import { RankingPeriodType, RankingType } from '@prisma/client';
import { PrismaService } from "../database/prisma.service";
import { MetricsService } from "../metrics/metrics.service";
export declare class RankingsService {
    private readonly prisma;
    private readonly metricsService;
    constructor(prisma: PrismaService, metricsService: MetricsService);
    studentRanking(studentId: string, periodType: RankingPeriodType, rankingType: RankingType): Promise<{
        success: boolean;
        data: {
            myRank: {
                rankNo: number;
                score: number;
            };
            items: {
                studentId: string;
                studentName: string;
                rankNo: number;
                score: number;
            }[];
        };
        meta: {};
    }>;
    adminRanking(periodType: RankingPeriodType, rankingType: RankingType): Promise<{
        success: boolean;
        data: {
            snapshot: {
                id: string;
                createdAt: Date;
                rankingType: import("@prisma/client").$Enums.RankingType;
                periodType: import("@prisma/client").$Enums.RankingPeriodType;
                periodKey: string;
                generatedAt: Date;
            };
            items: ({
                student: {
                    user: {
                        id: string;
                        name: string;
                        createdAt: Date;
                        status: import("@prisma/client").$Enums.UserStatus;
                        updatedAt: Date;
                        role: import("@prisma/client").$Enums.UserRole;
                        phone: string | null;
                        lastLoginAt: Date | null;
                    };
                } & {
                    id: string;
                    createdAt: Date;
                    gradeId: string | null;
                    classId: string | null;
                    updatedAt: Date;
                    userId: string;
                    studentNo: string;
                    groupId: string | null;
                    assignedSeatId: string | null;
                    enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                    joinedAt: Date | null;
                    memo: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                score: import("@prisma/client/runtime/library").Decimal;
                subScore1: import("@prisma/client/runtime/library").Decimal;
                subScore2: import("@prisma/client/runtime/library").Decimal;
                studentId: string;
                rankingSnapshotId: string;
                rankNo: number;
            })[];
        };
        meta: {};
    }>;
    ensureSnapshot(periodType: RankingPeriodType, rankingType: RankingType): Promise<{
        id: string;
        createdAt: Date;
        rankingType: import("@prisma/client").$Enums.RankingType;
        periodType: import("@prisma/client").$Enums.RankingPeriodType;
        periodKey: string;
        generatedAt: Date;
    }>;
}
