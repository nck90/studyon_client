import { PrismaService } from "../database/prisma.service";
import { NotificationsService } from "../notifications/notifications.service";
import { PointsService } from "../points/points.service";
export declare class StudySessionsService {
    private readonly prisma;
    private readonly notificationsService;
    private readonly pointsService;
    constructor(prisma: PrismaService, notificationsService: NotificationsService, pointsService: PointsService);
    active(studentId: string): Promise<{
        success: boolean;
        data: ({
            linkedPlan: {
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
            } | null;
            studyBreaks: {
                id: string;
                createdAt: Date;
                startedAt: Date;
                endedAt: Date | null;
                breakMinutes: number;
                breakSeconds: number;
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            startedAt: Date | null;
            endedAt: Date | null;
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            autoClosedReason: string | null;
        } & {
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
        }) | null;
        meta: {};
    }>;
    start(studentId: string, linkedPlanId?: string): Promise<{
        success: boolean;
        data: {
            linkedPlan: {
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
            } | null;
            studyBreaks: {
                id: string;
                createdAt: Date;
                startedAt: Date;
                endedAt: Date | null;
                breakMinutes: number;
                breakSeconds: number;
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            startedAt: Date | null;
            endedAt: Date | null;
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            autoClosedReason: string | null;
        } & {
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
        };
        meta: {};
    }>;
    pause(studentId: string, sessionId: string): Promise<{
        success: boolean;
        data: {
            linkedPlan: {
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
            } | null;
            studyBreaks: {
                id: string;
                createdAt: Date;
                startedAt: Date;
                endedAt: Date | null;
                breakMinutes: number;
                breakSeconds: number;
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            startedAt: Date | null;
            endedAt: Date | null;
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            autoClosedReason: string | null;
        } & {
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
        };
        meta: {};
    }>;
    resume(studentId: string, sessionId: string): Promise<{
        success: boolean;
        data: {
            linkedPlan: {
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
            } | null;
            studyBreaks: {
                id: string;
                createdAt: Date;
                startedAt: Date;
                endedAt: Date | null;
                breakMinutes: number;
                breakSeconds: number;
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            startedAt: Date | null;
            endedAt: Date | null;
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            autoClosedReason: string | null;
        } & {
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
        };
        meta: {};
    }>;
    end(studentId: string, sessionId: string): Promise<{
        success: boolean;
        data: {
            linkedPlan: {
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
            } | null;
            studyBreaks: {
                id: string;
                createdAt: Date;
                startedAt: Date;
                endedAt: Date | null;
                breakMinutes: number;
                breakSeconds: number;
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            startedAt: Date | null;
            endedAt: Date | null;
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            autoClosedReason: string | null;
        } & {
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
        };
        meta: {};
    }>;
    list(studentId: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: ({
            linkedPlan: {
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
            } | null;
            studyBreaks: {
                id: string;
                createdAt: Date;
                startedAt: Date;
                endedAt: Date | null;
                breakMinutes: number;
                breakSeconds: number;
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            startedAt: Date | null;
            endedAt: Date | null;
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            autoClosedReason: string | null;
        } & {
            studyMinutes: number;
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
        })[];
        meta: {};
    }>;
    private serializeSession;
    private resolveSessionDurations;
    private notifyStudent;
}
