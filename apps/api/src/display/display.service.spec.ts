import { RankingPeriodType, RankingType } from '@prisma/client';
import { DisplayService } from './display.service';

describe('DisplayService', () => {
  const prisma = {
    seat: { findMany: jest.fn() },
    attendance: { count: jest.fn() },
    studySession: { findMany: jest.fn() },
    rankingSnapshotItem: { findFirst: jest.fn() },
  };
  const rankingsService = { adminRanking: jest.fn() };
  const settingsService = {
    getTvDisplay: jest.fn(),
    updateTvDisplay: jest.fn(),
  };
  let service: DisplayService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new DisplayService(
      prisma as never,
      rankingsService as never,
      settingsService as never,
    );
  });

  it('normalizes TV display settings for public clients', async () => {
    settingsService.getTvDisplay.mockResolvedValue({
      success: true,
      data: {
        activeScreen: 'STATUS',
        rotationEnabled: true,
        rotationIntervalSeconds: 20,
        displayOptions: {
          enabledScreens: ['RANKING', 'STATUS', 'MOTIVATION', 'CLOCK'],
          message: '집중합시다',
          rankingType: 'STUDY_VOLUME',
          periodType: 'WEEKLY',
        },
        updatedAt: new Date('2026-05-22T01:00:00.000Z'),
      },
      meta: {},
    });

    await expect(service.current()).resolves.toEqual({
      success: true,
      data: {
        activeScreen: 'SEAT_MAP',
        rotationEnabled: true,
        rotationIntervalSeconds: 20,
        enabledScreens: ['RANKING', 'SEAT_MAP', 'MESSAGE', 'CLOCK'],
        message: '집중합시다',
        rankingType: 'STUDY_VOLUME',
        periodType: 'WEEKLY',
        updatedAt: '2026-05-22T01:00:00.000Z',
      },
      meta: {},
    });
  });

  it('masks student names in public rankings', async () => {
    rankingsService.adminRanking.mockResolvedValue({
      success: true,
      data: {
        snapshot: {
          id: 'snapshot-1',
          rankingType: RankingType.STUDY_TIME,
          periodType: RankingPeriodType.DAILY,
          periodKey: '2026-05-22',
        },
        items: [
          {
            id: 'rank-1',
            studentId: 'student-1',
            rankNo: 1,
            score: '120',
            subScore1: '0',
            subScore2: '0',
            student: {
              id: 'student-1',
              user: { name: '정상민' },
              grade: { name: '고3' },
              class: { name: 'A반' },
            },
          },
        ],
      },
      meta: {},
    });

    const result = await service.rankings(
      RankingPeriodType.DAILY,
      RankingType.STUDY_TIME,
    );

    expect(result.data.items[0].displayName).toBe('정*민');
    expect(result.data.items[0].student.user.name).toBe('정*민');
  });

  it('returns masked public seat map data', async () => {
    prisma.seat.findMany.mockResolvedValue([
      {
        id: 'seat-1',
        seatNo: 'A1',
        zone: 'A',
        status: 'OCCUPIED',
        currentStudent: {
          id: 'student-1',
          user: { name: '김민지' },
        },
      },
      {
        id: 'seat-2',
        seatNo: 'A2',
        zone: 'A',
        status: 'AVAILABLE',
        currentStudent: null,
      },
    ]);

    await expect(service.seats()).resolves.toEqual({
      success: true,
      data: [
        {
          id: 'seat-1',
          seatNo: 'A1',
          zone: 'A',
          status: 'OCCUPIED',
          uiStatus: 'occupied',
          currentStudent: { id: 'student-1', displayName: '김*지' },
        },
        {
          id: 'seat-2',
          seatNo: 'A2',
          zone: 'A',
          status: 'AVAILABLE',
          uiStatus: 'empty',
          currentStudent: null,
        },
      ],
      meta: {},
    });
  });
});
