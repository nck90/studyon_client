import { AttendanceStatus } from '@prisma/client';
import { JwtPayload } from "../auth/types/jwt-payload.type";
import { CheckInDto } from './dto/check-in.dto';
import { CheckOutDto } from './dto/check-out.dto';
import { UpdateAttendanceDto } from './dto/update-attendance.dto';
import { AttendancesService } from './attendances.service';
export declare class AttendancesController {
    private readonly attendancesService;
    constructor(attendancesService: AttendancesService);
    getToday(user: JwtPayload): Promise<{
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
    listStudent(user: JwtPayload, startDate?: string, endDate?: string): Promise<{
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
    checkIn(user: JwtPayload, dto: CheckInDto): Promise<{
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
    checkOut(user: JwtPayload, dto: CheckOutDto): Promise<{
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
    listAdmin(date?: string, startDate?: string, endDate?: string, classId?: string, groupId?: string, attendanceStatus?: AttendanceStatus): Promise<{
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
    patch(user: JwtPayload, attendanceId: string, dto: UpdateAttendanceDto): Promise<{
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
        };
        meta: {};
    }>;
}
