import { Prisma, RankingPeriodType, RankingType } from '@prisma/client';
import { JwtPayload } from "../auth/types/jwt-payload.type";
import { PrismaService } from "../database/prisma.service";
import { RankingsService } from './rankings.service';
export declare class RankingsController {
    private readonly rankingsService;
    private readonly prisma;
    constructor(rankingsService: RankingsService, prisma: PrismaService);
    studentRankings(user: JwtPayload, periodType?: RankingPeriodType, rankingType?: RankingType): Promise<{
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
    adminRankings(periodType?: RankingPeriodType, rankingType?: RankingType): Promise<{
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
                    passwordHash: string;
                    studentNo: string;
                    loginId: string;
                    groupId: string | null;
                    assignedSeatId: string | null;
                    enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                    joinedAt: Date | null;
                    memo: string | null;
                    pointBalance: number;
                };
            } & {
                id: string;
                createdAt: Date;
                score: Prisma.Decimal;
                subScore1: Prisma.Decimal;
                subScore2: Prisma.Decimal;
                studentId: string;
                rankingSnapshotId: string;
                rankNo: number;
            })[];
        };
        meta: {};
    }>;
    getActivePolicy(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            isActive: boolean;
            policyName: string;
            createdById: string | null;
            studyTimeWeight: Prisma.Decimal;
            studyVolumeWeight: Prisma.Decimal;
            attendanceWeight: Prisma.Decimal;
            tieBreakerRule: Prisma.JsonValue;
        } | null;
        meta: {};
    }>;
    createPolicy(body: Record<string, unknown>): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            isActive: boolean;
            policyName: string;
            createdById: string | null;
            studyTimeWeight: Prisma.Decimal;
            studyVolumeWeight: Prisma.Decimal;
            attendanceWeight: Prisma.Decimal;
            tieBreakerRule: Prisma.JsonValue;
        };
        meta: {};
    }>;
    patchPolicy(policyId: string, body: Record<string, unknown>): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            isActive: boolean;
            policyName: string;
            createdById: string | null;
            studyTimeWeight: Prisma.Decimal;
            studyVolumeWeight: Prisma.Decimal;
            attendanceWeight: Prisma.Decimal;
            tieBreakerRule: Prisma.JsonValue;
        };
        meta: {};
    }>;
}
