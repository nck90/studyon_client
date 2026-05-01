import { JwtPayload } from "../auth/types/jwt-payload.type";
import { StudentsService } from './students.service';
export declare class StudentsController {
    private readonly studentsService;
    constructor(studentsService: StudentsService);
    home(user: JwtPayload): Promise<{
        success: boolean;
        data: {
            todayAttendance: {
                status: import("@prisma/client").$Enums.AttendanceStatus;
                checkInAt: string | null;
                checkOutAt: string | null;
                stayMinutes: number;
            };
            seat: {
                seatId: string;
                seatNo: string;
                status: import("@prisma/client").$Enums.SeatStatus;
            } | null;
            study: {
                sessionStatus: import("@prisma/client").$Enums.StudySessionStatus;
                studyMinutes: number;
                breakMinutes: number;
            };
            plans: {
                totalCount: number;
                completedCount: number;
                targetMinutes: number;
            };
            notifications: {
                id: string;
                title: string;
            }[];
            streakDays: number;
            community: {
                checkedInStudentCount: number;
                totalActiveStudents: number;
            };
            student: {
                id: string;
                name: string;
                studentNo: string;
                className: string | null;
            };
        };
        meta: {};
    }>;
    profile(user: JwtPayload): Promise<{
        success: boolean;
        data: {
            preferences: {
                notificationEnabled: boolean;
            };
            profileStats: {
                totalStudySeconds: number;
                totalStudyMinutes: number;
                totalPoints: number;
                level: number;
                completedPlansCount: number;
                badgeCount: number;
                streakDays: number;
            };
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
    badges(user: JwtPayload): Promise<{
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
            studentId: string;
            badgeId: string;
            awardedAt: Date;
            reason: string | null;
        })[];
        meta: {};
    }>;
    preferences(user: JwtPayload): Promise<{
        success: boolean;
        data: {
            notificationEnabled: boolean;
        };
        meta: {};
    }>;
    updatePreferences(user: JwtPayload, body: {
        notificationEnabled?: boolean;
    }): Promise<{
        success: boolean;
        data: {
            notificationEnabled: boolean;
        };
        meta: {};
    }>;
}
