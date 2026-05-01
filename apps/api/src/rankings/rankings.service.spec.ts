import { RankingPeriodType, RankingType } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { MetricsService } from '@/metrics/metrics.service';
import { RankingsService } from './rankings.service';

describe('RankingsService', () => {
  let service: RankingsService;
  let prisma: {
    rankingSnapshot: {
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
    rankingSnapshotItem: {
      deleteMany: jest.Mock;
      createMany: jest.Mock;
    };
    student: {
      findMany: jest.Mock;
    };
    dailyStudentMetric: {
      findMany: jest.Mock;
    };
    weeklyStudentMetric: {
      findMany: jest.Mock;
    };
    monthlyStudentMetric: {
      findMany: jest.Mock;
    };
  };
  let metricsService: {
    refreshForDate: jest.Mock;
  };

  beforeEach(() => {
    prisma = {
      rankingSnapshot: {
        findFirst: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockResolvedValue({ id: 'snapshot-1' }),
        update: jest.fn(),
      },
      rankingSnapshotItem: {
        deleteMany: jest.fn().mockResolvedValue(undefined),
        createMany: jest.fn().mockResolvedValue({ count: 2 }),
      },
      student: {
        findMany: jest.fn().mockResolvedValue([
          { id: 'student-1', user: { name: 'A' } },
          { id: 'student-2', user: { name: 'B' } },
        ]),
      },
      dailyStudentMetric: {
        findMany: jest.fn().mockResolvedValue([]),
      },
      weeklyStudentMetric: {
        findMany: jest.fn().mockResolvedValue([
          {
            studentId: 'student-1',
            studyMinutes: 600,
            pagesCompleted: 0,
            problemsSolved: 0,
            attendanceDays: 5,
          },
          {
            studentId: 'student-2',
            studyMinutes: 300,
            pagesCompleted: 0,
            problemsSolved: 0,
            attendanceDays: 3,
          },
        ]),
      },
      monthlyStudentMetric: {
        findMany: jest.fn().mockResolvedValue([]),
      },
    };
    metricsService = {
      refreshForDate: jest.fn().mockResolvedValue(undefined),
    };
    service = new RankingsService(
      prisma as unknown as PrismaService,
      metricsService as unknown as MetricsService,
    );
  });

  it('builds weekly rankings from weekly metrics', async () => {
    await service.ensureSnapshot(
      RankingPeriodType.WEEKLY,
      RankingType.STUDY_TIME,
    );

    expect(prisma.weeklyStudentMetric.findMany).toHaveBeenCalledTimes(1);
    expect(prisma.dailyStudentMetric.findMany).not.toHaveBeenCalled();
    expect(prisma.rankingSnapshotItem.createMany).toHaveBeenCalledWith({
      data: [
        {
          rankingSnapshotId: 'snapshot-1',
          studentId: 'student-1',
          rankNo: 1,
          score: 600,
          subScore1: 0,
          subScore2: 0,
        },
        {
          rankingSnapshotId: 'snapshot-1',
          studentId: 'student-2',
          rankNo: 2,
          score: 300,
          subScore1: 0,
          subScore2: 0,
        },
      ],
    });
  });
});
