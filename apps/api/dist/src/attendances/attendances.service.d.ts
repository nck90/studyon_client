import { AttendanceStatus } from '@prisma/client';
import { AuditService } from "../audit/audit.service";
import { PrismaService } from "../database/prisma.service";
import { EventsService } from "../events/events.service";
import { UpdateAttendanceDto } from './dto/update-attendance.dto';
export declare class AttendancesService {
    private readonly prisma;
    private readonly audit;
    private readonly events;
    constructor(prisma: PrismaService, audit: AuditService, events: EventsService);
    private serializeAttendance;
    getToday(studentId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            attendanceDate: string;
            status: import("@prisma/client").$Enums.AttendanceStatus;
            checkInAt: string | null;
            checkOutAt: string | null;
            stayMinutes: number;
            isLate: boolean;
            isEarlyLeave: boolean;
        } | null;
        meta: {};
    }>;
    listStudentAttendances(studentId: string, startDate?: string, endDate?: string): Promise<{
        success: boolean;
        data: ({
            id: string;
            studentId: string;
            attendanceDate: string;
            status: import("@prisma/client").$Enums.AttendanceStatus;
            checkInAt: string | null;
            checkOutAt: string | null;
            stayMinutes: number;
            isLate: boolean;
            isEarlyLeave: boolean;
        } | null)[];
        meta: {};
    }>;
    checkIn(studentId: string, seatId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            attendanceDate: string;
            status: import("@prisma/client").$Enums.AttendanceStatus;
            checkInAt: string | null;
            checkOutAt: string | null;
            stayMinutes: number;
            isLate: boolean;
            isEarlyLeave: boolean;
        } | null;
        meta: {};
    }>;
    checkOut(studentId: string, forceCloseStudySession?: boolean): Promise<{
        success: boolean;
        data: {
            id: string;
            studentId: string;
            attendanceDate: string;
            status: import("@prisma/client").$Enums.AttendanceStatus;
            checkInAt: string | null;
            checkOutAt: string | null;
            stayMinutes: number;
            isLate: boolean;
            isEarlyLeave: boolean;
        } | null;
        meta: {};
    }>;
    listAdmin(date?: string, classId?: string, groupId?: string, attendanceStatus?: AttendanceStatus): Promise<{
        success: boolean;
        data: ({
            seat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            } | null;
            student: {
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
        } & {
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
        })[];
        meta: {};
    }>;
    getAdmin(attendanceId: string): Promise<{
        success: boolean;
        data: {
            seat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            } | null;
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
                studentNo: string;
                groupId: string | null;
                assignedSeatId: string | null;
                enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                joinedAt: Date | null;
                memo: string | null;
            };
        } & {
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
        };
        meta: {};
    }>;
    updateAdmin(attendanceId: string, dto: UpdateAttendanceDto, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            seat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            } | null;
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
                studentNo: string;
                groupId: string | null;
                assignedSeatId: string | null;
                enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                joinedAt: Date | null;
                memo: string | null;
            };
        } & {
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
        };
        meta: {};
    }>;
    stats(startDate?: string, endDate?: string, classId?: string): Promise<{
        success: boolean;
        data: {
            total: number;
            checkedIn: number;
            attendanceRate: number;
            late: number;
            earlyLeave: number;
        };
        meta: {};
    }>;
}
