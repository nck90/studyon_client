import { SeatAssignmentType, SeatStatus } from '@prisma/client';
import { AuditService } from "../audit/audit.service";
import { PrismaService } from "../database/prisma.service";
import { EventsService } from "../events/events.service";
export declare class SeatsService {
    private readonly prisma;
    private readonly audit;
    private readonly events;
    constructor(prisma: PrismaService, audit: AuditService, events: EventsService);
    private serializeSeat;
    getMySeat(studentId: string): Promise<{
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
    getSeatMap(zone?: string): Promise<{
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
    getAvailableSeats(zone?: string): Promise<{
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
    requestSeatChange(studentId: string, toSeatId: string, reason?: string): Promise<{
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
    mySeatChangeRequests(studentId: string): Promise<{
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
    listAdmin(zone?: string, status?: SeatStatus): Promise<{
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
    createSeat(seatNo: string, zone?: string, actorUserId?: string): Promise<{
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
    deleteSeat(seatId: string, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
        };
        meta: {};
    }>;
    assign(seatId: string, studentId: string, assignmentType: SeatAssignmentType, actorUserId?: string): Promise<{
        success: boolean;
        data: {
            seatId: string;
            studentId: string;
            assigned: boolean;
        };
        meta: {};
    }>;
    updateSeat(seatId: string, status?: SeatStatus, zone?: string, actorUserId?: string): Promise<{
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
    lock(seatId: string, locked: boolean, actorUserId?: string): Promise<{
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
    listChangeRequests(): Promise<{
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
    reviewRequest(requestId: string, approved: boolean, reviewedById?: string): Promise<{
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
