import { JwtPayload } from "../auth/types/jwt-payload.type";
import { PointsService } from './points.service';
export declare class PointsController {
    private readonly pointsService;
    constructor(pointsService: PointsService);
    getBalance(user: JwtPayload): Promise<{
        success: boolean;
        data: {
            balance: number;
        };
        meta: {};
    }>;
    getHistory(user: JwtPayload, take?: string, skip?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            memo: string | null;
            type: import("@prisma/client").$Enums.PointTransactionType;
            studentId: string;
            source: import("@prisma/client").$Enums.PointSource;
            amount: number;
            balance: number;
        }[];
        meta: {
            total: number;
            take: number;
            skip: number;
        };
    }>;
}
