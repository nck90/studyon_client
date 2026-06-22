import { AppEventType } from '@prisma/client';
import { JwtPayload } from "../auth/types/jwt-payload.type";
import { StudentsService } from './students.service';
export declare class StudentsController {
    private readonly studentsService;
    constructor(studentsService: StudentsService);
    home(user: JwtPayload): Promise<{
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
    profile(user: JwtPayload): Promise<{
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
    badges(user: JwtPayload): Promise<{
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
    preferences(user: JwtPayload): Promise<{
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
    focusPolicy(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            policyName: string;
            mode: import("@prisma/client").$Enums.FocusPolicyMode;
            isEnabled: boolean;
            blockedPackages: import("@prisma/client/runtime/library").JsonValue;
            allowedPackages: import("@prisma/client/runtime/library").JsonValue;
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
    updatePreferences(user: JwtPayload, body: {
        notificationEnabled?: boolean;
        targetUniversityName?: string | null;
        targetUniversityMediaId?: string | null;
        homeBackgroundMediaId?: string | null;
        checkInBackgroundMediaId?: string | null;
        themePreset?: string | null;
        focusModeEnabled?: boolean;
        tvGoalConsent?: boolean;
    }): Promise<{
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
    focusEvent(user: JwtPayload, body: {
        sessionId?: string | null;
        studySessionId?: string | null;
        eventType?: string;
        occurredAt?: string;
        durationSeconds?: number | null;
    }): Promise<{
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
    motivationDashboard(user: JwtPayload): Promise<{
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
    goalRoadmap(user: JwtPayload): Promise<{
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
    saveGoalRoadmap(user: JwtPayload, body: {
        targetName?: string;
        targetDate?: string;
        reminderEnabled?: boolean;
        reminderTime?: string;
    }): Promise<{
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
    generateGoalRoadmap(user: JwtPayload): Promise<{
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
    acceptRoadmapMission(user: JwtPayload, missionId: string): Promise<{
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
    dailyMissionToday(user: JwtPayload): Promise<{
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
    generateDailyMission(user: JwtPayload): Promise<{
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
    completeDailyMission(user: JwtPayload, missionId: string, body: {
        completionMethod?: string;
    }): Promise<{
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
    updateDailyMissionReminder(user: JwtPayload, body: {
        reminderEnabled?: boolean;
        reminderTime?: string;
    }): Promise<{
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
    appEvent(user: JwtPayload, body: {
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
            payload: import("@prisma/client/runtime/library").JsonValue | null;
        };
        meta: {};
    }>;
}
