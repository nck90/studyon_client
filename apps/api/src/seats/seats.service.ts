import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  SeatAssignmentType,
  SeatChangeRequestStatus,
  SeatStatus,
} from '@prisma/client';
import { AuditService } from '@/audit/audit.service';
import { PrismaService } from '@/database/prisma.service';
import { EventsService } from '@/events/events.service';

@Injectable()
export class SeatsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly events: EventsService,
  ) {}

  async getMySeat(studentId: string) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      include: { assignedSeat: true },
    });
    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }
    return { success: true, data: student.assignedSeat, meta: {} };
  }

  async getSeatMap(zone?: string) {
    const seats = await this.prisma.seat.findMany({
      where: { zone: zone ?? undefined, isActive: true },
      orderBy: { seatNo: 'asc' },
    });
    return { success: true, data: seats, meta: {} };
  }

  async getAvailableSeats(zone?: string) {
    const seats = await this.prisma.seat.findMany({
      where: {
        zone: zone ?? undefined,
        isActive: true,
        status: SeatStatus.AVAILABLE,
      },
      orderBy: { seatNo: 'asc' },
    });
    return { success: true, data: seats, meta: {} };
  }

  async requestSeatChange(
    studentId: string,
    toSeatId: string,
    reason?: string,
  ) {
    const [seat, student, existingPending] = await Promise.all([
      this.prisma.seat.findUnique({ where: { id: toSeatId } }),
      this.prisma.student.findUnique({
        where: { id: studentId },
      }),
      this.prisma.seatChangeRequest.findFirst({
        where: { studentId, requestStatus: SeatChangeRequestStatus.PENDING },
      }),
    ]);

    if (
      !seat ||
      seat.status === SeatStatus.LOCKED ||
      seat.status === SeatStatus.OCCUPIED
    ) {
      throw new BadRequestException('요청할 수 없는 좌석입니다.');
    }

    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }
    if (student.assignedSeatId === toSeatId) {
      throw new BadRequestException('현재 좌석과 동일한 좌석입니다.');
    }
    if (existingPending) {
      throw new BadRequestException(
        '검토 중인 좌석 변경 요청이 이미 있습니다.',
      );
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

  async mySeatChangeRequests(studentId: string) {
    const items = await this.prisma.seatChangeRequest.findMany({
      where: { studentId },
      include: { fromSeat: true, toSeat: true },
      orderBy: { createdAt: 'desc' },
    });
    return { success: true, data: items, meta: {} };
  }

  async listAdmin(zone?: string, status?: SeatStatus) {
    const seats = await this.prisma.seat.findMany({
      where: { zone: zone ?? undefined, status: status ?? undefined },
      include: { currentStudent: { include: { user: true } } },
      orderBy: { seatNo: 'asc' },
    });
    return { success: true, data: seats, meta: {} };
  }

  async assign(
    seatId: string,
    studentId: string,
    assignmentType: SeatAssignmentType,
    actorUserId?: string,
  ) {
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
      throw new NotFoundException('좌석을 찾을 수 없습니다.');
    }
    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }
    if (
      seat.status === SeatStatus.LOCKED ||
      (seat.currentStudentId && seat.currentStudentId !== studentId)
    ) {
      throw new BadRequestException('배정할 수 없는 좌석입니다.');
    }

    await this.prisma.$transaction(async (tx) => {
      if (student.assignedSeatId && student.assignedSeatId !== seatId) {
        await tx.seat.update({
          where: { id: student.assignedSeatId },
          data: { currentStudentId: null, status: SeatStatus.AVAILABLE },
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
          status: activeAttendance ? SeatStatus.OCCUPIED : SeatStatus.RESERVED,
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

  async updateSeat(
    seatId: string,
    status?: SeatStatus,
    zone?: string,
    actorUserId?: string,
  ) {
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

  async lock(seatId: string, locked: boolean, actorUserId?: string) {
    const current = await this.prisma.seat.findUnique({
      where: { id: seatId },
      include: { assignedStudents: true },
    });
    if (!current) {
      throw new NotFoundException('좌석을 찾을 수 없습니다.');
    }
    if (locked && current.status === SeatStatus.OCCUPIED) {
      throw new BadRequestException('사용 중인 좌석은 잠글 수 없습니다.');
    }
    const seat = await this.prisma.seat.update({
      where: { id: seatId },
      data: {
        status: locked
          ? SeatStatus.LOCKED
          : current.assignedStudents.length > 0
            ? SeatStatus.RESERVED
            : SeatStatus.AVAILABLE,
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

  async reviewRequest(
    requestId: string,
    approved: boolean,
    reviewedById?: string,
  ) {
    const request = await this.prisma.seatChangeRequest.findUnique({
      where: { id: requestId },
    });
    if (!request) {
      throw new NotFoundException('요청을 찾을 수 없습니다.');
    }

    if (approved) {
      await this.assign(
        request.toSeatId,
        request.studentId,
        SeatAssignmentType.TEMPORARY,
      );
    }

    const updated = await this.prisma.seatChangeRequest.update({
      where: { id: requestId },
      data: {
        requestStatus: approved
          ? SeatChangeRequestStatus.APPROVED
          : SeatChangeRequestStatus.REJECTED,
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
}
