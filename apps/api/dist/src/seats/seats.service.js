"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SeatsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const audit_service_1 = require("../audit/audit.service");
const prisma_service_1 = require("../database/prisma.service");
const events_service_1 = require("../events/events.service");
let SeatsService = class SeatsService {
    prisma;
    audit;
    events;
    constructor(prisma, audit, events) {
        this.prisma = prisma;
        this.audit = audit;
        this.events = events;
    }
    async getMySeat(studentId) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
            include: { assignedSeat: true },
        });
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        return { success: true, data: student.assignedSeat, meta: {} };
    }
    async getSeatMap(zone) {
        const seats = await this.prisma.seat.findMany({
            where: { zone: zone ?? undefined, isActive: true },
            orderBy: { seatNo: 'asc' },
        });
        return { success: true, data: seats, meta: {} };
    }
    async getAvailableSeats(zone) {
        const seats = await this.prisma.seat.findMany({
            where: {
                zone: zone ?? undefined,
                isActive: true,
                status: client_1.SeatStatus.AVAILABLE,
            },
            orderBy: { seatNo: 'asc' },
        });
        return { success: true, data: seats, meta: {} };
    }
    async requestSeatChange(studentId, toSeatId, reason) {
        const [seat, student, existingPending] = await Promise.all([
            this.prisma.seat.findUnique({ where: { id: toSeatId } }),
            this.prisma.student.findUnique({
                where: { id: studentId },
            }),
            this.prisma.seatChangeRequest.findFirst({
                where: { studentId, requestStatus: client_1.SeatChangeRequestStatus.PENDING },
            }),
        ]);
        if (!seat ||
            seat.status === client_1.SeatStatus.LOCKED ||
            seat.status === client_1.SeatStatus.OCCUPIED) {
            throw new common_1.BadRequestException('요청할 수 없는 좌석입니다.');
        }
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        if (student.assignedSeatId === toSeatId) {
            throw new common_1.BadRequestException('현재 좌석과 동일한 좌석입니다.');
        }
        if (existingPending) {
            throw new common_1.BadRequestException('검토 중인 좌석 변경 요청이 이미 있습니다.');
        }
        const request = await this.prisma.seatChangeRequest.create({
            data: {
                studentId,
                fromSeatId: student.assignedSeatId ?? undefined,
                toSeatId,
                requestedReason: reason,
            },
        });
        return { success: true, data: request, meta: {} };
    }
    async mySeatChangeRequests(studentId) {
        const items = await this.prisma.seatChangeRequest.findMany({
            where: { studentId },
            include: { fromSeat: true, toSeat: true },
            orderBy: { createdAt: 'desc' },
        });
        return { success: true, data: items, meta: {} };
    }
    async listAdmin(zone, status) {
        const seats = await this.prisma.seat.findMany({
            where: { zone: zone ?? undefined, status: status ?? undefined },
            include: { currentStudent: { include: { user: true } } },
            orderBy: { seatNo: 'asc' },
        });
        return { success: true, data: seats, meta: {} };
    }
    async assign(seatId, studentId, assignmentType, actorUserId) {
        const [seat, student, activeAttendance] = await Promise.all([
            this.prisma.seat.findUnique({ where: { id: seatId } }),
            this.prisma.student.findUnique({ where: { id: studentId } }),
            this.prisma.attendance.findFirst({
                where: {
                    studentId,
                    attendanceDate: new Date(new Date().toISOString().slice(0, 10)),
                    attendanceStatus: 'CHECKED_IN',
                },
            }),
        ]);
        if (!seat) {
            throw new common_1.NotFoundException('좌석을 찾을 수 없습니다.');
        }
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        if (seat.status === client_1.SeatStatus.LOCKED ||
            (seat.currentStudentId && seat.currentStudentId !== studentId)) {
            throw new common_1.BadRequestException('배정할 수 없는 좌석입니다.');
        }
        await this.prisma.$transaction(async (tx) => {
            if (student.assignedSeatId && student.assignedSeatId !== seatId) {
                await tx.seat.update({
                    where: { id: student.assignedSeatId },
                    data: { currentStudentId: null, status: client_1.SeatStatus.AVAILABLE },
                });
            }
            await tx.student.update({
                where: { id: studentId },
                data: { assignedSeatId: seatId },
            });
            await tx.seatAssignment.updateMany({
                where: { studentId, isCurrent: true },
                data: { isCurrent: false, endedAt: new Date() },
            });
            await tx.seatAssignment.create({
                data: { studentId, seatId, assignmentType, isCurrent: true },
            });
            await tx.seat.update({
                where: { id: seatId },
                data: {
                    currentStudentId: activeAttendance ? studentId : null,
                    status: activeAttendance ? client_1.SeatStatus.OCCUPIED : client_1.SeatStatus.RESERVED,
                },
            });
            if (activeAttendance) {
                await tx.attendance.update({
                    where: { id: activeAttendance.id },
                    data: { seatId },
                });
            }
        });
        await this.audit.log({
            actorUserId,
            actionType: 'SEAT_ASSIGNED',
            targetType: 'seat',
            targetId: seatId,
            afterData: { seatId, studentId, assignmentType },
        });
        this.events.emit({
            channel: 'seat',
            event: 'seat.assigned',
            payload: { seatId, studentId, assignmentType },
        });
        this.events.emit({
            channel: 'display',
            event: 'display.refresh',
            payload: { type: 'status' },
        });
        return {
            success: true,
            data: { seatId, studentId, assigned: true },
            meta: {},
        };
    }
    async updateSeat(seatId, status, zone, actorUserId) {
        const before = await this.prisma.seat.findUnique({ where: { id: seatId } });
        const seat = await this.prisma.seat.update({
            where: { id: seatId },
            data: { status: status ?? undefined, zone: zone ?? undefined },
        });
        await this.audit.log({
            actorUserId,
            actionType: 'SEAT_UPDATED',
            targetType: 'seat',
            targetId: seatId,
            beforeData: before,
            afterData: seat,
        });
        this.events.emit({
            channel: 'seat',
            event: 'seat.updated',
            payload: seat,
        });
        return { success: true, data: seat, meta: {} };
    }
    async lock(seatId, locked, actorUserId) {
        const current = await this.prisma.seat.findUnique({
            where: { id: seatId },
            include: { assignedStudents: true },
        });
        if (!current) {
            throw new common_1.NotFoundException('좌석을 찾을 수 없습니다.');
        }
        if (locked && current.status === client_1.SeatStatus.OCCUPIED) {
            throw new common_1.BadRequestException('사용 중인 좌석은 잠글 수 없습니다.');
        }
        const seat = await this.prisma.seat.update({
            where: { id: seatId },
            data: {
                status: locked
                    ? client_1.SeatStatus.LOCKED
                    : current.assignedStudents.length > 0
                        ? client_1.SeatStatus.RESERVED
                        : client_1.SeatStatus.AVAILABLE,
            },
        });
        await this.audit.log({
            actorUserId,
            actionType: locked ? 'SEAT_LOCKED' : 'SEAT_UNLOCKED',
            targetType: 'seat',
            targetId: seatId,
            beforeData: current,
            afterData: seat,
        });
        this.events.emit({
            channel: 'seat',
            event: locked ? 'seat.locked' : 'seat.unlocked',
            payload: seat,
        });
        return { success: true, data: seat, meta: {} };
    }
    async listChangeRequests() {
        const items = await this.prisma.seatChangeRequest.findMany({
            include: {
                student: { include: { user: true } },
                fromSeat: true,
                toSeat: true,
            },
            orderBy: { createdAt: 'desc' },
        });
        return { success: true, data: items, meta: {} };
    }
    async reviewRequest(requestId, approved, reviewedById) {
        const request = await this.prisma.seatChangeRequest.findUnique({
            where: { id: requestId },
        });
        if (!request) {
            throw new common_1.NotFoundException('요청을 찾을 수 없습니다.');
        }
        if (approved) {
            await this.assign(request.toSeatId, request.studentId, client_1.SeatAssignmentType.TEMPORARY);
        }
        const updated = await this.prisma.seatChangeRequest.update({
            where: { id: requestId },
            data: {
                requestStatus: approved
                    ? client_1.SeatChangeRequestStatus.APPROVED
                    : client_1.SeatChangeRequestStatus.REJECTED,
                reviewedById,
                reviewedAt: new Date(),
            },
        });
        await this.audit.log({
            actorUserId: reviewedById,
            actionType: approved ? 'SEAT_CHANGE_APPROVED' : 'SEAT_CHANGE_REJECTED',
            targetType: 'seat_change_request',
            targetId: requestId,
            beforeData: request,
            afterData: updated,
        });
        this.events.emit({
            channel: 'seat',
            event: approved ? 'seat.request_approved' : 'seat.request_rejected',
            payload: updated,
        });
        return { success: true, data: updated, meta: {} };
    }
};
exports.SeatsService = SeatsService;
exports.SeatsService = SeatsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        audit_service_1.AuditService,
        events_service_1.EventsService])
], SeatsService);
//# sourceMappingURL=seats.service.js.map