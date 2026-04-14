import { PrismaService } from "../database/prisma.service";
export declare class StudySessionsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    active(studentId: string): Promise<{
        success: boolean;
        data: ({
            linkedPlan: {
                id: string;
                createdAt: Date;
                status: import("@prisma/client").$Enums.StudyPlanStatus;
                updatedAt: Date;
                description: string | null;
                studentId: string;
                title: string;
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
                studySessionId: string;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            startedAt: Date | null;
            endedAt: Date | null;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            studyMinutes: number;
            breakMinutes: number;
            autoClosedReason: string | null;
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
                studentId: string;
                title: string;
                planDate: Date;
                subjectName: string;
                targetMinutes: number;
                priority: import("@prisma/client").$Enums.StudyPlanPriority;
                completedAt: Date | null;
            } | null;
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            startedAt: Date | null;
            endedAt: Date | null;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            studyMinutes: number;
            breakMinutes: number;
            autoClosedReason: string | null;
        };
        meta: {};
    }>;
    pause(studentId: string, sessionId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            startedAt: Date | null;
            endedAt: Date | null;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            studyMinutes: number;
            breakMinutes: number;
            autoClosedReason: string | null;
        };
        meta: {};
    }>;
    resume(studentId: string, sessionId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            startedAt: Date | null;
            endedAt: Date | null;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            studyMinutes: number;
            breakMinutes: number;
            autoClosedReason: string | null;
        };
        meta: {};
    }>;
    end(studentId: string, sessionId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            startedAt: Date | null;
            endedAt: Date | null;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            studyMinutes: number;
            breakMinutes: number;
            autoClosedReason: string | null;
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
                studentId: string;
                title: string;
                planDate: Date;
                subjectName: string;
                targetMinutes: number;
                priority: import("@prisma/client").$Enums.StudyPlanPriority;
                completedAt: Date | null;
            } | null;
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudySessionStatus;
            updatedAt: Date;
            studentId: string;
            startedAt: Date | null;
            endedAt: Date | null;
            attendanceId: string | null;
            linkedPlanId: string | null;
            sessionDate: Date;
            studyMinutes: number;
            breakMinutes: number;
            autoClosedReason: string | null;
        })[];
        meta: {};
    }>;
}
