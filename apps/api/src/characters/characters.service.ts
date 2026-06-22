import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CharacterXpSource, ItemCategory, PointSource } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { PointsService } from '@/points/points.service';

@Injectable()
export class CharactersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pointsService: PointsService,
  ) {}

  async getMyCharacter(studentId: string) {
    const character = await this.ensureCharacter(studentId);

    // Load equipped items
    const itemIds = [
      character.hatItemId,
      character.glassesItemId,
      character.outfitItemId,
      character.bgItemId,
      character.expressionItemId,
    ].filter(Boolean) as string[];

    const equippedItems =
      itemIds.length > 0
        ? await this.prisma.characterItem.findMany({
            where: { id: { in: itemIds } },
          })
        : [];

    const recentXpEvents = await this.prisma.characterXpTransaction.findMany({
      where: { studentId },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    return {
      success: true,
      data: this.serializeCharacter(character, equippedItems, recentXpEvents),
      meta: {},
    };
  }

  async awardXp(
    studentId: string,
    amount: number,
    source: CharacterXpSource,
    referenceKey: string,
    memo?: string,
    points = 0,
  ) {
    const normalizedAmount = Math.floor(amount);
    if (normalizedAmount <= 0) {
      return {
        xp: 0,
        points,
        leveledUp: false,
        levelsGained: 0,
        level: 1,
        xpToNext: this.xpRequiredForLevel(1),
        growthStage: this.growthStageForLevel(1),
        duplicate: false,
      };
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const existing = await tx.characterXpTransaction.findUnique({
        where: { studentId_referenceKey: { studentId, referenceKey } },
      });
      if (existing) {
        const current = await tx.studentCharacter.findUnique({
          where: { studentId },
        });
        const level = current?.level ?? 1;
        return {
          duplicate: true,
          points: 0,
          leveledUp: false,
          levelsGained: 0,
          level,
          xp: current?.xp ?? 0,
          xpToNext: this.xpRequiredForLevel(level) - (current?.xp ?? 0),
          growthStage: current?.growthStage ?? this.growthStageForLevel(level),
        };
      }

      const character =
        (await tx.studentCharacter.findUnique({ where: { studentId } })) ??
        (await tx.studentCharacter.create({ data: { studentId } }));

      const levelBefore = character.level;
      let level = character.level;
      let xp = character.xp + normalizedAmount;
      let levelsGained = 0;
      while (xp >= this.xpRequiredForLevel(level)) {
        xp -= this.xpRequiredForLevel(level);
        level += 1;
        levelsGained += 1;
      }
      const growthStage = this.growthStageForLevel(level);
      const updated = await tx.studentCharacter.update({
        where: { studentId },
        data: {
          level,
          xp,
          growthStage,
          ...(levelsGained > 0 ? { lastLevelUpAt: new Date() } : {}),
        },
      });
      await tx.characterXpTransaction.create({
        data: {
          studentId,
          source,
          amount: normalizedAmount,
          points,
          levelBefore,
          levelAfter: updated.level,
          xpAfter: updated.xp,
          balanceAfter: xp,
          referenceKey,
          memo,
        },
      });
      return {
        duplicate: false,
        points: levelsGained * 20,
        leveledUp: levelsGained > 0,
        levelsGained,
        level: updated.level,
        xp: updated.xp,
        xpToNext: this.xpRequiredForLevel(updated.level) - updated.xp,
        growthStage: updated.growthStage,
      };
    });

    if (result.points > 0) {
      await this.pointsService.earn(
        studentId,
        result.points,
        PointSource.LEVEL_UP_BONUS,
        `Lv.${result.level} 성장 보너스`,
      );
    }

    return result;
  }

  async getShop(studentId: string, category?: ItemCategory) {
    const [items, owned] = await Promise.all([
      this.prisma.characterItem.findMany({
        where: { isActive: true, ...(category ? { category } : {}) },
        orderBy: [{ category: 'asc' }, { sortOrder: 'asc' }],
      }),
      this.prisma.studentItem.findMany({
        where: { studentId },
        select: { itemId: true },
      }),
    ]);

    const ownedIds = new Set(owned.map((o) => o.itemId));
    const data = items.map((item) => ({
      ...item,
      owned: ownedIds.has(item.id),
    }));

    return { success: true, data, meta: {} };
  }

  async buyItem(studentId: string, itemId: string) {
    const item = await this.prisma.characterItem.findUnique({
      where: { id: itemId },
    });
    if (!item || !item.isActive)
      throw new NotFoundException('아이템을 찾을 수 없습니다.');

    const existing = await this.prisma.studentItem.findUnique({
      where: { studentId_itemId: { studentId, itemId } },
    });
    if (existing) throw new BadRequestException('이미 보유한 아이템입니다.');

    if (item.price > 0) {
      await this.pointsService.spend(
        studentId,
        item.price,
        PointSource.ITEM_PURCHASE,
        `${item.name} 구매`,
      );
    }

    await this.prisma.studentItem.create({
      data: { studentId, itemId },
    });

    return {
      success: true,
      data: { purchased: true, itemId, itemName: item.name },
      meta: {},
    };
  }

  async equip(
    studentId: string,
    body: {
      hatItemId?: string | null;
      glassesItemId?: string | null;
      outfitItemId?: string | null;
      bgItemId?: string | null;
      expressionItemId?: string | null;
    },
  ) {
    // Verify all items are owned
    const itemIds = Object.values(body).filter(Boolean) as string[];
    if (itemIds.length > 0) {
      const owned = await this.prisma.studentItem.findMany({
        where: { studentId, itemId: { in: itemIds } },
        select: { itemId: true },
      });
      const ownedSet = new Set(owned.map((o) => o.itemId));
      // Also check default (free) items
      const defaults = await this.prisma.characterItem.findMany({
        where: { id: { in: itemIds }, isDefault: true },
        select: { id: true },
      });
      defaults.forEach((d) => ownedSet.add(d.id));

      for (const id of itemIds) {
        if (!ownedSet.has(id))
          throw new BadRequestException('보유하지 않은 아이템입니다.');
      }
    }

    const character = await this.prisma.studentCharacter.upsert({
      where: { studentId },
      create: { studentId, ...body },
      update: body,
    });

    return { success: true, data: character, meta: {} };
  }

  async getOwnedItems(studentId: string) {
    const items = await this.prisma.studentItem.findMany({
      where: { studentId },
      include: { item: true },
      orderBy: { purchasedAt: 'desc' },
    });
    return { success: true, data: items.map((si) => si.item), meta: {} };
  }

  private ensureCharacter(studentId: string) {
    return this.prisma.studentCharacter.upsert({
      where: { studentId },
      create: { studentId },
      update: {},
    });
  }

  private serializeCharacter(
    character: Awaited<ReturnType<CharactersService['ensureCharacter']>>,
    equippedItems: unknown[],
    recentXpEvents: unknown[] = [],
  ) {
    return {
      ...character,
      equippedItems,
      stageAssetKey: character.growthStage,
      xpToNext: this.xpRequiredForLevel(character.level) - character.xp,
      xpProgress:
        character.xp / Math.max(1, this.xpRequiredForLevel(character.level)),
      growthStageLabel: this.growthStageLabel(character.level),
      recentXpEvents,
    };
  }

  private xpRequiredForLevel(level: number) {
    return 100 + (Math.max(1, level) - 1) * 50;
  }

  private growthStageForLevel(level: number) {
    if (level >= 15) return 'stage_05';
    if (level >= 10) return 'stage_04';
    if (level >= 6) return 'stage_03';
    if (level >= 3) return 'stage_02';
    return 'stage_01';
  }

  private growthStageLabel(level: number) {
    if (level >= 15) return '마스터';
    if (level >= 10) return '도전가';
    if (level >= 6) return '집중러';
    if (level >= 3) return '루틴러';
    return '입문자';
  }
}
