import { ItemCategory } from '@prisma/client';
import { PrismaService } from "../database/prisma.service";
import { PointsService } from "../points/points.service";
export declare class CharactersService {
    private readonly prisma;
    private readonly pointsService;
    constructor(prisma: PrismaService, pointsService: PointsService);
    getMyCharacter(studentId: string): Promise<{
        success: boolean;
        data: {
            equippedItems: {
                id: string;
                name: string;
                sortOrder: number;
                createdAt: Date;
                isActive: boolean;
                description: string | null;
                isDefault: boolean;
                category: import("@prisma/client").$Enums.ItemCategory;
                price: number;
                svgKey: string;
            }[];
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            hatItemId: string | null;
            glassesItemId: string | null;
            outfitItemId: string | null;
            bgItemId: string | null;
            expressionItemId: string | null;
        };
        meta: {};
    }>;
    getShop(studentId: string, category?: ItemCategory): Promise<{
        success: boolean;
        data: {
            owned: boolean;
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
            isActive: boolean;
            description: string | null;
            isDefault: boolean;
            category: import("@prisma/client").$Enums.ItemCategory;
            price: number;
            svgKey: string;
        }[];
        meta: {};
    }>;
    buyItem(studentId: string, itemId: string): Promise<{
        success: boolean;
        data: {
            purchased: boolean;
            itemId: string;
            itemName: string;
        };
        meta: {};
    }>;
    equip(studentId: string, body: {
        hatItemId?: string | null;
        glassesItemId?: string | null;
        outfitItemId?: string | null;
        bgItemId?: string | null;
        expressionItemId?: string | null;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            hatItemId: string | null;
            glassesItemId: string | null;
            outfitItemId: string | null;
            bgItemId: string | null;
            expressionItemId: string | null;
        };
        meta: {};
    }>;
    getOwnedItems(studentId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
            isActive: boolean;
            description: string | null;
            isDefault: boolean;
            category: import("@prisma/client").$Enums.ItemCategory;
            price: number;
            svgKey: string;
        }[];
        meta: {};
    }>;
}
