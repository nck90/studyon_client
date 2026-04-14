import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import {
  AttendanceStatus,
  NotificationChannel,
  NotificationType,
  StudySessionStatus,
} from '@prisma/client';
import { startOfDay } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { SettingsService } from '@/settings/settings.service';
import { NotificationsService } from './notifications.service';

@Injectable()
export class NotificationsAutomationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settingsService: SettingsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  @Cron('0 */5 * * * *')
  async run() {
    await this.processScheduledNotifications();
    await this.processAbsenceAlerts();
    await this.processBreakAlerts();
    await this.processGoalShortfallAlerts();
  }

  private async processScheduledNotifications() {
    const scheduled = await this.prisma.notification.findMany({
      where: {
        status: 'SCHEDULED',
        scheduledAt: { lte: new Date() },
      },
      select: { id: true },
      take: 50,
    });

    for (const item of scheduled) {
      await this.notificationsService.send(item.id);
    }
  }

  private async processAbsenceAlerts() {
    const policyResult = await this.settingsService.getAttendancePolicy();
    const cutoff = policyResult.data?.lateCutoffTime ?? '09:00';
    if (!this.hasPassedTime(cutoff)) {
      return;
    }

    const today = new Date(new Date().toISOString().slice(0, 10));
    const students = await this.prisma.student.findMany({
      where: {
        enrollmentStatus: 'ACTIVE',
        attendances: {
          none: {
            attendanceDate: today,
            attendanceStatus: {
              in: [AttendanceStatus.CHECKED_IN, AttendanceStatus.CHECKED_OUT],
            },
          },
        },
      },
      include: { user: true },
      take: 100,
    });

    for (const student of students) {
      await this.sendAutomatedStudentNotification({
        userId: student.userId,
        title: '미입실 알림',
        body: `${student.user.name} 학생이 아직 입실하지 않았습니다.`,
        notificationType: NotificationType.ABSENCE,
      });
    }
  }

  private async processBreakAlerts() {
    const sessions = await this.prisma.studySession.findMany({
      where: { status: StudySessionStatus.PAUSED },
      include: {
        student: { include: { user: true } },
        studyBreaks: { orderBy: { createdAt: 'desc' }, take: 1 },
      },
      take: 100,
    });

    const thresholdMinutes = 15;
    for (const session of sessions) {
      const latestBreak = session.studyBreaks[0];
      if (!latestBreak?.startedAt || latestBreak.endedAt) {
        continue;
      }

      const elapsedMinutes = Math.floor(
        (Date.now() - latestBreak.startedAt.getTime()) / 60000,
      );
      if (elapsedMinutes < thresholdMinutes) {
        continue;
      }

      await this.sendAutomatedStudentNotification({
        userId: session.student.userId,
        title: '휴식 시간 초과 알림',
        body: `${session.student.user.name} 학생의 휴식 시간이 ${thresholdMinutes}분을 초과했습니다.`,
        notificationType: NotificationType.BREAK_OVER,
      });
    }
  }

  private async processGoalShortfallAlerts() {
    if (!this.hasPassedTime('21:00')) {
      return;
    }

    const today = new Date(new Date().toISOString().slice(0, 10));
    const students = await this.prisma.student.findMany({
      where: { enrollmentStatus: 'ACTIVE' },
      include: { user: true },
      take: 100,
    });

    for (const student of students) {
      const [plans, sessions] = await Promise.all([
        this.prisma.studyPlan.findMany({
          where: { studentId: student.id, planDate: today },
        }),
        this.prisma.studySession.findMany({
          where: { studentId: student.id, sessionDate: today },
        }),
      ]);

      const targetMinutes = plans.reduce(
        (sum, item) => sum + item.targetMinutes,
        0,
      );
      if (targetMinutes <= 0) {
        continue;
      }

      const studyMinutes = sessions.reduce(
        (sum, item) => sum + item.studyMinutes,
        0,
      );
      if (studyMinutes >= targetMinutes) {
        continue;
      }

      await this.sendAutomatedStudentNotification({
        userId: student.userId,
        title: '목표 미달성 알림',
        body: `${student.user.name} 학생의 오늘 공부 시간이 목표 대비 부족합니다.`,
        notificationType: NotificationType.GOAL_SHORTFALL,
      });
    }
  }

  private async sendAutomatedStudentNotification(input: {
    userId: string;
    title: string;
    body: string;
    notificationType: NotificationType;
  }) {
    const existing = await this.prisma.notificationReceipt.findFirst({
      where: {
        userId: input.userId,
        notification: {
          notificationType: input.notificationType,
          title: input.title,
          createdAt: { gte: startOfDay() },
        },
      },
    });

    if (existing) {
      return;
    }

    await this.notificationsService.sendDirectToUsers({
      userIds: [input.userId],
      notificationType: input.notificationType,
      channel: NotificationChannel.IN_APP,
      title: input.title,
      body: input.body,
    });
  }

  private hasPassedTime(time: string) {
    const [hours, minutes] = time.split(':').map(Number);
    const now = new Date();
    return (
      now.getHours() > hours ||
      (now.getHours() === hours && now.getMinutes() >= minutes)
    );
  }
}
