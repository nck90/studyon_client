import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ItemCategory, PointSource } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { PointsService } from '@/points/points.service';

@Injectable()
export class CharactersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pointsService: PointsService,
  ) {}

  async getMyCharacter(studentId: string) {
    let character = await this.prisma.studentCharacter.findUnique({
      where: { studentId },
    });
    if (!character) {
      character = await this.prisma.studentCharacter.create({
        data: { studentId },
      });
    }

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

    return {
      success: true,
      data: { ...character, equippedItems },
      meta: {},
    };
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
}
