import { AppEventType, Prisma } from '@prisma/client';
import { PrismaService } from "../database/prisma.service";
import { EventsService } from "../events/events.service";
import { MediaService } from "../media/media.service";
type StudentPreferenceInput = {
    notificationEnabled?: boolean;
    targetUniversityName?: string | null;
    targetUniversityMediaId?: string | null;
    homeBackgroundMediaId?: string | null;
    checkInBackgroundMediaId?: string | null;
    themePreset?: string | null;
    focusModeEnabled?: boolean;
    tvGoalConsent?: boolean;
};
type RoadmapInput = {
    targetName?: string;
    targetDate?: string;
    reminderEnabled?: boolean;
    reminderTime?: string;
};
type ReminderInput = {
    reminderEnabled?: boolean;
    reminderTime?: string;
};
type FocusEventInput = {
    sessionId?: string | null;
    studySessionId?: string | null;
    eventType?: string;
    occurredAt?: string;
    durationSeconds?: number | null;
};
export declare class StudentsService {
    private readonly prisma;
    private readonly events;
    private readonly mediaService;
    constructor(prisma: PrismaService, events: EventsService, mediaService: MediaService);
    getStudentHome(studentId: string): Promise<{
        success: boolean;
        data: {
            todayAttendance: {
                status: import("@prisma/client").$Enums.AttendanceStatus;
                checkInAt: string | null;
                checkOutAt: string | null;
                stayMinutes: number;
            };
            seat: {
                seatId: string;
                seatNo: string;
                status: import("@prisma/client").$Enums.SeatStatus;
            } | null;
            study: {
                sessionStatus: import("@prisma/client").$Enums.StudySessionStatus;
                studyMinutes: number;
                breakMinutes: number;
            };
            plans: {
                totalCount: number;
                completedCount: number;
                targetMinutes: number;
            };
            notifications: {
                id: string;
                title: string;
            }[];
            streakDays: number;
            community: {
                checkedInStudentCount: number;
                totalActiveStudents: number;
            };
            student: {
                id: string;
                name: string;
                studentNo: string;
                className: string | null;
            };
        };
        meta: {};
    }>;
    getProfile(studentId: string): Promise<{
        success: boolean;
        data: {
            preferences: {
                notificationEnabled: boolean;
                targetUniversityName: string;
                targetUniversityMediaId: string | null;
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
                } | null;
                homeBackgroundMediaId: string | null;
                homeBackgroundMedia: {
                    id: string;
                    createdAt: Date;
                    studentId: string;
                    kind: import("@prisma/client").$Enums.MediaAssetKind;
                    originalName: string;
                    mimeType: string;
                    byteSize: number;
                    storageKey: string;
                    publicUrl: string;
                } | null;
                checkInBackgroundMediaId: string | null;
                checkInBackgroundMedia: {
                    id: string;
                    createdAt: Date;
                    studentId: string;
                    kind: import("@prisma/client").$Enums.MediaAssetKind;
                    originalName: string;
                    mimeType: string;
                    byteSize: number;
                    storageKey: string;
                    publicUrl: string;
                } | null;
                themePreset: string;
                focusModeEnabled: boolean;
                tvGoalConsent: boolean;
                tvGoalApprovalStatus: string;
                tvGoalReviewedAt: string | null;
                tvGoalReviewedBy: string | null;
                tvGoalReviewMemo: string | null;
                dailyMissionReminderEnabled: boolean;
                dailyMissionReminderTime: string;
            };
            profileStats: {
                totalStudySeconds: number;
                totalStudyMinutes: number;
                totalPoints: number;
                level: number;
                completedPlansCount: number;
                badgeCount: number;
                streakDays: number;
            };
            grade: {
                id: string;
                name: string;
                sortOrder: number;
                createdAt: Date;
            } | null;
            class: {
                id: string;
                name: string;
                sortOrder: number;
                createdAt: Date;
                gradeId: string | null;
            } | null;
            group: {
                id: string;
                name: string;
                sortOrder: number;
                createdAt: Date;
                classId: string | null;
            } | null;
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
            assignedSeat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            } | null;
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
        meta: {};
    }>;
    getBadges(studentId: string): Promise<{
        success: boolean;
        data: ({
            badge: {
                id: string;
                name: string;
                createdAt: Date;
                isActive: boolean;
                code: string;
                description: string | null;
                badgeType: import("@prisma/client").$Enums.BadgeType;
                iconUrl: string | null;
            };
        } & {
            id: string;
            createdAt: Date;
            badgeId: string;
            studentId: string;
            awardedAt: Date;
            reason: string | null;
        })[];
        meta: {};
    }>;
    getPreferences(studentId: string): Promise<{
        success: boolean;
        data: {
            notificationEnabled: boolean;
            targetUniversityName: string;
            targetUniversityMediaId: string | null;
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
            } | null;
            homeBackgroundMediaId: string | null;
            homeBackgroundMedia: {
                id: string;
                createdAt: Date;
                studentId: string;
                kind: import("@prisma/client").$Enums.MediaAssetKind;
                originalName: string;
                mimeType: string;
                byteSize: number;
                storageKey: string;
                publicUrl: string;
            } | null;
            checkInBackgroundMediaId: string | null;
            checkInBackgroundMedia: {
                id: string;
                createdAt: Date;
                studentId: string;
                kind: import("@prisma/client").$Enums.MediaAssetKind;
                originalName: string;
                mimeType: string;
                byteSize: number;
                storageKey: string;
                publicUrl: string;
            } | null;
            themePreset: string;
            focusModeEnabled: boolean;
            tvGoalConsent: boolean;
            tvGoalApprovalStatus: string;
            tvGoalReviewedAt: string | null;
            tvGoalReviewedBy: string | null;
            tvGoalReviewMemo: string | null;
            dailyMissionReminderEnabled: boolean;
            dailyMissionReminderTime: string;
        };
        meta: {};
    }>;
    getFocusPolicy(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            policyName: string;
            mode: import("@prisma/client").$Enums.FocusPolicyMode;
            isEnabled: boolean;
            blockedPackages: Prisma.JsonValue;
            allowedPackages: Prisma.JsonValue;
            graceSeconds: number;
            opsQueueThreshold: number;
            parentReportThreshold: number;
        } | {
            id: null;
            policyName: string;
            mode: "SOFT_LOCK";
            isEnabled: false;
            blockedPackages: never[];
            allowedPackages: never[];
            graceSeconds: number;
            opsQueueThreshold: number;
            parentReportThreshold: number;
        };
        meta: {};
    }>;
    updatePreferences(studentId: string, input: StudentPreferenceInput): Promise<{
        success: boolean;
        data: {
            notificationEnabled: boolean;
            targetUniversityName: string | null;
            targetUniversityMediaId: string | null;
            homeBackgroundMediaId: string | null;
            checkInBackgroundMediaId: string | null;
            themePreset: string | null;
            focusModeEnabled: boolean;
            tvGoalConsent: boolean;
            tvGoalApprovalStatus: string;
            tvGoalReviewedAt: string | null;
            tvGoalReviewedBy: string | null;
            tvGoalReviewMemo: string | null;
        };
        meta: {};
    }>;
    getMotivationDashboard(studentId: string): Promise<{
        success: boolean;
        data: {
            preferences: {
                notificationEnabled: boolean;
                targetUniversityName: string;
                targetUniversityMediaId: string | null;
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
                } | null;
                homeBackgroundMediaId: string | null;
                homeBackgroundMedia: {
                    id: string;
                    createdAt: Date;
                    studentId: string;
                    kind: import("@prisma/client").$Enums.MediaAssetKind;
                    originalName: string;
                    mimeType: string;
                    byteSize: number;
                    storageKey: string;
                    publicUrl: string;
                } | null;
                checkInBackgroundMediaId: string | null;
                checkInBackgroundMedia: {
                    id: string;
                    createdAt: Date;
                    studentId: string;
                    kind: import("@prisma/client").$Enums.MediaAssetKind;
                    originalName: string;
                    mimeType: string;
                    byteSize: number;
                    storageKey: string;
                    publicUrl: string;
                } | null;
                themePreset: string;
                focusModeEnabled: boolean;
                tvGoalConsent: boolean;
                tvGoalApprovalStatus: string;
                tvGoalReviewedAt: string | null;
                tvGoalReviewedBy: string | null;
                tvGoalReviewMemo: string | null;
                dailyMissionReminderEnabled: boolean;
                dailyMissionReminderTime: string;
            };
            today: {
                studyMinutes: number;
                targetMinutes: number;
                achievedRate: number;
                pagesCompleted: number;
                problemsSolved: number;
                streakDays: number;
            };
            week: {
                studyMinutes: number;
                targetMinutes: number;
                achievedRate: number;
            };
            month: {
                studyMinutes: number;
                targetMinutes: number;
                achievedRate: number;
            };
            badges: ({
                badge: {
                    id: string;
                    name: string;
                    createdAt: Date;
                    isActive: boolean;
                    code: string;
                    description: string | null;
                    badgeType: import("@prisma/client").$Enums.BadgeType;
                    iconUrl: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                badgeId: string;
                studentId: string;
                awardedAt: Date;
                reason: string | null;
            })[];
            plans: {
                id: string;
                createdAt: Date;
                status: import("@prisma/client").$Enums.StudyPlanStatus;
                updatedAt: Date;
                description: string | null;
                title: string;
                studentId: string;
                planDate: Date;
                subjectName: string;
                targetMinutes: number;
                priority: import("@prisma/client").$Enums.StudyPlanPriority;
                completedAt: Date | null;
            }[];
        };
        meta: {};
    }>;
    getGoalRoadmap(studentId: string): Promise<{
        success: boolean;
        data: {
            roadmap: null;
            milestones: never[];
            currentMission: null;
            daysLeft: null;
            progressPercent: number;
        } | {
            roadmap: {
                id: string;
                targetName: string;
                targetDate: string;
                status: import("@prisma/client").$Enums.GoalRoadmapStatus;
                reminderEnabled: boolean;
                reminderTime: string;
            };
            milestones: {
                id: string;
                title: string;
                periodStart: string;
                periodEnd: string;
                targetMinutes: number;
                focusSubjects: string[];
            }[];
            currentMission: {
                id: string;
                title: string;
                description: string | null;
                weekStartDate: string;
                targetMinutes: number;
                status: import("@prisma/client").$Enums.RoadmapMissionStatus;
                focusSubjects: string[];
            } | null;
            daysLeft: number;
            progressPercent: number;
        };
        meta: {};
    }>;
    saveGoalRoadmap(studentId: string, input: RoadmapInput): Promise<{
        success: boolean;
        data: {
            roadmap: null;
            milestones: never[];
            currentMission: null;
            daysLeft: null;
            progressPercent: number;
        } | {
            roadmap: {
                id: string;
                targetName: string;
                targetDate: string;
                status: import("@prisma/client").$Enums.GoalRoadmapStatus;
                reminderEnabled: boolean;
                reminderTime: string;
            };
            milestones: {
                id: string;
                title: string;
                periodStart: string;
                periodEnd: string;
                targetMinutes: number;
                focusSubjects: string[];
            }[];
            currentMission: {
                id: string;
                title: string;
                description: string | null;
                weekStartDate: string;
                targetMinutes: number;
                status: import("@prisma/client").$Enums.RoadmapMissionStatus;
                focusSubjects: string[];
            } | null;
            daysLeft: number;
            progressPercent: number;
        };
        meta: {};
    }>;
    generateGoalRoadmap(studentId: string): Promise<{
        success: boolean;
        data: {
            roadmap: null;
            milestones: never[];
            currentMission: null;
            daysLeft: null;
            progressPercent: number;
        } | {
            roadmap: {
                id: string;
                targetName: string;
                targetDate: string;
                status: import("@prisma/client").$Enums.GoalRoadmapStatus;
                reminderEnabled: boolean;
                reminderTime: string;
            };
            milestones: {
                id: string;
                title: string;
                periodStart: string;
                periodEnd: string;
                targetMinutes: number;
                focusSubjects: string[];
            }[];
            currentMission: {
                id: string;
                title: string;
                description: string | null;
                weekStartDate: string;
                targetMinutes: number;
                status: import("@prisma/client").$Enums.RoadmapMissionStatus;
                focusSubjects: string[];
            } | null;
            daysLeft: number;
            progressPercent: number;
        };
        meta: {};
    }>;
    acceptRoadmapMission(studentId: string, missionId: string): Promise<{
        success: boolean;
        data: {
            roadmap: null;
            milestones: never[];
            currentMission: null;
            daysLeft: null;
            progressPercent: number;
        } | {
            roadmap: {
                id: string;
                targetName: string;
                targetDate: string;
                status: import("@prisma/client").$Enums.GoalRoadmapStatus;
                reminderEnabled: boolean;
                reminderTime: string;
            };
            milestones: {
                id: string;
                title: string;
                periodStart: string;
                periodEnd: string;
                targetMinutes: number;
                focusSubjects: string[];
            }[];
            currentMission: {
                id: string;
                title: string;
                description: string | null;
                weekStartDate: string;
                targetMinutes: number;
                status: import("@prisma/client").$Enums.RoadmapMissionStatus;
                focusSubjects: string[];
            } | null;
            daysLeft: number;
            progressPercent: number;
        };
        meta: {};
    }>;
    getTodayDailyMission(studentId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            missionDate: string;
            title: string;
            subjectName: string;
            targetMinutes: number;
            status: import("@prisma/client").$Enums.DailyMissionStatus;
            source: import("@prisma/client").$Enums.DailyMissionSource;
            completedAt: string | null;
            completionMethod: string | null;
            template: {
                id: string;
                title: string;
                subjectName: string;
            } | null;
            reminder: {
                enabled: boolean;
                time: string;
            };
        };
        meta: {};
    }>;
    generateTodayDailyMission(studentId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            missionDate: string;
            title: string;
            subjectName: string;
            targetMinutes: number;
            status: import("@prisma/client").$Enums.DailyMissionStatus;
            source: import("@prisma/client").$Enums.DailyMissionSource;
            completedAt: string | null;
            completionMethod: string | null;
            template: {
                id: string;
                title: string;
                subjectName: string;
            } | null;
            reminder: {
                enabled: boolean;
                time: string;
            };
        };
        meta: {};
    }>;
    completeDailyMission(studentId: string, missionId: string, completionMethod?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            missionDate: string;
            title: string;
            subjectName: string;
            targetMinutes: number;
            status: import("@prisma/client").$Enums.DailyMissionStatus;
            source: import("@prisma/client").$Enums.DailyMissionSource;
            completedAt: string | null;
            completionMethod: string | null;
            template: {
                id: string;
                title: string;
                subjectName: string;
            } | null;
            reminder: {
                enabled: boolean;
                time: string;
            };
        };
        meta: {};
    }>;
    updateDailyMissionReminder(studentId: string, input: ReminderInput): Promise<{
        success: boolean;
        data: {
            dailyMissionReminderEnabled: boolean;
            dailyMissionReminderTime: string;
            notificationEnabled: boolean;
            targetUniversityName: string;
            targetUniversityMediaId: string | null;
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
            } | null;
            homeBackgroundMediaId: string | null;
            homeBackgroundMedia: {
                id: string;
                createdAt: Date;
                studentId: string;
                kind: import("@prisma/client").$Enums.MediaAssetKind;
                originalName: string;
                mimeType: string;
                byteSize: number;
                storageKey: string;
                publicUrl: string;
            } | null;
            checkInBackgroundMediaId: string | null;
            checkInBackgroundMedia: {
                id: string;
                createdAt: Date;
                studentId: string;
                kind: import("@prisma/client").$Enums.MediaAssetKind;
                originalName: string;
                mimeType: string;
                byteSize: number;
                storageKey: string;
                publicUrl: string;
            } | null;
            themePreset: string;
            focusModeEnabled: boolean;
            tvGoalConsent: boolean;
            tvGoalApprovalStatus: string;
            tvGoalReviewedAt: string | null;
            tvGoalReviewedBy: string | null;
            tvGoalReviewMemo: string | null;
        };
        meta: {};
    }>;
    recordAppEvent(studentId: string, input: {
        eventType?: AppEventType;
        occurredAt?: string;
        payload?: Record<string, unknown>;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            eventType: import("@prisma/client").$Enums.AppEventType;
            eventDate: Date;
            occurredAt: Date;
            payload: Prisma.JsonValue | null;
        };
        meta: {};
    }>;
    private getStudentPreferences;
    private ensureTodayDailyMission;
    private createOrRefreshTodayDailyMission;
    private findDailyMissionTemplate;
    private syncDailyMissionCompletion;
    private serializeDailyMission;
    private activeRoadmap;
    private ensureActiveRoadmap;
    private serializeRoadmap;
    private syncMissionStatus;
    private roadmapRecommendation;
    private buildMilestones;
    private normalizeReminderTime;
    private stringArray;
    recordFocusEvent(studentId: string, input: FocusEventInput): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            studentId: string;
            studySessionId: string | null;
            eventType: import("@prisma/client").$Enums.FocusEventType;
            eventDate: Date;
            occurredAt: Date;
            durationSeconds: number | null;
        };
        meta: {};
    }>;
    private normalizeFocusEventType;
    private normalizeDurationSeconds;
    private assertOwnedMedia;
    private preferenceKey;
    private deleteReplacedMedia;
}
export {};
