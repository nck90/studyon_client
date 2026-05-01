import { PointSource } from '@prisma/client';
import { PrismaService } from "../database/prisma.service";
export declare class PointsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getBalance(studentId: string): Promise<{
        success: boolean;
        data: {
            balance: number;
        };
        meta: {};
    }>;
    getHistory(studentId: string, take?: number, skip?: number): Promise<{
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
    earnStudyTime(studentId: string, studySeconds: number, memo?: string, source?: PointSource): Promise<number | null | undefined>;
    awardStudySessionTime(studentId: string, sessionId: string, studySeconds: number): Promise<number | null | undefined>;
    earn(studentId: string, amount: number, source: PointSource, memo?: string): Promise<number | undefined>;
    spend(studentId: string, amount: number, source: PointSource, memo?: string): Promise<number>;
}
