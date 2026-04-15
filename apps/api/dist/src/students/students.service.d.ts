import { PrismaService } from "../database/prisma.service";
export declare class StudentsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getStudentHome(studentId: string): Promise<{
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
            student: {
                id: string;
                name: string;
                studentNo: string;
                className: string | null;
            };
        };
        meta: {};
    }>;
    getProfile(studentId: string): Promise<{
        success: boolean;
        data: {
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
        };
        meta: {};
    }>;
    getBadges(studentId: string): Promise<{
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
}
