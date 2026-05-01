import { PrismaService } from "../database/prisma.service";
import { PointsService } from "../points/points.service";
import { CreateStudyLogDto } from './dto/create-study-log.dto';
import { UpdateStudyLogDto } from './dto/update-study-log.dto';
export declare class StudyLogsService {
    private readonly prisma;
    private readonly pointsService;
    constructor(prisma: PrismaService, pointsService: PointsService);
    list(studentId: string, date?: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: ({
            studySession: {
                id: string;
                status: import("@prisma/client").$Enums.StudySessionStatus;
                startedAt: Date | null;
                endedAt: Date | null;
                studyMinutes: number;
                studySeconds: number;
                breakMinutes: number;
                breakSeconds: number;
            } | null;
            plan: {
                id: string;
                title: string;
                targetMinutes: number;
            } | null;
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            memo: string | null;
            studentId: string;
            studyMinutes: number;
            studySeconds: number;
            studySessionId: string | null;
            subjectName: string;
            pagesCompleted: number;
            problemsSolved: number;
            planId: string | null;
            logDate: Date;
            progressPercent: import("@prisma/client/runtime/library").Decimal;
            isCompleted: boolean;
        })[];
        meta: {};
    }>;
    create(studentId: string, dto: CreateStudyLogDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            memo: string | null;
            studentId: string;
            studyMinutes: number;
            studySeconds: number;
            studySessionId: string | null;
            subjectName: string;
            pagesCompleted: number;
            problemsSolved: number;
            planId: string | null;
            logDate: Date;
            progressPercent: import("@prisma/client/runtime/library").Decimal;
            isCompleted: boolean;
        };
        meta: {};
    }>;
    update(studentId: string, logId: string, dto: UpdateStudyLogDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            memo: string | null;
            studentId: string;
            studyMinutes: number;
            studySeconds: number;
            studySessionId: string | null;
            subjectName: string;
            pagesCompleted: number;
            problemsSolved: number;
            planId: string | null;
            logDate: Date;
            progressPercent: import("@prisma/client/runtime/library").Decimal;
            isCompleted: boolean;
        };
        meta: {};
    }>;
    remove(studentId: string, logId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
            logId: string;
        };
        meta: {};
    }>;
    private serializeDecimal;
    private resolveStudyDuration;
}
