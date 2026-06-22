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
            activeScreen: string;
            rotationEnabled: boolean;
            rotationIntervalSeconds: number;
            enabledScreens: string[];
            message: string;
            rankingType: string;
            periodType: string;
            updatedAt: string | null;
        };
        meta: {};
    }>;
    rankings(periodType?: RankingPeriodType, rankingType?: RankingType): Promise<{
        success: boolean;
        data: {
            items: {
                displayName: string;
                student: {
                    user: {
                        name: string;
                    };
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
                id: string;
                createdAt: Date;
                score: import("@prisma/client/runtime/library").Decimal;
                subScore1: import("@prisma/client/runtime/library").Decimal;
                subScore2: import("@prisma/client/runtime/library").Decimal;
                studentId: string;
                rankingSnapshotId: string;
                rankNo: number;
            }[];
            snapshot: {
                id: string;
                createdAt: Date;
                rankingType: import("@prisma/client").$Enums.RankingType;
                periodType: import("@prisma/client").$Enums.RankingPeriodType;
                periodKey: string;
                generatedAt: Date;
            };
        };
        meta: {};
    }>;
    seats(): Promise<{
        success: boolean;
        data: {
            id: string;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            uiStatus: string;
            currentStudent: {
                id: string;
                displayName: string;
            } | null;
        }[];
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
                displayName: string;
                rankNo: number;
                score: number;
            } | null;
            challenge: string;
        };
        meta: {};
    }>;
    goals(): Promise<{
        success: boolean;
        data: {
            goals: {
                studentId: string;
                displayName: string;
                targetUniversityName: unknown;
                targetUniversityMedia: {
                    id: string;
                    createdAt: Date;
                    studentId: string;
                    kind: import("@prisma/client").$Enums.MediaAssetKind;
                    originalName: string;
                    mimeType: string;
                    byteSize: number;
                    storageKey: string;
                    publicUrl: string;
                } | {
                    id: string;
                } | null;
            }[];
            achievers: {
                displayName: string;
                achievedRate: number;
                studyMinutes: number;
            }[];
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
    private normalizeSettings;
    private normalizeScreen;
    private studentIdFromPreferenceKey;
    private toSeatUiStatus;
    private maskName;
}
