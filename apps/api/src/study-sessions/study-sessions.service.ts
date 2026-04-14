import { BadRequestException, Injectable } from '@nestjs/common';
import { StudySessionStatus } from '@prisma/client';
import { dateOnly, diffMinutes } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';

@Injectable()
export class StudySessionsService {
  constructor(private readonly prisma: PrismaService) {}

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
      .then((data) => ({ success: true, data, meta: {} }));
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
      include: { linkedPlan: true },
    });

    if (linkedPlanId) {
      await this.prisma.studyPlan.update({
        where: { id: linkedPlanId },
        data: { status: 'IN_PROGRESS' },
      });
    }

    return { success: true, data: session, meta: {} };
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
      });
    });

    return { success: true, data: updated, meta: {} };
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
    const breakMinutes = diffMinutes(activeBreak.startedAt, now);

    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.studyBreak.update({
        where: { id: activeBreak.id },
        data: { endedAt: now, breakMinutes },
      });

      const breaks = await tx.studyBreak.findMany({
        where: { studySessionId: sessionId },
      });
      return tx.studySession.update({
        where: { id: sessionId },
        data: {
          status: StudySessionStatus.ACTIVE,
          breakMinutes: breaks.reduce(
            (sum, item) => sum + item.breakMinutes,
            0,
          ),
        },
      });
    });

    return { success: true, data: updated, meta: {} };
  }

  async end(studentId: string, sessionId: string) {
    const session = await this.prisma.studySession.findFirst({
      where: { id: sessionId, studentId },
      include: { studyBreaks: true },
    });
    if (!session || !session.startedAt) {
      throw new BadRequestException('세션을 종료할 수 없습니다.');
    }

    const now = new Date();

    const result = await this.prisma.$transaction(async (tx) => {
      const openBreak = session.studyBreaks.find((item) => !item.endedAt);
      if (openBreak) {
        await tx.studyBreak.update({
          where: { id: openBreak.id },
          data: {
            endedAt: now,
            breakMinutes: diffMinutes(openBreak.startedAt, now),
          },
        });
      }

      const breaks = await tx.studyBreak.findMany({
        where: { studySessionId: sessionId },
      });
      const breakMinutes = breaks.reduce(
        (sum, item) => sum + item.breakMinutes,
        0,
      );
      const totalMinutes = diffMinutes(session.startedAt, now);
      const studyMinutes = Math.max(0, totalMinutes - breakMinutes);

      return tx.studySession.update({
        where: { id: sessionId },
        data: {
          status: StudySessionStatus.COMPLETED,
          endedAt: now,
          breakMinutes,
          studyMinutes,
        },
      });
    });

    return { success: true, data: result, meta: {} };
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
        include: { linkedPlan: true },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }
}
