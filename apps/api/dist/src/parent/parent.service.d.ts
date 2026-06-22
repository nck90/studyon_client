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
    getActionReport(authorization?: string, queryToken?: string): Promise<{
        success: boolean;
        data: {
            report: {
                id: string;
                message: string;
                expiresAt: string;
                viewedAt: string;
                createdAt: string;
            };
            task: {
                id: string;
                taskDate: string;
                reasonType: import("@prisma/client").$Enums.OpsTaskReasonType;
                severity: import("@prisma/client").$Enums.OpsTaskSeverity;
                status: import("@prisma/client").$Enums.OpsTaskStatus;
                message: string;
                sourceSnapshot: import("@prisma/client/runtime/library").JsonValue;
            };
            student: {
                id: string;
                studentNo: string;
                name: string;
                gradeName: string | null;
                className: string | null;
                groupName: string | null;
            };
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
            todayMission: {
                id: string;
                createdAt: Date;
                status: import("@prisma/client").$Enums.DailyMissionStatus;
                updatedAt: Date;
                title: string;
                studentId: string;
                subjectName: string;
                targetMinutes: number;
                completedAt: Date | null;
                source: import("@prisma/client").$Enums.DailyMissionSource;
                missionDate: Date;
                templateId: string | null;
                roadmapMissionId: string | null;
                completionMethod: string | null;
            } | null;
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
            focusSummary: {
                eventCount: number;
                returnCount: number;
                totalAwaySeconds: number;
                longestAwaySeconds: number;
                averageReturnSeconds: number;
                lastEventAt: string | null;
            } | null;
        };
        meta: {};
    }>;
    getConsultationReport(queryToken?: string): Promise<{
        success: boolean;
        data: {
            report: {
                id: string;
                message: string;
                expiresAt: string;
                viewedAt: string;
                createdAt: string;
            };
            student: {
                id: string;
                studentNo: string;
                name: string;
                gradeName: string | null;
                className: string | null;
                groupName: string | null;
            };
            guardian: {
                id: string;
                name: string;
                relation: import("@prisma/client").$Enums.GuardianRelation;
            } | null;
            consultation: {
                id: string;
                contactType: import("@prisma/client").$Enums.ConsultationContactType;
                direction: import("@prisma/client").$Enums.ConsultationDirection;
                occurredAt: string;
                summary: string;
                detail: string | null;
                promisedAction: string | null;
                followUps: {
                    id: string;
                    title: string;
                    dueAt: string;
                    status: import("@prisma/client").$Enums.ParentFollowUpStatus;
                }[];
            };
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
            recentAttendances: {
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
            todayMission: {
                id: string;
                createdAt: Date;
                status: import("@prisma/client").$Enums.DailyMissionStatus;
                updatedAt: Date;
                title: string;
                studentId: string;
                subjectName: string;
                targetMinutes: number;
                completedAt: Date | null;
                source: import("@prisma/client").$Enums.DailyMissionSource;
                missionDate: Date;
                templateId: string | null;
                roadmapMissionId: string | null;
                completionMethod: string | null;
            } | null;
            focusSummary: {
                eventCount: number;
                returnCount: number;
                averageReturnSeconds: number;
                longestAwaySeconds: number;
            } | null;
        };
        meta: {};
    }>;
    private verifyToken;
}
