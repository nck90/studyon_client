import { PrismaService } from "../database/prisma.service";
export declare class ReportsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    daily(studentId: string, date?: string): Promise<{
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
    weekly(studentId: string, startDate?: string): Promise<{
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
    monthly(studentId: string, month?: string): Promise<{
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
