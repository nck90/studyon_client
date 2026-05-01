import { JwtService } from '@nestjs/jwt';
import { AuditService } from "../audit/audit.service";
import { PrismaService } from "../database/prisma.service";
export declare class ParentService {
    private readonly prisma;
    private readonly jwtService;
    private readonly audit;
    constructor(prisma: PrismaService, jwtService: JwtService, audit: AuditService);
    issueAccessToken(actorUserId: string, studentId: string, expiresInDays?: number): Promise<{
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
    getOverview(token?: string): Promise<{
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
                passwordHash: string;
                studentNo: string;
                loginId: string;
                groupId: string | null;
                assignedSeatId: string | null;
                enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                joinedAt: Date | null;
                memo: string | null;
                pointBalance: number;
            }) | null;
            todayAttendance: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                createdById: string | null;
                attendanceDate: Date;
                studentId: string;
                attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
                checkInAt: Date | null;
                checkOutAt: Date | null;
                seatId: string | null;
                lateStatus: import("@prisma/client").$Enums.AttendanceFlag;
                earlyLeaveStatus: import("@prisma/client").$Enums.AttendanceFlag;
                stayMinutes: number;
            } | null;
            todayMetric: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                studentId: string;
                studyMinutes: number;
                breakMinutes: number;
                targetMinutes: number;
                attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
                metricDate: Date;
                attendanceMinutes: number;
                achievedRate: import("@prisma/client/runtime/library").Decimal;
                pagesCompleted: number;
                problemsSolved: number;
                studySessionCount: number;
                streakDays: number;
            } | null;
            todayPlans: {
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
            }[];
        };
        meta: {};
    }>;
    getAttendance(token?: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            createdById: string | null;
            attendanceDate: Date;
            studentId: string;
            attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
            checkInAt: Date | null;
            checkOutAt: Date | null;
            seatId: string | null;
            lateStatus: import("@prisma/client").$Enums.AttendanceFlag;
            earlyLeaveStatus: import("@prisma/client").$Enums.AttendanceFlag;
            stayMinutes: number;
        }[];
        meta: {};
    }>;
    getStudyReport(token?: string, startDate?: string, endDate?: string): Promise<{
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
                studyMinutes: number;
                breakMinutes: number;
                targetMinutes: number;
                attendanceStatus: import("@prisma/client").$Enums.AttendanceStatus;
                metricDate: Date;
                attendanceMinutes: number;
                achievedRate: import("@prisma/client/runtime/library").Decimal;
                pagesCompleted: number;
                problemsSolved: number;
                studySessionCount: number;
                streakDays: number;
            }[];
            recentLogs: {
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
    private verifyToken;
}
