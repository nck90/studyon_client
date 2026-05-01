"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CharactersService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../database/prisma.service");
const points_service_1 = require("../points/points.service");
let CharactersService = class CharactersService {
    prisma;
    pointsService;
    constructor(prisma, pointsService) {
        this.prisma = prisma;
        this.pointsService = pointsService;
    }
    async getMyCharacter(studentId) {
        let character = await this.prisma.studentCharacter.findUnique({
            where: { studentId },
        });
        if (!character) {
            character = await this.prisma.studentCharacter.create({
                data: { studentId },
            });
        }
        const itemIds = [
            character.hatItemId,
            character.glassesItemId,
            character.outfitItemId,
            character.bgItemId,
            character.expressionItemId,
        ].filter(Boolean);
        const equippedItems = itemIds.length > 0
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
    async getShop(studentId, category) {
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
    async buyItem(studentId, itemId) {
        const item = await this.prisma.characterItem.findUnique({
            where: { id: itemId },
        });
        if (!item || !item.isActive)
            throw new common_1.NotFoundException('아이템을 찾을 수 없습니다.');
        const existing = await this.prisma.studentItem.findUnique({
            where: { studentId_itemId: { studentId, itemId } },
        });
        if (existing)
            throw new common_1.BadRequestException('이미 보유한 아이템입니다.');
        if (item.price > 0) {
            await this.pointsService.spend(studentId, item.price, client_1.PointSource.ITEM_PURCHASE, `${item.name} 구매`);
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
    async equip(studentId, body) {
        const itemIds = Object.values(body).filter(Boolean);
        if (itemIds.length > 0) {
            const owned = await this.prisma.studentItem.findMany({
                where: { studentId, itemId: { in: itemIds } },
                select: { itemId: true },
            });
            const ownedSet = new Set(owned.map((o) => o.itemId));
            const defaults = await this.prisma.characterItem.findMany({
                where: { id: { in: itemIds }, isDefault: true },
                select: { id: true },
            });
            defaults.forEach((d) => ownedSet.add(d.id));
            for (const id of itemIds) {
                if (!ownedSet.has(id))
                    throw new common_1.BadRequestException('보유하지 않은 아이템입니다.');
            }
        }
        const character = await this.prisma.studentCharacter.upsert({
            where: { studentId },
            create: { studentId, ...body },
            update: body,
        });
        return { success: true, data: character, meta: {} };
    }
    async getOwnedItems(studentId) {
        const items = await this.prisma.studentItem.findMany({
            where: { studentId },
            include: { item: true },
            orderBy: { purchasedAt: 'desc' },
        });
        return { success: true, data: items.map((si) => si.item), meta: {} };
    }
};
exports.CharactersService = CharactersService;
exports.CharactersService = CharactersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        points_service_1.PointsService])
], CharactersService);
//# sourceMappingURL=characters.service.js.map