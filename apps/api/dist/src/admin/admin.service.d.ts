import { BadgeRuleMetric, ConsultationContactType, ConsultationDirection, FocusPolicyMode, GuardianRelation, ParentFollowUpStatus, Prisma } from '@prisma/client';
import { AuditService } from "../audit/audit.service";
import { PrismaService } from "../database/prisma.service";
import { NotificationsService } from "../notifications/notifications.service";
export declare class AdminService {
    private readonly prisma;
    private readonly audit;
    private readonly notifications;
    constructor(prisma: PrismaService, audit: AuditService, notifications: NotificationsService);
    dashboard(date?: string, classId?: string, groupId?: string): Promise<{
        success: boolean;
        data: {
            checkedInCount: number;
            seatOccupancyRate: number;
            availableSeatCount: number;
            notCheckedInStudents: number;
            notStartedStudyStudents: number;
            inactiveStudents: number;
        };
        meta: {};
    }>;
    listStudents(filters: {
        keyword?: string;
        gradeId?: string;
        classId?: string;
        groupId?: string;
        status?: string;
    }): Promise<{
        success: boolean;
        data: ({
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
        })[];
        meta: {};
    }>;
    getStudent(studentId: string): Promise<{
        success: boolean;
        data: ({
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
            attendances: {
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
            studyPlans: {
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
            studyLogs: {
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
                progressPercent: Prisma.Decimal;
                isCompleted: boolean;
            }[];
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
        meta: {};
    }>;
    createStudent(input: {
        actorUserId?: string;
        studentNo: string;
        name: string;
        gradeId?: string;
        classId?: string;
        groupId?: string;
        assignedSeatId?: string;
    }): Promise<{
        success: boolean;
        data: {
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
        };
        meta: {};
    }>;
    updateStudent(studentId: string, body: Record<string, unknown>, actorUserId?: string): Promise<{
        success: boolean;
        data: {
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
        };
        meta: {};
    }>;
    deleteStudent(studentId: string, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
        };
        meta: {};
    }>;
    getStudyOverview(startDate?: string, endDate?: string, classId?: string, groupId?: string): Promise<{
        success: boolean;
        data: ({
            student: {
                class: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                    gradeId: string | null;
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
            };
        } & {
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
            achievedRate: Prisma.Decimal;
            pagesCompleted: number;
            problemsSolved: number;
            studySessionCount: number;
            streakDays: number;
        })[];
        meta: {};
    }>;
    getStudyOverviewSubjects(startDate?: string, endDate?: string, classId?: string, groupId?: string): Promise<{
        success: boolean;
        data: {
            subjectName: string;
            studyMinutes: number;
        }[];
        meta: {};
    }>;
    studentStudySummary(studentId: string): Promise<{
        success: boolean;
        data: {
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
            achievedRate: Prisma.Decimal;
            pagesCompleted: number;
            problemsSolved: number;
            studySessionCount: number;
            streakDays: number;
        }[];
        meta: {};
    }>;
    classStudySummary(classId: string): Promise<{
        success: boolean;
        data: ({
            student: {
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
            };
        } & {
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
            achievedRate: Prisma.Decimal;
            pagesCompleted: number;
            problemsSolved: number;
            studySessionCount: number;
            streakDays: number;
        })[];
        meta: {};
    }>;
    grades(): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
        }[];
        meta: {};
    }>;
    createGrade(name: string, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
        };
        meta: {};
    }>;
    classes(): Promise<{
        success: boolean;
        data: ({
            grade: {
                id: string;
                name: string;
                sortOrder: number;
                createdAt: Date;
            } | null;
        } & {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
            gradeId: string | null;
        })[];
        meta: {};
    }>;
    createClass(name: string, gradeId?: string, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
            gradeId: string | null;
        };
        meta: {};
    }>;
    groups(): Promise<{
        success: boolean;
        data: ({
            class: {
                id: string;
                name: string;
                sortOrder: number;
                createdAt: Date;
                gradeId: string | null;
            } | null;
        } & {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
            classId: string | null;
        })[];
        meta: {};
    }>;
    createGroup(name: string, classId?: string, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            sortOrder: number;
            createdAt: Date;
            classId: string | null;
        };
        meta: {};
    }>;
    auditLogs(actionType?: string, targetType?: string): Promise<{
        success: boolean;
        data: ({
            actor: {
                id: string;
                name: string;
                createdAt: Date;
                status: import("@prisma/client").$Enums.UserStatus;
                updatedAt: Date;
                role: import("@prisma/client").$Enums.UserRole;
                phone: string | null;
                lastLoginAt: Date | null;
            };
        } & {
            id: string;
            createdAt: Date;
            actionType: string;
            targetType: string;
            targetId: string | null;
            beforeData: Prisma.JsonValue | null;
            afterData: Prisma.JsonValue | null;
            actorUserId: string;
        })[];
        meta: {};
    }>;
    directorOverview(startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: {
            attendanceRate: number;
            seatUtilizationRate: number;
            totalStudyMinutes: number;
            activeStudentCount: number;
        };
        meta: {};
    }>;
    operationsReport(periodType: string, periodKey?: string): Promise<{
        success: boolean;
        data: {
            periodType: string;
            periodKey: string;
            generatedAt: string;
            attendanceRate: number;
            seatUtilizationRate: number;
            totalStudyMinutes: number;
            avgDailyStudyMinutes: number;
            topClasses: {
                classId: string;
                className: string;
                totalStudyMinutes: number;
                achievedRate: number;
            }[];
        };
        meta: {};
    }>;
    performanceAnalytics(startDate?: string, endDate?: string, classId?: string): Promise<{
        success: boolean;
        data: ({
            student: {
                class: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                    gradeId: string | null;
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
            };
        } & {
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
            achievedRate: Prisma.Decimal;
            pagesCompleted: number;
            problemsSolved: number;
            studySessionCount: number;
            streakDays: number;
        })[];
        meta: {};
    }>;
    private getOperationsReport;
    getBadgeRules(): Promise<{
        success: boolean;
        data: ({
            badge: {
                id: string;
                name: string;
                createdAt: Date;
                isActive: boolean;
                code: string;
                description: string | null;
                badgeType: import("@prisma/client").$Enums.BadgeType;
                iconUrl: string | null;
            };
        } & {
            id: string;
            createdAt: Date;
            isActive: boolean;
            updatedAt: Date;
            badgeId: string;
            metric: import("@prisma/client").$Enums.BadgeRuleMetric;
            threshold: number;
            windowDays: number | null;
        })[];
        meta: {};
    }>;
    updateBadgeRules(rules: {
        id?: string;
        badgeId: string;
        metric: BadgeRuleMetric;
        threshold: number;
        windowDays?: number | null;
        isActive?: boolean;
    }[]): Promise<{
        success: boolean;
        data: ({
            badge: {
                id: string;
                name: string;
                createdAt: Date;
                isActive: boolean;
                code: string;
                description: string | null;
                badgeType: import("@prisma/client").$Enums.BadgeType;
                iconUrl: string | null;
            };
        } & {
            id: string;
            createdAt: Date;
            isActive: boolean;
            updatedAt: Date;
            badgeId: string;
            metric: import("@prisma/client").$Enums.BadgeRuleMetric;
            threshold: number;
            windowDays: number | null;
        })[];
        meta: {};
    }>;
    getFocusPolicy(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            policyName: string;
            mode: import("@prisma/client").$Enums.FocusPolicyMode;
            isEnabled: boolean;
            blockedPackages: Prisma.JsonValue;
            allowedPackages: Prisma.JsonValue;
            graceSeconds: number;
            opsQueueThreshold: number;
            parentReportThreshold: number;
        };
        meta: {};
    }>;
    updateFocusPolicy(input: {
        policyName?: string;
        mode?: FocusPolicyMode;
        isEnabled?: boolean;
        blockedPackages?: string[];
        allowedPackages?: string[];
        graceSeconds?: number;
        opsQueueThreshold?: number;
        parentReportThreshold?: number;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            policyName: string;
            mode: import("@prisma/client").$Enums.FocusPolicyMode;
            isEnabled: boolean;
            blockedPackages: Prisma.JsonValue;
            allowedPackages: Prisma.JsonValue;
            graceSeconds: number;
            opsQueueThreshold: number;
            parentReportThreshold: number;
        };
        meta: {};
    }>;
    focusOverview(date?: string): Promise<{
        success: boolean;
        data: {
            metricDate: string;
            totalStudyingCount: number;
            exitStudentCount: number;
            highRiskStudentCount: number;
            eventCount: number;
            protectionRate: number;
            averageReturnSeconds: number;
            policy: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                policyName: string;
                mode: import("@prisma/client").$Enums.FocusPolicyMode;
                isEnabled: boolean;
                blockedPackages: Prisma.JsonValue;
                allowedPackages: Prisma.JsonValue;
                graceSeconds: number;
                opsQueueThreshold: number;
                parentReportThreshold: number;
            };
        };
        meta: {};
    }>;
    focusStudents(filters: {
        date?: string;
        classId?: string;
        status?: string;
    }): Promise<{
        success: boolean;
        data: {
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            status: string;
            activeSessionId: string;
            eventCount: number;
            returnCount: number;
            totalAwaySeconds: number;
            longestAwaySeconds: number;
            averageReturnSeconds: number;
            lastEventAt: string | null;
        }[];
        meta: {};
    }>;
    focusEvents(filters: {
        date?: string;
        studentId?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            className: string | null;
            eventType: import("@prisma/client").$Enums.FocusEventType;
            occurredAt: string;
            durationSeconds: number | null;
            studySessionId: string | null;
        }[];
        meta: {};
    }>;
    retentionOverview(): Promise<{
        success: boolean;
        data: {
            weeklyActiveStudents: number;
            planAchievedRate: number;
            focusEventCount: number;
            pendingGoalApprovalCount: number;
            openInterventionCount: number;
            focusRiskStudents: {
                studentId: string;
                studentName: string;
                className: string | null;
                eventCount: number;
                lastEventAt: string | null;
            }[];
        };
        meta: {};
    }>;
    opsOverview(date?: string): Promise<{
        success: boolean;
        data: {
            taskDate: string;
            totalCount: number;
            openCount: number;
            resolvedCount: number;
            dismissedCount: number;
            highSeverityOpenCount: number;
            parentReportCount: number;
            completionRate: number;
        };
        meta: {};
    }>;
    generateOpsTasks(): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            taskDate: string;
            reasonType: import("@prisma/client").$Enums.OpsTaskReasonType;
            severity: import("@prisma/client").$Enums.OpsTaskSeverity;
            status: import("@prisma/client").$Enums.OpsTaskStatus;
            message: string;
            sourceSnapshot: Prisma.JsonValue;
            resolvedAt: string | null;
            createdAt: string;
            updatedAt: string;
            actions: {
                id: string;
                actionType: import("@prisma/client").$Enums.OpsTaskActionType;
                actorName: string | null;
                payload: Prisma.JsonValue;
                createdAt: string;
            }[];
            parentReports: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                viewedAt: string | null;
                createdAt: string;
            }[];
        }[];
        meta: {};
    }>;
    opsTasks(filters: {
        date?: string;
        status?: string;
        reasonType?: string;
        severity?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            taskDate: string;
            reasonType: import("@prisma/client").$Enums.OpsTaskReasonType;
            severity: import("@prisma/client").$Enums.OpsTaskSeverity;
            status: import("@prisma/client").$Enums.OpsTaskStatus;
            message: string;
            sourceSnapshot: Prisma.JsonValue;
            resolvedAt: string | null;
            createdAt: string;
            updatedAt: string;
            actions: {
                id: string;
                actionType: import("@prisma/client").$Enums.OpsTaskActionType;
                actorName: string | null;
                payload: Prisma.JsonValue;
                createdAt: string;
            }[];
            parentReports: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                viewedAt: string | null;
                createdAt: string;
            }[];
        }[];
        meta: {};
    }>;
    sendOpsStudentMessage(taskId: string, actorUserId: string, message?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            taskDate: string;
            reasonType: import("@prisma/client").$Enums.OpsTaskReasonType;
            severity: import("@prisma/client").$Enums.OpsTaskSeverity;
            status: import("@prisma/client").$Enums.OpsTaskStatus;
            message: string;
            sourceSnapshot: Prisma.JsonValue;
            resolvedAt: string | null;
            createdAt: string;
            updatedAt: string;
            actions: {
                id: string;
                actionType: import("@prisma/client").$Enums.OpsTaskActionType;
                actorName: string | null;
                payload: Prisma.JsonValue;
                createdAt: string;
            }[];
            parentReports: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                viewedAt: string | null;
                createdAt: string;
            }[];
        } | null;
        meta: {};
    }>;
    createOpsParentReport(taskId: string, actorUserId: string, message?: string): Promise<{
        success: boolean;
        data: {
            report: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                createdAt: string;
            };
            urlPath: string;
        };
        meta: {};
    }>;
    resolveOpsTask(taskId: string, actorUserId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            taskDate: string;
            reasonType: import("@prisma/client").$Enums.OpsTaskReasonType;
            severity: import("@prisma/client").$Enums.OpsTaskSeverity;
            status: import("@prisma/client").$Enums.OpsTaskStatus;
            message: string;
            sourceSnapshot: Prisma.JsonValue;
            resolvedAt: string | null;
            createdAt: string;
            updatedAt: string;
            actions: {
                id: string;
                actionType: import("@prisma/client").$Enums.OpsTaskActionType;
                actorName: string | null;
                payload: Prisma.JsonValue;
                createdAt: string;
            }[];
            parentReports: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                viewedAt: string | null;
                createdAt: string;
            }[];
        } | null;
        meta: {};
    }>;
    dismissOpsTask(taskId: string, actorUserId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            taskDate: string;
            reasonType: import("@prisma/client").$Enums.OpsTaskReasonType;
            severity: import("@prisma/client").$Enums.OpsTaskSeverity;
            status: import("@prisma/client").$Enums.OpsTaskStatus;
            message: string;
            sourceSnapshot: Prisma.JsonValue;
            resolvedAt: string | null;
            createdAt: string;
            updatedAt: string;
            actions: {
                id: string;
                actionType: import("@prisma/client").$Enums.OpsTaskActionType;
                actorName: string | null;
                payload: Prisma.JsonValue;
                createdAt: string;
            }[];
            parentReports: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                viewedAt: string | null;
                createdAt: string;
            }[];
        } | null;
        meta: {};
    }>;
    parentCrmOverview(): Promise<{
        success: boolean;
        data: {
            openFollowUpCount: number;
            overdueFollowUpCount: number;
            todayFollowUpCount: number;
            guardianCount: number;
            recentConsultations: {
                id: string;
                studentId: string;
                studentName: string;
                studentNo: string;
                className: string | null;
                gradeName: string | null;
                guardianId: string | null;
                guardianName: string | null;
                guardianRelation: import("@prisma/client").$Enums.GuardianRelation | null;
                createdByName: string | null;
                contactType: import("@prisma/client").$Enums.ConsultationContactType;
                direction: import("@prisma/client").$Enums.ConsultationDirection;
                occurredAt: string;
                summary: string;
                detail: string | null;
                promisedAction: string | null;
                createdAt: string;
                followUps: {
                    id: string;
                    title: string;
                    dueAt: string;
                    status: import("@prisma/client").$Enums.ParentFollowUpStatus;
                }[];
                latestReport: {
                    id: string;
                    expiresAt: string;
                    viewedAt: string | null;
                } | null;
            }[];
        };
        meta: {};
    }>;
    parentGuardians(filters: {
        studentId?: string;
        keyword?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            name: string;
            relation: import("@prisma/client").$Enums.GuardianRelation;
            phone: string | null;
            email: string | null;
            isPrimary: boolean;
            memo: string | null;
            createdAt: string;
            updatedAt: string;
        }[];
        meta: {};
    }>;
    createParentGuardian(input: {
        studentId?: string;
        name?: string;
        relation?: GuardianRelation;
        phone?: string | null;
        email?: string | null;
        isPrimary?: boolean;
        memo?: string | null;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            name: string;
            relation: import("@prisma/client").$Enums.GuardianRelation;
            phone: string | null;
            email: string | null;
            isPrimary: boolean;
            memo: string | null;
            createdAt: string;
            updatedAt: string;
        };
        meta: {};
    }>;
    updateParentGuardian(guardianId: string, input: {
        name?: string;
        relation?: GuardianRelation;
        phone?: string | null;
        email?: string | null;
        isPrimary?: boolean;
        memo?: string | null;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            name: string;
            relation: import("@prisma/client").$Enums.GuardianRelation;
            phone: string | null;
            email: string | null;
            isPrimary: boolean;
            memo: string | null;
            createdAt: string;
            updatedAt: string;
        };
        meta: {};
    }>;
    parentConsultations(filters: {
        studentId?: string;
        guardianId?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            guardianId: string | null;
            guardianName: string | null;
            guardianRelation: import("@prisma/client").$Enums.GuardianRelation | null;
            createdByName: string | null;
            contactType: import("@prisma/client").$Enums.ConsultationContactType;
            direction: import("@prisma/client").$Enums.ConsultationDirection;
            occurredAt: string;
            summary: string;
            detail: string | null;
            promisedAction: string | null;
            createdAt: string;
            followUps: {
                id: string;
                title: string;
                dueAt: string;
                status: import("@prisma/client").$Enums.ParentFollowUpStatus;
            }[];
            latestReport: {
                id: string;
                expiresAt: string;
                viewedAt: string | null;
            } | null;
        }[];
        meta: {};
    }>;
    createParentConsultation(actorUserId: string, input: {
        studentId?: string;
        guardianId?: string | null;
        contactType?: ConsultationContactType;
        direction?: ConsultationDirection;
        occurredAt?: string;
        summary?: string;
        detail?: string | null;
        promisedAction?: string | null;
        nextFollowUpAt?: string | null;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            guardianId: string | null;
            guardianName: string | null;
            guardianRelation: import("@prisma/client").$Enums.GuardianRelation | null;
            createdByName: string | null;
            contactType: import("@prisma/client").$Enums.ConsultationContactType;
            direction: import("@prisma/client").$Enums.ConsultationDirection;
            occurredAt: string;
            summary: string;
            detail: string | null;
            promisedAction: string | null;
            createdAt: string;
            followUps: {
                id: string;
                title: string;
                dueAt: string;
                status: import("@prisma/client").$Enums.ParentFollowUpStatus;
            }[];
            latestReport: {
                id: string;
                expiresAt: string;
                viewedAt: string | null;
            } | null;
        };
        meta: {};
    }>;
    parentFollowUps(filters: {
        status?: ParentFollowUpStatus;
        studentId?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            guardianId: string | null;
            guardianName: string | null;
            consultationId: string | null;
            sourceOpsTaskId: string | null;
            assignedToName: string | null;
            title: string;
            dueAt: string;
            status: import("@prisma/client").$Enums.ParentFollowUpStatus;
            completedAt: string | null;
            createdAt: string;
        }[];
        meta: {};
    }>;
    createParentFollowUp(input: {
        studentId?: string;
        guardianId?: string | null;
        consultationId?: string | null;
        sourceOpsTaskId?: string | null;
        title?: string;
        dueAt?: string;
        assignedToId?: string | null;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            guardianId: string | null;
            guardianName: string | null;
            consultationId: string | null;
            sourceOpsTaskId: string | null;
            assignedToName: string | null;
            title: string;
            dueAt: string;
            status: import("@prisma/client").$Enums.ParentFollowUpStatus;
            completedAt: string | null;
            createdAt: string;
        };
        meta: {};
    }>;
    updateParentFollowUp(followUpId: string, input: {
        status?: ParentFollowUpStatus;
        dueAt?: string;
        title?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            guardianId: string | null;
            guardianName: string | null;
            consultationId: string | null;
            sourceOpsTaskId: string | null;
            assignedToName: string | null;
            title: string;
            dueAt: string;
            status: import("@prisma/client").$Enums.ParentFollowUpStatus;
            completedAt: string | null;
            createdAt: string;
        };
        meta: {};
    }>;
    createParentConsultationReport(consultationId: string, message?: string, expiresInDays?: number): Promise<{
        success: boolean;
        data: {
            report: {
                id: string;
                tokenId: string;
                message: string;
                expiresAt: string;
                createdAt: string;
            };
            urlPath: string;
        };
        meta: {};
    }>;
    createOpsParentFollowUp(taskId: string, input: {
        title?: string;
        dueAt?: string;
        guardianId?: string | null;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            studentNo: string;
            className: string | null;
            gradeName: string | null;
            guardianId: string | null;
            guardianName: string | null;
            consultationId: string | null;
            sourceOpsTaskId: string | null;
            assignedToName: string | null;
            title: string;
            dueAt: string;
            status: import("@prisma/client").$Enums.ParentFollowUpStatus;
            completedAt: string | null;
            createdAt: string;
        };
        meta: {};
    }>;
    retentionGoals(): Promise<{
        success: boolean;
        data: {
            studentId: string;
            studentName: string;
            className: string | null;
            gradeName: string | null;
            targetUniversityName: unknown;
            tvGoalConsent: boolean;
            tvGoalApprovalStatus: string;
            tvGoalReviewedAt: string | null;
            tvGoalReviewMemo: string | null;
            targetUniversityMedia: {
                id: string;
                createdAt: Date;
                studentId: string;
                kind: import("@prisma/client").$Enums.MediaAssetKind;
                originalName: string;
                mimeType: string;
                byteSize: number;
                storageKey: string;
                publicUrl: string;
            } | null;
        }[];
        meta: {};
    }>;
    retentionInterventions(): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            className: string | null;
            reasonType: import("@prisma/client").$Enums.InterventionReasonType;
            reasonDate: string;
            severity: import("@prisma/client").$Enums.InterventionSeverity;
            message: string;
            createdAt: string;
            roadmap: {
                targetName: string;
                targetDate: string;
                reminderEnabled: boolean;
                reminderTime: string;
            } | null;
            currentMission: {
                id: string;
                title: string;
                status: import("@prisma/client").$Enums.RoadmapMissionStatus;
                targetMinutes: number;
            } | null;
        }[];
        meta: {};
    }>;
    generateRetentionInterventions(): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            studentName: string;
            className: string | null;
            reasonType: import("@prisma/client").$Enums.InterventionReasonType;
            reasonDate: string;
            severity: import("@prisma/client").$Enums.InterventionSeverity;
            message: string;
            createdAt: string;
            roadmap: {
                targetName: string;
                targetDate: string;
                reminderEnabled: boolean;
                reminderTime: string;
            } | null;
            currentMission: {
                id: string;
                title: string;
                status: import("@prisma/client").$Enums.RoadmapMissionStatus;
                targetMinutes: number;
            } | null;
        }[];
        meta: {};
    }>;
    messageRetentionIntervention(interventionId: string, actorUserId: string, message?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.InterventionQueueStatus;
            updatedAt: Date;
            actionType: import("@prisma/client").$Enums.InterventionActionType | null;
            message: string;
            studentId: string;
            severity: import("@prisma/client").$Enums.InterventionSeverity;
            reasonType: import("@prisma/client").$Enums.InterventionReasonType;
            resolvedById: string | null;
            resolvedAt: Date | null;
            reasonDate: Date;
        };
        meta: {};
    }>;
    recommendRetentionPlan(interventionId: string, actorUserId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.InterventionQueueStatus;
            updatedAt: Date;
            actionType: import("@prisma/client").$Enums.InterventionActionType | null;
            message: string;
            studentId: string;
            severity: import("@prisma/client").$Enums.InterventionSeverity;
            reasonType: import("@prisma/client").$Enums.InterventionReasonType;
            resolvedById: string | null;
            resolvedAt: Date | null;
            reasonDate: Date;
        };
        meta: {};
    }>;
    retentionMissionTemplates(): Promise<{
        success: boolean;
        data: {
            id: string;
            gradeId: string | null;
            classId: string | null;
            gradeName: string | null;
            className: string | null;
            title: string;
            subjectName: string;
            targetMinutes: number;
            isActive: boolean;
            sortOrder: number;
        }[];
        meta: {};
    }>;
    createRetentionMissionTemplate(actorUserId: string, input: {
        gradeId?: string | null;
        classId?: string | null;
        title?: string;
        subjectName?: string;
        targetMinutes?: number;
        isActive?: boolean;
        sortOrder?: number;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            sortOrder: number;
            createdAt: Date;
            gradeId: string | null;
            classId: string | null;
            isActive: boolean;
            updatedAt: Date;
            createdById: string | null;
            title: string;
            subjectName: string;
            targetMinutes: number;
        };
        meta: {};
    }>;
    updateRetentionMissionTemplate(templateId: string, input: {
        gradeId?: string | null;
        classId?: string | null;
        title?: string;
        subjectName?: string;
        targetMinutes?: number;
        isActive?: boolean;
        sortOrder?: number;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            sortOrder: number;
            createdAt: Date;
            gradeId: string | null;
            classId: string | null;
            isActive: boolean;
            updatedAt: Date;
            createdById: string | null;
            title: string;
            subjectName: string;
            targetMinutes: number;
        };
        meta: {};
    }>;
    retentionDailyMissionOverview(): Promise<{
        success: boolean;
        data: {
            missionDate: string;
            totalAssignedCount: number;
            completedCount: number;
            incompleteCount: number;
            completionRate: number;
            notificationOpenCount: number;
            reminderEnabledStudentCount: number;
            missions: {
                id: string;
                studentId: string;
                studentName: string;
                className: string | null;
                title: string;
                subjectName: string;
                targetMinutes: number;
                status: import("@prisma/client").$Enums.DailyMissionStatus;
                source: import("@prisma/client").$Enums.DailyMissionSource;
                completedAt: string | null;
            }[];
        };
        meta: {};
    }>;
    reviewRetentionGoal(studentId: string, status: 'APPROVED' | 'REJECTED' | 'PENDING', reviewerUserId: string, memo?: string): Promise<{
        success: boolean;
        data: Prisma.JsonValue;
        meta: {};
    }>;
    private opsTaskRow;
    private opsTaskStatus;
    private opsTaskReasonType;
    private opsTaskSeverity;
    private opsTaskInclude;
    private findOpenOpsTask;
    private opsTaskResponse;
    private serializeOpsTask;
    private interventionRow;
    private findOpenIntervention;
    private resolveIntervention;
    private dailyMissionTemplateData;
    private countDailyMissionReminderEnabledStudents;
    private goalPreferenceRows;
    private studentIdFromPreferenceKey;
    private preferenceKey;
    private resolvePeriodRange;
    private ensureFocusPolicy;
    private policyInt;
    private guardianRelation;
    private contactType;
    private consultationDirection;
    private validDate;
    private serializeGuardian;
    private serializeParentConsultation;
    private serializeFollowUp;
}
