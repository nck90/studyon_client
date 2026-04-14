import { AuditService } from "../audit/audit.service";
import { PrismaService } from "../database/prisma.service";
import { EventsService } from "../events/events.service";
export declare class SettingsService {
    private readonly prisma;
    private readonly audit;
    private readonly events;
    constructor(prisma: PrismaService, audit: AuditService, events: EventsService);
    getAttendancePolicy(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            isActive: boolean;
            policyName: string;
            lateCutoffTime: string;
            earlyLeaveCutoffTime: string;
            autoCheckoutEnabled: boolean;
            autoCheckoutAfterMinutes: number | null;
            createdById: string | null;
        } | null;
        meta: {};
    }>;
    updateAttendancePolicy(data: Record<string, unknown>, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            isActive: boolean;
            policyName: string;
            lateCutoffTime: string;
            earlyLeaveCutoffTime: string;
            autoCheckoutEnabled: boolean;
            autoCheckoutAfterMinutes: number | null;
            createdById: string | null;
        };
        meta: {};
    }>;
    getRankingPolicy(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            isActive: boolean;
            policyName: string;
            createdById: string | null;
            studyTimeWeight: import("@prisma/client/runtime/library").Decimal;
            studyVolumeWeight: import("@prisma/client/runtime/library").Decimal;
            attendanceWeight: import("@prisma/client/runtime/library").Decimal;
            tieBreakerRule: import("@prisma/client/runtime/library").JsonValue;
        } | null;
        meta: {};
    }>;
    getTvDisplay(): Promise<{
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
    updateTvDisplay(data: Record<string, unknown>, actorUserId?: string): Promise<{
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
