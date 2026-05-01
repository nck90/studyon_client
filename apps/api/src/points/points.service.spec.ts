import { PointSource } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { PointsService } from './points.service';

describe('PointsService', () => {
  let service: PointsService;
  let prisma: {
    pointTransaction: { findFirst: jest.Mock };
  };

  beforeEach(() => {
    prisma = {
      pointTransaction: { findFirst: jest.fn() },
    };
    service = new PointsService(prisma as unknown as PrismaService);
  });

  it('awards 100 points per hour for timer study sessions', async () => {
    prisma.pointTransaction.findFirst.mockResolvedValue(null);
    const earnSpy = jest.spyOn(service, 'earn').mockResolvedValue(100);

    const result = await service.awardStudySessionTime(
      'student-1',
      'session-1',
      3600,
    );

    expect(prisma.pointTransaction.findFirst).toHaveBeenCalledWith({
      where: {
        studentId: 'student-1',
        source: PointSource.STUDY_TIME,
        memo: { startsWith: '[study-session:session-1]' },
      },
      select: { balance: true },
    });
    expect(earnSpy).toHaveBeenCalledWith(
      'student-1',
      100,
      PointSource.STUDY_TIME,
      '[study-session:session-1] 타이머 공부 60분',
    );
    expect(result).toBe(100);
  });

  it('does not double-award a timer study session', async () => {
    prisma.pointTransaction.findFirst.mockResolvedValue({ balance: 250 });
    const earnSpy = jest.spyOn(service, 'earn').mockResolvedValue(350);

    const result = await service.awardStudySessionTime(
      'student-1',
      'session-1',
      7200,
    );

    expect(earnSpy).not.toHaveBeenCalled();
    expect(result).toBe(250);
  });
});
