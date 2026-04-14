import { JwtPayload } from "../auth/types/jwt-payload.type";
import { CreateStudyLogDto } from './dto/create-study-log.dto';
import { UpdateStudyLogDto } from './dto/update-study-log.dto';
import { StudyLogsService } from './study-logs.service';
export declare class StudyLogsController {
    private readonly studyLogsService;
    constructor(studyLogsService: StudyLogsService);
    list(user: JwtPayload, date?: string, startDate?: string, endDate?: string): Promise<{
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
    create(user: JwtPayload, dto: CreateStudyLogDto): Promise<{
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
    update(user: JwtPayload, logId: string, dto: UpdateStudyLogDto): Promise<{
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
    remove(user: JwtPayload, logId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
            logId: string;
        };
        meta: {};
    }>;
}
