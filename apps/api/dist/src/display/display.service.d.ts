import { RankingPeriodType, RankingType } from '@prisma/client';
import { PrismaService } from "../database/prisma.service";
import { RankingsService } from "../rankings/rankings.service";
import { SettingsService } from "../settings/settings.service";
export declare class DisplayService {
    private readonly prisma;
    private readonly rankingsService;
    private readonly settingsService;
    constructor(prisma: PrismaService, rankingsService: RankingsService, settingsService: SettingsService);
    current(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            activeScreen: import("@prisma/client").$Enums.DisplayScreen;
            rotationEnabled: boolean;
            rotationIntervalSeconds: number;
            displayOptions: import("@prisma/client/runtime/library").JsonValue;
            updatedById: string | null;
        } | null;
        meta: {};
    }>;
    rankings(periodType?: RankingPeriodType, rankingType?: RankingType): Promise<{
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
    status(): Promise<{
        success: boolean;
        data: {
            checkedInCount: number;
            seatOccupancyRate: number;
            liveStudyMinutes: number;
            todayTotalStudyMinutes: number;
        };
        meta: {};
    }>;
    motivation(): Promise<{
        success: boolean;
        data: {
            message: string;
            topStudent: {
                name: string;
                rankNo: number;
                score: number;
            } | null;
            challenge: string;
        };
        meta: {};
    }>;
    control(activeScreen: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            activeScreen: import("@prisma/client").$Enums.DisplayScreen;
            rotationEnabled: boolean;
            rotationIntervalSeconds: number;
            displayOptions: import("@prisma/client/runtime/library").JsonValue;
            updatedById: string | null;
        };
        meta: {};
    }>;
}
