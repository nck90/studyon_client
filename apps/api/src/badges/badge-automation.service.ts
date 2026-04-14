import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { BadgeType } from '@prisma/client';
import { dateOnly } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';

const DEFAULT_BADGES = [
  {
    code: 'ATTENDANCE_STARTER',
    name: '첫 출석',
    description: '첫 입실을 완료했습니다.',
    badgeType: BadgeType.ATTENDANCE,
  },
  {
    code: 'ATTENDANCE_STREAK_7',
    name: '7일 연속 출석',
    description: '7일 연속 출석을 달성했습니다.',
    badgeType: BadgeType.ATTENDANCE,
  },
  {
    code: 'STUDY_5H',
    name: '5시간 집중',
    description: '하루 공부 시간 5시간을 달성했습니다.',
    badgeType: BadgeType.STUDY_TIME,
  },
  {
    code: 'GOAL_ACHIEVER',
    name: '목표 달성',
    description: '하루 계획 달성률 100%를 달성했습니다.',
    badgeType: BadgeType.ACHIEVEMENT,
  },
];

@Injectable()
export class BadgeAutomationService {
  constructor(private readonly prisma: PrismaService) {}

  @Cron('30 */20 * * * *')
  async awardBadges() {
    await this.ensureDefaultBadges();
    const metrics = await this.prisma.dailyStudentMetric.findMany({
      where: { metricDate: dateOnly() },
    });

    for (const metric of metrics) {
      if (
        metric.attendanceStatus === 'CHECKED_IN' ||
        metric.attendanceStatus === 'CHECKED_OUT'
      ) {
        await this.give(metric.studentId, 'ATTENDANCE_STARTER', '첫 출석 달성');
      }
      if (metric.streakDays >= 7) {
        await this.give(
          metric.studentId,
          'ATTENDANCE_STREAK_7',
          '7일 연속 출석 달성',
        );
      }
      if (metric.studyMinutes >= 300) {
        await this.give(metric.studentId, 'STUDY_5H', '하루 5시간 공부 달성');
      }
      if (Number(metric.achievedRate) >= 100) {
        await this.give(metric.studentId, 'GOAL_ACHIEVER', '당일 목표 달성');
      }
    }
  }

  private async ensureDefaultBadges() {
    for (const badge of DEFAULT_BADGES) {
      await this.prisma.badge.upsert({
        where: { code: badge.code },
        update: badge,
        create: badge,
      });
    }
  }

  private async give(studentId: string, badgeCode: string, reason: string) {
    const badge = await this.prisma.badge.findUnique({
      where: { code: badgeCode },
    });
    if (!badge) {
      return;
    }

    const existing = await this.prisma.studentBadge.findFirst({
      where: { studentId, badgeId: badge.id },
    });
    if (existing) {
      return;
    }

    await this.prisma.studentBadge.create({
      data: {
        studentId,
        badgeId: badge.id,
        reason,
      },
    });
  }
}
