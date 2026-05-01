import { BadRequestException, Injectable } from '@nestjs/common';
import {
  NotificationChannel,
  NotificationType,
  StudySessionStatus,
} from '@prisma/client';
import { dateOnly, diffSeconds } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { NotificationsService } from '@/notifications/notifications.service';
import { PointsService } from '@/points/points.service';

@Injectable()
export class StudySessionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
    private readonly pointsService: PointsService,
  ) {}

  active(studentId: string) {
    return this.prisma.studySession
      .findFirst({
        where: {
          studentId,
          status: {
            in: [StudySessionStatus.ACTIVE, StudySessionStatus.PAUSED],
          },
        },
        include: { linkedPlan: true, studyBreaks: true },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({
        success: true,
        data: data ? this.serializeSession(data) : null,
        meta: {},
      }));
  }

  async start(studentId: string, linkedPlanId?: string) {
    const existing = await this.prisma.studySession.findFirst({
      where: {
        studentId,
        status: { in: [StudySessionStatus.ACTIVE, StudySessionStatus.PAUSED] },
      },
    });
    if (existing) {
      throw new BadRequestException('이미 진행 중인 공부 세션이 있습니다.');
    }

    const attendance = await this.prisma.attendance.findUnique({
      where: {
        studentId_attendanceDate: { studentId, attendanceDate: dateOnly() },
      },
    });

    const session = await this.prisma.studySession.create({
      data: {
        studentId,
        attendanceId: attendance?.id,
        linkedPlanId,
        sessionDate: dateOnly(),
        status: StudySessionStatus.ACTIVE,
        startedAt: new Date(),
      },
      include: { linkedPlan: true, studyBreaks: true },
    });

    if (linkedPlanId) {
      await this.prisma.studyPlan.update({
        where: { id: linkedPlanId },
        data: { status: 'IN_PROGRESS' },
      });
    }

    await this.notifyStudent(
      studentId,
      '공부를 시작했어요',
      linkedPlanId
        ? '선택한 계획으로 공부 세션이 시작되었습니다.'
        : '새 공부 세션이 시작되었습니다.',
    );

    return { success: true, data: this.serializeSession(session), meta: {} };
  }

  async pause(studentId: string, sessionId: string) {
    const session = await this.prisma.studySession.findFirst({
      where: { id: sessionId, studentId, status: StudySessionStatus.ACTIVE },
    });
    if (!session) {
      throw new BadRequestException('활성 세션이 아닙니다.');
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.studyBreak.create({
        data: { studySessionId: sessionId, startedAt: new Date() },
      });
      return tx.studySession.update({
        where: { id: sessionId },
        data: { status: StudySessionStatus.PAUSED },
        include: { linkedPlan: true, studyBreaks: true },
      });
    });

    await this.notifyStudent(
      studentId,
      '휴식 시작',
      '공부 세션이 일시정지되고 휴식 시간이 기록됩니다.',
    );

    return { success: true, data: this.serializeSession(updated), meta: {} };
  }

  async resume(studentId: string, sessionId: string) {
    const session = await this.prisma.studySession.findFirst({
      where: { id: sessionId, studentId, status: StudySessionStatus.PAUSED },
      include: { studyBreaks: true },
    });
    if (!session) {
      throw new BadRequestException('일시정지 상태의 세션이 아닙니다.');
    }
    const activeBreak = session.studyBreaks.find((item) => !item.endedAt);
    if (!activeBreak) {
      throw new BadRequestException('활성 휴식 구간이 없습니다.');
    }

    const now = new Date();
    const breakSeconds = diffSeconds(activeBreak.startedAt, now);
    const breakMinutes = Math.floor(breakSeconds / 60);

    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.studyBreak.update({
        where: { id: activeBreak.id },
        data: { endedAt: now, breakMinutes, breakSeconds },
      });

      const breaks = await tx.studyBreak.findMany({
        where: { studySessionId: sessionId },
      });
      const totalBreakSeconds = breaks.reduce(
        (sum, item) => sum + item.breakSeconds,
        0,
      );
      return tx.studySession.update({
        where: { id: sessionId },
        data: {
          status: StudySessionStatus.ACTIVE,
          breakMinutes: Math.floor(totalBreakSeconds / 60),
          breakSeconds: totalBreakSeconds,
        },
        include: { linkedPlan: true, studyBreaks: true },
      });
    });

    await this.notifyStudent(
      studentId,
      '공부 재개',
      '휴식이 종료되고 공부 세션이 다시 시작되었습니다.',
    );

    return { success: true, data: this.serializeSession(updated), meta: {} };
  }

  async end(studentId: string, sessionId: string) {
    const session = await this.prisma.studySession.findFirst({
      where: {
        id: sessionId,
        studentId,
        status: { in: [StudySessionStatus.ACTIVE, StudySessionStatus.PAUSED] },
      },
      include: { studyBreaks: true },
    });
    if (!session || !session.startedAt) {
      throw new BadRequestException('세션을 종료할 수 없습니다.');
    }

    const now = new Date();

    const result = await this.prisma.$transaction(async (tx) => {
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

      const breaks = await tx.studyBreak.findMany({
        where: { studySessionId: sessionId },
      });
      const breakSeconds = breaks.reduce(
        (sum, item) => sum + item.breakSeconds,
        0,
      );
      const totalSeconds = diffSeconds(session.startedAt, now);
      const studySeconds = Math.max(0, totalSeconds - breakSeconds);
      const studyMinutes = Math.floor(studySeconds / 60);
      const breakMinutes = Math.floor(breakSeconds / 60);

      const updated = await tx.studySession.update({
        where: { id: sessionId },
        data: {
          status: StudySessionStatus.COMPLETED,
          endedAt: now,
          breakMinutes,
          breakSeconds,
          studyMinutes,
          studySeconds,
        },
        include: { linkedPlan: true, studyBreaks: true },
      });

      return updated;
    });

    await this.pointsService.awardStudySessionTime(
      studentId,
      result.id,
      result.studySeconds,
    );

    await this.notifyStudent(
      studentId,
      '공부 세션 완료',
      `이번 세션에서 ${result.studyMinutes}분 공부를 기록했어요.`,
    );

    return { success: true, data: this.serializeSession(result), meta: {} };
  }

  list(studentId: string, startDate?: string, endDate?: string) {
    return this.prisma.studySession
      .findMany({
        where: {
          studentId,
          sessionDate: {
            gte: startDate ? dateOnly(startDate) : undefined,
            lte: endDate ? dateOnly(endDate) : undefined,
          },
        },
        include: { linkedPlan: true, studyBreaks: true },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({
        success: true,
        data: data.map((item) => this.serializeSession(item)),
        meta: {},
      }));
  }

  private serializeSession<
    T extends {
      startedAt: Date | null;
      endedAt: Date | null;
      studyMinutes: number;
      studySeconds: number;
      breakMinutes: number;
      breakSeconds: number;
      studyBreaks?: Array<{
        startedAt: Date;
        endedAt: Date | null;
        breakSeconds: number;
      }>;
    },
  >(session: T) {
    const durations = this.resolveSessionDurations(session);

    return {
      ...session,
      studyMinutes: durations.studyMinutes,
      studySeconds: durations.studySeconds,
      breakMinutes: durations.breakMinutes,
      breakSeconds: durations.breakSeconds,
    };
  }

  private resolveSessionDurations(session: {
    startedAt: Date | null;
    endedAt: Date | null;
    studyMinutes: number;
    studySeconds: number;
    breakMinutes: number;
    breakSeconds: number;
    studyBreaks?: Array<{
      startedAt: Date;
      endedAt: Date | null;
      breakSeconds: number;
    }>;
  }) {
    if (!session.startedAt) {
      return {
        studyMinutes: session.studyMinutes,
        studySeconds: session.studySeconds,
        breakMinutes: session.breakMinutes,
        breakSeconds: session.breakSeconds,
      };
    }

    const now = new Date();
    const closedBreakSeconds =
      session.studyBreaks
        ?.filter((item) => item.endedAt != null)
        .reduce(
          (sum, item) =>
            sum +
            (item.breakSeconds > 0
              ? item.breakSeconds
              : diffSeconds(item.startedAt, item.endedAt)),
          0,
        ) ?? session.breakSeconds;
    const openBreakSeconds =
      session.studyBreaks
        ?.filter((item) => item.endedAt == null)
        .reduce((sum, item) => sum + diffSeconds(item.startedAt, now), 0) ?? 0;
    const totalBreakSeconds = closedBreakSeconds + openBreakSeconds;
    const endAt = session.endedAt ?? now;
    const totalSeconds = diffSeconds(session.startedAt, endAt);
    const studySeconds = Math.max(0, totalSeconds - totalBreakSeconds);

    return {
      studyMinutes: Math.floor(studySeconds / 60),
      studySeconds,
      breakMinutes: Math.floor(totalBreakSeconds / 60),
      breakSeconds: totalBreakSeconds,
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
