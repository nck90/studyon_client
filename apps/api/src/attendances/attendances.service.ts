import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AttendanceFlag,
  AttendanceStatus,
  NotificationChannel,
  NotificationType,
  SeatStatus,
  StudySessionStatus,
} from '@prisma/client';
import { AuditService } from '@/audit/audit.service';
import { PrismaService } from '@/database/prisma.service';
import { dateOnly, diffMinutes, diffSeconds } from '@/common/utils/date.util';
import { EventsService } from '@/events/events.service';
import { NotificationsService } from '@/notifications/notifications.service';
import { PointsService } from '@/points/points.service';
import { UpdateAttendanceDto } from './dto/update-attendance.dto';

@Injectable()
export class AttendancesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly events: EventsService,
    private readonly notificationsService: NotificationsService,
    private readonly pointsService: PointsService,
  ) {}

  private serializeAttendance(
    attendance: {
      id: string;
      studentId: string;
      attendanceDate: Date;
      attendanceStatus: AttendanceStatus;
      checkInAt: Date | null;
      checkOutAt: Date | null;
      stayMinutes: number;
      lateStatus: AttendanceFlag;
      earlyLeaveStatus: AttendanceFlag;
    } | null,
  ) {
    if (!attendance) return null;

    return {
      id: attendance.id,
      studentId: attendance.studentId,
      attendanceDate: attendance.attendanceDate.toISOString().slice(0, 10),
      status: attendance.attendanceStatus,
      checkInAt: attendance.checkInAt?.toISOString() ?? null,
      checkOutAt: attendance.checkOutAt?.toISOString() ?? null,
      stayMinutes: attendance.stayMinutes,
      isLate: attendance.lateStatus === AttendanceFlag.LATE,
      isEarlyLeave: attendance.earlyLeaveStatus === AttendanceFlag.EARLY_LEAVE,
    };
  }

  async getToday(studentId: string) {
    const attendance = await this.prisma.attendance.findUnique({
      where: {
        studentId_attendanceDate: {
          studentId,
          attendanceDate: dateOnly(),
        },
      },
    });
    const studentUser = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { userId: true },
    });
    this.events.emit({
      channel: 'attendance',
      event: 'student.checked_in',
      payload: attendance,
      userId: studentUser?.userId,
    });
    this.events.emit({
      channel: 'display',
      event: 'display.refresh',
      payload: { type: 'status' },
    });
    return {
      success: true,
      data: this.serializeAttendance(attendance),
      meta: {},
    };
  }

  async listStudentAttendances(
    studentId: string,
    startDate?: string,
    endDate?: string,
  ) {
    const items = await this.prisma.attendance.findMany({
      where: {
        studentId,
        attendanceDate: {
          gte: startDate ? dateOnly(startDate) : undefined,
          lte: endDate ? dateOnly(endDate) : undefined,
        },
      },
      orderBy: { attendanceDate: 'desc' },
    });
    return {
      success: true,
      data: items.map((item) => this.serializeAttendance(item)),
      meta: {},
    };
  }

  async checkIn(studentId: string, seatId?: string) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
    });
    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }

    const today = dateOnly();
    const now = new Date();
    const existing = await this.prisma.attendance.findUnique({
      where: { studentId_attendanceDate: { studentId, attendanceDate: today } },
    });

    if (existing?.attendanceStatus === AttendanceStatus.CHECKED_IN) {
      throw new BadRequestException('이미 입실 처리되었습니다.');
    }

    if (seatId) {
      const seat = await this.prisma.seat.findUnique({ where: { id: seatId } });
      if (!seat || seat.status === SeatStatus.LOCKED) {
        throw new BadRequestException('좌석 상태가 유효하지 않습니다.');
      }
    }

    const lateStatus =
      now.getHours() >= 9 && now.getMinutes() > 0
        ? AttendanceFlag.LATE
        : AttendanceFlag.NONE;

    const attendance = await this.prisma.$transaction(async (tx) => {
      const saved = existing
        ? await tx.attendance.update({
            where: { id: existing.id },
            data: {
              checkInAt: now,
              attendanceStatus: AttendanceStatus.CHECKED_IN,
              seatId,
              lateStatus,
            },
          })
        : await tx.attendance.create({
            data: {
              studentId,
              attendanceDate: today,
              checkInAt: now,
              attendanceStatus: AttendanceStatus.CHECKED_IN,
              seatId,
              lateStatus,
            },
          });

      if (seatId) {
        await tx.seat.update({
          where: { id: seatId },
          data: { currentStudentId: studentId, status: SeatStatus.OCCUPIED },
        });
      }

      return saved;
    });

    await this.notifyStudent(
      studentId,
      '입실 완료',
      seatId
        ? '좌석 배정과 함께 입실 처리되었습니다.'
        : '오늘 입실이 기록되었습니다.',
    );

    // Award attendance points (+50)
    await this.pointsService
      .earn(studentId, 50, 'ATTENDANCE' as never, '출석 보너스')
      .catch(() => {});

    return {
      success: true,
      data: this.serializeAttendance(attendance),
      meta: {},
    };
  }

  async checkOut(studentId: string, forceCloseStudySession = true) {
    const today = dateOnly();
    const attendance = await this.prisma.attendance.findUnique({
      where: { studentId_attendanceDate: { studentId, attendanceDate: today } },
    });

    if (!attendance || !attendance.checkInAt) {
      throw new BadRequestException('입실 기록이 없습니다.');
    }

    const now = new Date();
    const stayMinutes = diffMinutes(attendance.checkInAt, now);
    const earlyLeaveStatus =
      now.getHours() < 22 ? AttendanceFlag.EARLY_LEAVE : AttendanceFlag.NONE;
    const autoClosedSessions: Array<{ id: string; studySeconds: number }> = [];

    const result = await this.prisma.$transaction(async (tx) => {
      if (forceCloseStudySession) {
        const activeSessions = await tx.studySession.findMany({
          where: {
            studentId,
            status: {
              in: [StudySessionStatus.ACTIVE, StudySessionStatus.PAUSED],
            },
          },
          include: { studyBreaks: true },
        });

        for (const session of activeSessions) {
          const openBreak = session.studyBreaks.find((item) => !item.endedAt);
          if (openBreak) {
            const breakSeconds = diffSeconds(openBreak.startedAt, now);
            await tx.studyBreak.update({
              where: { id: openBreak.id },
              data: {
                endedAt: now,
                breakMinutes: Math.floor(breakSeconds / 60),
                breakSeconds,
              },
            });
          }

          const refreshedBreaks = await tx.studyBreak.findMany({
            where: { studySessionId: session.id },
          });
          const totalBreakSeconds = refreshedBreaks.reduce(
            (sum, item) => sum + item.breakSeconds,
            0,
          );
          const totalSeconds = diffSeconds(session.startedAt, now);
          const studySeconds = Math.max(0, totalSeconds - totalBreakSeconds);
          const closedSession = await tx.studySession.update({
            where: { id: session.id },
            data: {
              status: StudySessionStatus.AUTO_CLOSED,
              endedAt: now,
              breakMinutes: Math.floor(totalBreakSeconds / 60),
              breakSeconds: totalBreakSeconds,
              studyMinutes: Math.floor(studySeconds / 60),
              studySeconds,
              autoClosedReason: 'CHECK_OUT',
            },
          });
          autoClosedSessions.push({
            id: closedSession.id,
            studySeconds: closedSession.studySeconds,
          });
        }
      }

      const updated = await tx.attendance.update({
        where: { id: attendance.id },
        data: {
          checkOutAt: now,
          stayMinutes,
          attendanceStatus: AttendanceStatus.CHECKED_OUT,
          earlyLeaveStatus,
        },
      });

      if (attendance.seatId) {
        const reserved = await tx.student.findUnique({
          where: { id: studentId },
          select: { assignedSeatId: true },
        });
        await tx.seat.update({
          where: { id: attendance.seatId },
          data: {
            currentStudentId: null,
            status:
              reserved?.assignedSeatId === attendance.seatId
                ? SeatStatus.RESERVED
                : SeatStatus.AVAILABLE,
          },
        });
      }

      return updated;
    });

    await Promise.all(
      autoClosedSessions.map((session) =>
        this.pointsService.awardStudySessionTime(
          studentId,
          session.id,
          session.studySeconds,
        ),
      ),
    );

    const studentUser = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { userId: true },
    });
    this.events.emit({
      channel: 'attendance',
      event: 'student.checked_out',
      payload: result,
      userId: studentUser?.userId,
    });
    this.events.emit({
      channel: 'display',
      event: 'display.refresh',
      payload: { type: 'status' },
    });
    await this.notifyStudent(
      studentId,
      '퇴실 완료',
      '오늘 출결이 체크아웃 상태로 저장되었습니다.',
      NotificationType.LEAVE_TIME,
    );
    return { success: true, data: this.serializeAttendance(result), meta: {} };
  }

  async listAdmin(
    date?: string,
    startDate?: string,
    endDate?: string,
    classId?: string,
    groupId?: string,
    attendanceStatus?: AttendanceStatus,
  ) {
    const items = await this.prisma.attendance.findMany({
      where: {
        attendanceDate: date
          ? dateOnly(date)
          : {
              gte: startDate ? dateOnly(startDate) : undefined,
              lte: endDate ? dateOnly(endDate) : undefined,
            },
        attendanceStatus,
        student: {
          classId: classId ?? undefined,
          groupId: groupId ?? undefined,
        },
      },
      include: {
        student: { include: { user: true, class: true, group: true } },
        seat: true,
      },
      orderBy: [{ attendanceDate: 'desc' }, { createdAt: 'desc' }],
    });

    return { success: true, data: items, meta: {} };
  }

  async getAdmin(attendanceId: string) {
    const item = await this.prisma.attendance.findUnique({
      where: { id: attendanceId },
      include: { student: { include: { user: true } }, seat: true },
    });
    if (!item) {
      throw new NotFoundException('출결 데이터를 찾을 수 없습니다.');
    }
    return { success: true, data: item, meta: {} };
  }

  async updateAdmin(
    attendanceId: string,
    dto: UpdateAttendanceDto,
    actorUserId?: string,
  ) {
    const attendance = await this.prisma.attendance.findUnique({
      where: { id: attendanceId },
      include: { student: true },
    });
    if (!attendance) {
      throw new NotFoundException('출결 데이터를 찾을 수 없습니다.');
    }

    const nextCheckInAt = dto.checkInAt
      ? new Date(dto.checkInAt)
      : attendance.checkInAt;
    let nextCheckOutAt = dto.checkOutAt
      ? new Date(dto.checkOutAt)
      : attendance.checkOutAt;
    const nextStatus = dto.attendanceStatus ?? attendance.attendanceStatus;

    if (
      nextCheckInAt &&
      nextCheckOutAt &&
      nextCheckOutAt.getTime() < nextCheckInAt.getTime()
    ) {
      throw new BadRequestException(
        '퇴실 시간은 입실 시간보다 빠를 수 없습니다.',
      );
    }

    if (
      nextStatus === AttendanceStatus.CHECKED_OUT &&
      nextCheckInAt &&
      !nextCheckOutAt
    ) {
      nextCheckOutAt = new Date();
    }

    const stayMinutes =
      nextCheckInAt && nextCheckOutAt
        ? diffMinutes(nextCheckInAt, nextCheckOutAt)
        : 0;
    const nextSeatId =
      dto.seatId !== undefined ? dto.seatId || null : attendance.seatId;

    const updated = await this.prisma.$transaction(async (tx) => {
      if (attendance.seatId && attendance.seatId !== nextSeatId) {
        await tx.seat.update({
          where: { id: attendance.seatId },
          data: {
            currentStudentId: null,
            status:
              attendance.student.assignedSeatId === attendance.seatId
                ? SeatStatus.RESERVED
                : SeatStatus.AVAILABLE,
          },
        });
      }

      if (nextSeatId) {
        const targetSeat = await tx.seat.findUnique({
          where: { id: nextSeatId },
        });
        if (!targetSeat || targetSeat.status === SeatStatus.LOCKED) {
          throw new BadRequestException('유효하지 않은 좌석입니다.');
        }

        await tx.seat.update({
          where: { id: nextSeatId },
          data: {
            currentStudentId:
              nextStatus === AttendanceStatus.CHECKED_IN
                ? attendance.studentId
                : null,
            status:
              nextStatus === AttendanceStatus.CHECKED_IN
                ? SeatStatus.OCCUPIED
                : attendance.student.assignedSeatId === nextSeatId
                  ? SeatStatus.RESERVED
                  : SeatStatus.AVAILABLE,
          },
        });
      }

      return tx.attendance.update({
        where: { id: attendanceId },
        data: {
          attendanceStatus: nextStatus,
          checkInAt: nextCheckInAt,
          checkOutAt: nextCheckOutAt,
          stayMinutes,
          seatId: nextSeatId,
          lateStatus: dto.lateStatus ?? attendance.lateStatus,
          earlyLeaveStatus: dto.earlyLeaveStatus ?? attendance.earlyLeaveStatus,
        },
        include: { student: { include: { user: true } }, seat: true },
      });
    });

    await this.audit.log({
      actorUserId,
      actionType: 'ATTENDANCE_UPDATED',
      targetType: 'attendance',
      targetId: attendanceId,
      beforeData: attendance,
      afterData: updated,
    });
    this.events.emit({
      channel: 'attendance',
      event: 'attendance.updated',
      payload: updated,
    });
    this.events.emit({
      channel: 'display',
      event: 'display.refresh',
      payload: { type: 'status' },
    });
    return { success: true, data: updated, meta: {} };
  }

  async stats(startDate?: string, endDate?: string, classId?: string) {
    const items = await this.prisma.attendance.findMany({
      where: {
        attendanceDate: {
          gte: startDate ? dateOnly(startDate) : undefined,
          lte: endDate ? dateOnly(endDate) : undefined,
        },
        student: { classId: classId ?? undefined },
      },
    });

    const total = items.length;
    const checkedIn = items.filter(
      (item) => item.attendanceStatus !== AttendanceStatus.ABSENT,
    ).length;
    const late = items.filter(
      (item) => item.lateStatus === AttendanceFlag.LATE,
    ).length;
    const earlyLeave = items.filter(
      (item) => item.earlyLeaveStatus === AttendanceFlag.EARLY_LEAVE,
    ).length;

    return {
      success: true,
      data: {
        total,
        checkedIn,
        attendanceRate:
          total === 0 ? 0 : Number(((checkedIn / total) * 100).toFixed(2)),
        late,
        earlyLeave,
      },
      meta: {},
    };
  }

  private async notifyStudent(
    studentId: string,
    title: string,
    body: string,
    notificationType: NotificationType = NotificationType.NOTICE,
  ) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { userId: true },
    });
    if (!student?.userId) {
      return;
    }
    await this.notificationsService.sendDirectToUsers({
      userIds: [student.userId],
      notificationType,
      channel: NotificationChannel.IN_APP,
      title,
      body,
    });
  }
}
