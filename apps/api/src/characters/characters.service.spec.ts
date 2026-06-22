import { CharacterXpSource, PointSource } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { PointsService } from '@/points/points.service';
import { CharactersService } from './characters.service';

describe('CharactersService', () => {
  let service: CharactersService;
  let prisma: {
    $transaction: jest.Mock;
  };
  let pointsService: {
    earn: jest.Mock;
    spend: jest.Mock;
  };

  beforeEach(() => {
    prisma = {
      $transaction: jest.fn(),
    };
    pointsService = {
      earn: jest.fn().mockResolvedValue(20),
      spend: jest.fn(),
    };
    service = new CharactersService(
      prisma as unknown as PrismaService,
      pointsService as unknown as PointsService,
    );
  });

  it('awards xp and level-up bonus once per reference key', async () => {
    prisma.$transaction.mockImplementation(
      (callback: (tx: unknown) => Promise<unknown>) =>
        callback({
          characterXpTransaction: {
            findUnique: jest.fn().mockResolvedValue(null),
            create: jest.fn().mockResolvedValue({}),
          },
          studentCharacter: {
            findUnique: jest.fn().mockResolvedValue({
              studentId: 'student-1',
              level: 1,
              xp: 90,
              growthStage: 'stage_01',
            }),
            create: jest.fn(),
            update: jest.fn().mockResolvedValue({
              studentId: 'student-1',
              level: 2,
              xp: 15,
              growthStage: 'stage_01',
            }),
          },
        }),
    );

    const result = await service.awardXp(
      'student-1',
      25,
      CharacterXpSource.DAILY_MISSION,
      'daily-mission:mission-1',
      '오늘 퀘스트 완료',
    );

    expect(result.leveledUp).toBe(true);
    expect(result.level).toBe(2);
    expect(result.xp).toBe(15);
    expect(pointsService.earn).toHaveBeenCalledWith(
      'student-1',
      20,
      PointSource.LEVEL_UP_BONUS,
      'Lv.2 성장 보너스',
    );
  });

  it('records base points in the reward ledger', async () => {
    const create = jest.fn().mockResolvedValue({});
    prisma.$transaction.mockImplementation(
      (callback: (tx: unknown) => Promise<unknown>) =>
        callback({
          characterXpTransaction: {
            findUnique: jest.fn().mockResolvedValue(null),
            create,
          },
          studentCharacter: {
            findUnique: jest.fn().mockResolvedValue({
              studentId: 'student-1',
              level: 1,
              xp: 0,
              growthStage: 'stage_01',
            }),
            create: jest.fn(),
            update: jest.fn().mockResolvedValue({
              studentId: 'student-1',
              level: 1,
              xp: 25,
              growthStage: 'stage_01',
            }),
          },
        }),
    );

    await service.awardXp(
      'student-1',
      25,
      CharacterXpSource.DAILY_MISSION,
      'daily-mission:mission-1',
      '오늘 퀘스트 완료',
      50,
    );

    expect(create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        points: 50,
        levelBefore: 1,
        levelAfter: 1,
        xpAfter: 25,
      }),
    });
  });

  it('does not award duplicate xp for the same reference key', async () => {
    prisma.$transaction.mockImplementation(
      (callback: (tx: unknown) => Promise<unknown>) =>
        callback({
          characterXpTransaction: {
            findUnique: jest.fn().mockResolvedValue({ id: 'event-1' }),
          },
          studentCharacter: {
            findUnique: jest.fn().mockResolvedValue({
              studentId: 'student-1',
              level: 2,
              xp: 15,
              growthStage: 'stage_01',
            }),
          },
        }),
    );

    const result = await service.awardXp(
      'student-1',
      25,
      CharacterXpSource.DAILY_MISSION,
      'daily-mission:mission-1',
    );

    expect(result.duplicate).toBe(true);
    expect(pointsService.earn).not.toHaveBeenCalled();
  });
});
