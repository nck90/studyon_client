import { BadgeRuleMetric, BadgeType } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { BadgeAutomationService } from './badge-automation.service';

describe('BadgeAutomationService', () => {
  let service: BadgeAutomationService;
  let prisma: {
    badge: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      upsert: jest.Mock;
    };
    badgeRule: {
      create: jest.Mock;
      findFirst: jest.Mock;
      findMany: jest.Mock;
    };
    dailyStudentMetric: {
      findMany: jest.Mock;
    };
    monthlyStudentMetric: {
      findMany: jest.Mock;
    };
    studentBadge: {
      create: jest.Mock;
      findFirst: jest.Mock;
    };
    weeklyStudentMetric: {
      findMany: jest.Mock;
    };
  };

  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-05-22T03:00:00.000Z'));
    prisma = {
      badge: {
        findMany: jest.fn().mockResolvedValue([]),
        findUnique: jest.fn(),
        upsert: jest.fn().mockResolvedValue(undefined),
      },
      badgeRule: {
        create: jest.fn().mockResolvedValue(undefined),
        findFirst: jest.fn().mockResolvedValue({ id: 'existing-rule' }),
        findMany: jest.fn(),
      },
      dailyStudentMetric: {
        findMany: jest.fn(),
      },
      monthlyStudentMetric: {
        findMany: jest.fn(),
      },
      studentBadge: {
        create: jest.fn().mockResolvedValue(undefined),
        findFirst: jest.fn().mockResolvedValue(null),
      },
      weeklyStudentMetric: {
        findMany: jest.fn(),
      },
    };
    service = new BadgeAutomationService(prisma as unknown as PrismaService);
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('awards weekly study badges using weekly metrics', async () => {
    const weeklyBadge = {
      id: 'badge-weekly',
      code: 'WEEKLY_20H',
      name: '주간 20시간',
      description: '주간 공부 20시간 달성',
      badgeType: BadgeType.STUDY_TIME,
    };
    prisma.dailyStudentMetric.findMany.mockResolvedValue([
      {
        studentId: 'student-1',
        attendanceStatus: 'ABSENT',
        streakDays: 0,
        studyMinutes: 30,
        achievedRate: 0,
        pagesCompleted: 0,
        problemsSolved: 0,
      },
    ]);
    prisma.badgeRule.findMany.mockResolvedValue([
      {
        badge: weeklyBadge,
        metric: BadgeRuleMetric.WEEKLY_STUDY_MINUTES,
        threshold: 1200,
      },
    ]);
    prisma.weeklyStudentMetric.findMany.mockResolvedValue([
      {
        studentId: 'student-1',
        studyMinutes: 1230,
      },
    ]);
    prisma.monthlyStudentMetric.findMany.mockResolvedValue([]);
    prisma.badge.findUnique.mockResolvedValue(weeklyBadge);

    await service.awardBadges();

    expect(prisma.weeklyStudentMetric.findMany).toHaveBeenCalledWith({
      where: { studentId: { in: ['student-1'] } },
      orderBy: { weekStartDate: 'desc' },
    });
    expect(prisma.studentBadge.create).toHaveBeenCalledWith({
      data: {
        studentId: 'student-1',
        badgeId: 'badge-weekly',
        reason: '주간 20시간 자동 달성',
      },
    });
  });
});
