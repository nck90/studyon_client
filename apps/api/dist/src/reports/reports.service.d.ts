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
    weekly(studentId: string, startDate?: string): Promise<{
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
    monthly(studentId: string, month?: string): Promise<{
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
