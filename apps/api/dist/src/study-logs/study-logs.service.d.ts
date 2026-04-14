import { PrismaService } from "../database/prisma.service";
import { CreateStudyLogDto } from './dto/create-study-log.dto';
import { UpdateStudyLogDto } from './dto/update-study-log.dto';
export declare class StudyLogsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    list(studentId: string, date?: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            memo: string | null;
            studentId: string;
            subjectName: string;
            studySessionId: string | null;
            planId: string | null;
            logDate: Date;
            pagesCompleted: number;
            problemsSolved: number;
            progressPercent: import("@prisma/client/runtime/library").Decimal;
            isCompleted: boolean;
        }[];
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
            subjectName: string;
            studySessionId: string | null;
            planId: string | null;
            logDate: Date;
            pagesCompleted: number;
            problemsSolved: number;
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
            subjectName: string;
            studySessionId: string | null;
            planId: string | null;
            logDate: Date;
            pagesCompleted: number;
            problemsSolved: number;
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
}
