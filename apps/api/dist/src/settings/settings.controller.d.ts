import { JwtPayload } from "../auth/types/jwt-payload.type";
import { SettingsService } from './settings.service';
export declare class SettingsController {
    private readonly settingsService;
    constructor(settingsService: SettingsService);
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
    patchAttendancePolicy(user: JwtPayload, body: Record<string, unknown>): Promise<{
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
    patchTvDisplay(user: JwtPayload, body: Record<string, unknown>): Promise<{
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
