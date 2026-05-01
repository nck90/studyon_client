import { SeatStatus } from '@prisma/client';
import { JwtPayload } from "../auth/types/jwt-payload.type";
import { AssignSeatDto } from './dto/assign-seat.dto';
import { SeatChangeRequestDto } from './dto/seat-change-request.dto';
import { SeatsService } from './seats.service';
export declare class SeatsController {
    private readonly seatsService;
    constructor(seatsService: SeatsService);
    mySeat(user: JwtPayload): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            currentStudentId: string | null;
            updatedAt: Date;
        } | null;
        meta: {};
    }>;
    seatMap(zone?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            uiStatus: string;
            currentStudent: {
                id: string;
                name: string;
            } | null;
        }[];
        meta: {};
    }>;
    available(zone?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            uiStatus: string;
            currentStudent: null;
        }[];
        meta: {};
    }>;
    requestChange(user: JwtPayload, dto: SeatChangeRequestDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            toSeatId: string;
            fromSeatId: string | null;
            requestStatus: import("@prisma/client").$Enums.SeatChangeRequestStatus;
            requestedReason: string | null;
            reviewedById: string | null;
            reviewedAt: Date | null;
        };
        meta: {};
    }>;
    myRequests(user: JwtPayload): Promise<{
        success: boolean;
        data: ({
            fromSeat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            } | null;
            toSeat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            toSeatId: string;
            fromSeatId: string | null;
            requestStatus: import("@prisma/client").$Enums.SeatChangeRequestStatus;
            requestedReason: string | null;
            reviewedById: string | null;
            reviewedAt: Date | null;
        })[];
        meta: {};
    }>;
    adminSeats(zone?: string, status?: SeatStatus): Promise<{
        success: boolean;
        data: {
            id: string;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            uiStatus: string;
            currentStudent: {
                id: string;
                name: string;
            } | null;
        }[];
        meta: {};
    }>;
    createSeat(user: JwtPayload, seatNo: string, zone?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            currentStudentId: string | null;
            updatedAt: Date;
        };
        meta: {};
    }>;
    updateSeat(user: JwtPayload, seatId: string, status?: SeatStatus, zone?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            currentStudentId: string | null;
            updatedAt: Date;
        };
        meta: {};
    }>;
    assign(user: JwtPayload, seatId: string, dto: AssignSeatDto): Promise<{
        success: boolean;
        data: {
            seatId: string;
            studentId: string;
            assigned: boolean;
        };
        meta: {};
    }>;
    lock(user: JwtPayload, seatId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            currentStudentId: string | null;
            updatedAt: Date;
        };
        meta: {};
    }>;
    unlock(user: JwtPayload, seatId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            seatNo: string;
            zone: string | null;
            status: import("@prisma/client").$Enums.SeatStatus;
            isActive: boolean;
            currentStudentId: string | null;
            updatedAt: Date;
        };
        meta: {};
    }>;
    deleteSeat(user: JwtPayload, seatId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
        };
        meta: {};
    }>;
    listRequests(): Promise<{
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
            fromSeat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            } | null;
            toSeat: {
                id: string;
                createdAt: Date;
                seatNo: string;
                zone: string | null;
                status: import("@prisma/client").$Enums.SeatStatus;
                isActive: boolean;
                currentStudentId: string | null;
                updatedAt: Date;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            toSeatId: string;
            fromSeatId: string | null;
            requestStatus: import("@prisma/client").$Enums.SeatChangeRequestStatus;
            requestedReason: string | null;
            reviewedById: string | null;
            reviewedAt: Date | null;
        })[];
        meta: {};
    }>;
    approve(user: JwtPayload, requestId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            toSeatId: string;
            fromSeatId: string | null;
            requestStatus: import("@prisma/client").$Enums.SeatChangeRequestStatus;
            requestedReason: string | null;
            reviewedById: string | null;
            reviewedAt: Date | null;
        };
        meta: {};
    }>;
    reject(user: JwtPayload, requestId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            studentId: string;
            toSeatId: string;
            fromSeatId: string | null;
            requestStatus: import("@prisma/client").$Enums.SeatChangeRequestStatus;
            requestedReason: string | null;
            reviewedById: string | null;
            reviewedAt: Date | null;
        };
        meta: {};
    }>;
}
