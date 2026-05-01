import { JwtPayload } from "../auth/types/jwt-payload.type";
import { AdminService } from './admin.service';
export declare class AdminController {
    private readonly adminService;
    constructor(adminService: AdminService);
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
    students(keyword?: string, gradeId?: string, classId?: string, groupId?: string, status?: string): Promise<{
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
    createStudent(user: JwtPayload, body: Record<string, unknown>): Promise<{
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
    student(studentId: string): Promise<{
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
                progressPercent: import("@prisma/client/runtime/library").Decimal;
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
    patchStudent(user: JwtPayload, studentId: string, body: Record<string, unknown>): Promise<{
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
    deleteStudent(user: JwtPayload, studentId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
        };
        meta: {};
    }>;
    studyOverview(startDate?: string, endDate?: string, classId?: string, groupId?: string): Promise<{
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
            achievedRate: import("@prisma/client/runtime/library").Decimal;
            pagesCompleted: number;
            problemsSolved: number;
            studySessionCount: number;
            streakDays: number;
        })[];
        meta: {};
    }>;
    studyOverviewSubjects(startDate?: string, endDate?: string, classId?: string, groupId?: string): Promise<{
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
            achievedRate: import("@prisma/client/runtime/library").Decimal;
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
            achievedRate: import("@prisma/client/runtime/library").Decimal;
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
    createGrade(user: JwtPayload, name: string): Promise<{
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
    createClass(user: JwtPayload, name: string, gradeId?: string): Promise<{
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
    createGroup(user: JwtPayload, name: string, classId?: string): Promise<{
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
            beforeData: import("@prisma/client/runtime/library").JsonValue | null;
            afterData: import("@prisma/client/runtime/library").JsonValue | null;
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
    operationsReport(periodType?: string, periodKey?: string): Promise<{
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
            achievedRate: import("@prisma/client/runtime/library").Decimal;
            pagesCompleted: number;
            problemsSolved: number;
            studySessionCount: number;
            streakDays: number;
        })[];
        meta: {};
    }>;
}
