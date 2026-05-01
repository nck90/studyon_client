import { ItemCategory } from '@prisma/client';
import { JwtPayload } from "../auth/types/jwt-payload.type";
import { CharactersService } from './characters.service';
export declare class CharactersController {
    private readonly charactersService;
    constructor(charactersService: CharactersService);
    getMyCharacter(user: JwtPayload): Promise<{
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
    getShop(user: JwtPayload, category?: ItemCategory): Promise<{
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
    getOwnedItems(user: JwtPayload): Promise<{
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
    buyItem(user: JwtPayload, itemId: string): Promise<{
        success: boolean;
        data: {
            purchased: boolean;
            itemId: string;
            itemName: string;
        };
        meta: {};
    }>;
    equip(user: JwtPayload, body: {
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
}
