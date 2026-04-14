import { JwtPayload } from "../auth/types/jwt-payload.type";
import { ParentService } from './parent.service';
export declare class ParentController {
    private readonly parentService;
    constructor(parentService: ParentService);
    issue(user: JwtPayload, studentId: string, expiresInDays?: number): Promise<{
        success: boolean;
        data: {
            token: string;
            expiresInDays: number;
            student: {
                id: string;
                studentNo: string;
                name: string;
                className: string | null;
            };
        };
        meta: {};
    }>;
    overview(authorization?: string): Promise<{
        success: boolean;
        data: {
            student: ({
                grade: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                } | null;
                class: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                    gradeId: string | null;
                } | null;
                group: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                    classId: string | null;
                } | null;
                user: {
                    id: string;
                    name: string;
                    createdAt: Date;
                    status: import("@prisma/client").$Enums.UserStatus;
                    updatedAt: Date;
                    role: import("@prisma/client").$Enums.UserRole;
                    phone: string | null;
                    lastLoginAt: Date | null;
                };
                assignedSeat: {
                    id: string;
                    createdAt: Date;
                    seatNo: string;
                    zone: string | null;
                    status: import("@prisma/client").$Enums.SeatStatus;
                    isActive: boolean;
                    currentStudentId: string | null;
                    updatedAt: Date;
                } | null;
            } & {
                id: string;
                createdAt: Date;
                gradeId: string | null;
                classId: string | null;
                updatedAt: Date;
                userId: string;
                studentNo: string;
                groupId: string | null;
                assignedSeatId: string | null;
                enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                joinedAt: Date | null;
                memo: string | null;
            }) | null;
            todayAttendance: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                createdById: string | null;
                studentId: string;
                seatId: string | null;
                attendanceDate: Date;
                checkInAt: Date | null;
                checkOutAt: Date | null;
                stayMinutes: number;
                lateStatus: import("@prisma/client").$Enums.AttendanceFlag;
                earlyLeaveStatus: import("@prisma/client").$Enums.AttendanceFlag;
                attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
            } | null;
            todayMetric: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                studentId: string;
                attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
                studyMinutes: number;
                breakMinutes: number;
                targetMinutes: number;
                pagesCompleted: number;
                problemsSolved: number;
                metricDate: Date;
                attendanceMinutes: number;
                achievedRate: import("@prisma/client/runtime/library").Decimal;
                studySessionCount: number;
                streakDays: number;
            } | null;
            todayPlans: {
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
            }[];
        };
        meta: {};
    }>;
    attendance(authorization?: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            createdById: string | null;
            studentId: string;
            seatId: string | null;
            attendanceDate: Date;
            checkInAt: Date | null;
            checkOutAt: Date | null;
            stayMinutes: number;
            lateStatus: import("@prisma/client").$Enums.AttendanceFlag;
            earlyLeaveStatus: import("@prisma/client").$Enums.AttendanceFlag;
            attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
        }[];
        meta: {};
    }>;
    studyReport(authorization?: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: {
            totalStudyMinutes: number;
            averageAchievedRate: number;
            totalPagesCompleted: number;
            totalProblemsSolved: number;
            recentMetrics: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                studentId: string;
                attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
                studyMinutes: number;
                breakMinutes: number;
                targetMinutes: number;
                pagesCompleted: number;
                problemsSolved: number;
                metricDate: Date;
                attendanceMinutes: number;
                achievedRate: import("@prisma/client/runtime/library").Decimal;
                studySessionCount: number;
                streakDays: number;
            }[];
            recentLogs: {
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
}
