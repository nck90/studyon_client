import { JwtPayload } from "../auth/types/jwt-payload.type";
import { StartStudySessionDto } from './dto/start-study-session.dto';
import { StudySessionsService } from './study-sessions.service';
export declare class StudySessionsController {
    private readonly studySessionsService;
    constructor(studySessionsService: StudySessionsService);
    active(user: JwtPayload): Promise<{
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
    list(user: JwtPayload, startDate?: string, endDate?: string): Promise<{
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
    start(user: JwtPayload, dto: StartStudySessionDto): Promise<{
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
    pause(user: JwtPayload, sessionId: string): Promise<{
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
    resume(user: JwtPayload, sessionId: string): Promise<{
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
    end(user: JwtPayload, sessionId: string): Promise<{
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
}
