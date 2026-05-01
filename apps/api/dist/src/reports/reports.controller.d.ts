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
            studySeconds: number;
            breakMinutes: number;
            breakSeconds: number;
            targetMinutes: number;
            achievedRate: number;
            attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
            subjectBreakdown: {
                subjectName: string;
                studyMinutes: number;
                studySeconds: number;
            }[];
            logs: {
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
            }[];
        };
        meta: {};
    }>;
    weekly(user: JwtPayload, weekStartDate?: string): Promise<{
        success: boolean;
        data: {
            weekStartDate: string;
            studyMinutes: number;
            studySeconds: number;
            attendanceDays: number;
            targetMinutes: number;
            achievedRate: number;
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
            studySeconds: number;
            attendanceDays: number;
            targetMinutes: number;
            achievedRate: number;
            pagesCompleted: number;
            problemsSolved: number;
        };
        meta: {};
    }>;
}
