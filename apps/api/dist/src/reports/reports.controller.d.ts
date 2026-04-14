import { JwtPayload } from "../auth/types/jwt-payload.type";
import { ReportsService } from './reports.service';
export declare class ReportsController {
    private readonly reportsService;
    constructor(reportsService: ReportsService);
    daily(user: JwtPayload, date?: string): Promise<{
        success: boolean;
        data: {
            date: string;
            attendanceMinutes: number;
            studyMinutes: number;
            breakMinutes: number;
            targetMinutes: number;
            achievedRate: number;
            attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
            subjectBreakdown: {
                subjectName: string;
                pagesCompleted: number;
            }[];
            logs: {
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
        };
        meta: {};
    }>;
    weekly(user: JwtPayload, weekStartDate?: string): Promise<{
        success: boolean;
        data: {
            weekStartDate: string;
            studyMinutes: number;
            attendanceDays: number;
            targetMinutes: number;
            pagesCompleted: number;
            problemsSolved: number;
        };
        meta: {};
    }>;
    monthly(user: JwtPayload, month?: string): Promise<{
        success: boolean;
        data: {
            month: string;
            studyMinutes: number;
            attendanceDays: number;
            targetMinutes: number;
            pagesCompleted: number;
            problemsSolved: number;
        };
        meta: {};
    }>;
}
