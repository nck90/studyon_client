import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { BadgeRuleMetric, BadgeType } from '@prisma/client';
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
    await this.ensureDefaultRules();
    const metrics = await this.prisma.dailyStudentMetric.findMany({
      where: { metricDate: dateOnly() },
    });
    const rules = await this.prisma.badgeRule.findMany({
      where: { isActive: true },
      include: { badge: true },
    });
    const studentIds = metrics.map((metric) => metric.studentId);
    const [weeklyMetrics, monthlyMetrics] = await Promise.all([
      rules.some((rule) => rule.metric === BadgeRuleMetric.WEEKLY_STUDY_MINUTES)
        ? this.prisma.weeklyStudentMetric.findMany({
            where: { studentId: { in: studentIds } },
            orderBy: { weekStartDate: 'desc' },
          })
        : Promise.resolve([]),
      rules.some(
        (rule) => rule.metric === BadgeRuleMetric.MONTHLY_STUDY_MINUTES,
      )
        ? this.prisma.monthlyStudentMetric.findMany({
            where: { studentId: { in: studentIds } },
            orderBy: { monthKey: 'desc' },
          })
        : Promise.resolve([]),
    ]);
    const weeklyByStudentId = new Map<string, number>();
    const monthlyByStudentId = new Map<string, number>();
    for (const metric of weeklyMetrics) {
      if (!weeklyByStudentId.has(metric.studentId)) {
        weeklyByStudentId.set(metric.studentId, metric.studyMinutes);
      }
    }
    for (const metric of monthlyMetrics) {
      if (!monthlyByStudentId.has(metric.studentId)) {
        monthlyByStudentId.set(metric.studentId, metric.studyMinutes);
      }
    }

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
      for (const rule of rules) {
        if (
          this.metricValue(rule.metric, metric, {
            weeklyStudyMinutes:
              weeklyByStudentId.get(metric.studentId) ?? metric.studyMinutes,
            monthlyStudyMinutes:
              monthlyByStudentId.get(metric.studentId) ?? metric.studyMinutes,
          }) >= rule.threshold
        ) {
          await this.give(
            metric.studentId,
            rule.badge.code,
            `${rule.badge.name} 자동 달성`,
          );
        }
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

  private async ensureDefaultRules() {
    const badgeCodes = ['ATTENDANCE_STREAK_7', 'STUDY_5H', 'GOAL_ACHIEVER'];
    const badges = await this.prisma.badge.findMany({
      where: { code: { in: badgeCodes } },
    });
    const byCode = new Map(badges.map((badge) => [badge.code, badge]));
    const rules = [
      {
        code: 'ATTENDANCE_STREAK_7',
        metric: BadgeRuleMetric.ATTENDANCE_STREAK_DAYS,
        threshold: 7,
      },
      {
        code: 'STUDY_5H',
        metric: BadgeRuleMetric.DAILY_STUDY_MINUTES,
        threshold: 300,
      },
      {
        code: 'GOAL_ACHIEVER',
        metric: BadgeRuleMetric.DAILY_ACHIEVED_RATE,
        threshold: 100,
      },
    ];

    for (const rule of rules) {
      const badge = byCode.get(rule.code);
      if (!badge) continue;
      const existing = await this.prisma.badgeRule.findFirst({
        where: { badgeId: badge.id, metric: rule.metric },
      });
      if (existing) continue;
      await this.prisma.badgeRule.create({
        data: {
          badgeId: badge.id,
          metric: rule.metric,
          threshold: rule.threshold,
          isActive: true,
        },
      });
    }
  }

  private metricValue(
    metric: BadgeRuleMetric,
    dailyMetric: {
      studentId: string;
      streakDays: number;
      studyMinutes: number;
      achievedRate: unknown;
      pagesCompleted: number;
      problemsSolved: number;
    },
    periodMetric: {
      weeklyStudyMinutes: number;
      monthlyStudyMinutes: number;
    },
  ) {
    switch (metric) {
      case BadgeRuleMetric.ATTENDANCE_STREAK_DAYS:
        return dailyMetric.streakDays;
      case BadgeRuleMetric.DAILY_STUDY_MINUTES:
        return dailyMetric.studyMinutes;
      case BadgeRuleMetric.DAILY_ACHIEVED_RATE:
        return Number(dailyMetric.achievedRate);
      case BadgeRuleMetric.PAGES_COMPLETED:
        return dailyMetric.pagesCompleted;
      case BadgeRuleMetric.PROBLEMS_SOLVED:
        return dailyMetric.problemsSolved;
      case BadgeRuleMetric.WEEKLY_STUDY_MINUTES:
        return periodMetric.weeklyStudyMinutes;
      case BadgeRuleMetric.MONTHLY_STUDY_MINUTES:
        return periodMetric.monthlyStudyMinutes;
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
