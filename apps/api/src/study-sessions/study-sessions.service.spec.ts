import { StudySessionStatus } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { NotificationsService } from '@/notifications/notifications.service';
import { PointsService } from '@/points/points.service';
import { StudySessionsService } from './study-sessions.service';

describe('StudySessionsService', () => {
  let service: StudySessionsService;
  let prisma: {
    studySession: { findFirst: jest.Mock };
    $transaction: jest.Mock;
    student: { findUnique: jest.Mock };
  };
  let notificationsService: {
    sendDirectToUsers: jest.Mock;
  };
  let pointsService: {
    awardStudySessionTime: jest.Mock;
  };

  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-04-30T10:00:00.000Z'));

    prisma = {
      studySession: { findFirst: jest.fn() },
      $transaction: jest.fn(),
      student: { findUnique: jest.fn() },
    };
    notificationsService = {
      sendDirectToUsers: jest.fn().mockResolvedValue(undefined),
    };
    pointsService = {
      awardStudySessionTime: jest.fn().mockResolvedValue(100),
    };
    service = new StudySessionsService(
      prisma as unknown as PrismaService,
      notificationsService as unknown as NotificationsService,
      pointsService as unknown as PointsService,
    );
    prisma.student.findUnique.mockResolvedValue({ userId: 'user-1' });
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('ends a session and awards timer points from study seconds', async () => {
    prisma.studySession.findFirst.mockResolvedValue({
      id: 'session-1',
      studentId: 'student-1',
      startedAt: new Date('2026-04-30T09:00:00.000Z'),
      status: StudySessionStatus.PAUSED,
      studyBreaks: [
        {
          id: 'break-1',
          startedAt: new Date('2026-04-30T09:30:00.000Z'),
          endedAt: null,
          breakSeconds: 0,
        },
      ],
    });
    prisma.$transaction.mockImplementation(
      (callback: (tx: unknown) => Promise<unknown>) =>
        callback({
          studyBreak: {
            update: jest.fn().mockResolvedValue(undefined),
            findMany: jest.fn().mockResolvedValue([
              {
                id: 'break-1',
                breakSeconds: 1800,
              },
            ]),
          },
          studySession: {
            update: jest.fn().mockResolvedValue({
              id: 'session-1',
              studentId: 'student-1',
              status: StudySessionStatus.COMPLETED,
              startedAt: new Date('2026-04-30T09:00:00.000Z'),
              endedAt: new Date('2026-04-30T10:00:00.000Z'),
              studyMinutes: 30,
              studySeconds: 1800,
              breakMinutes: 30,
              breakSeconds: 1800,
              linkedPlan: null,
              studyBreaks: [
                {
                  id: 'break-1',
                  startedAt: new Date('2026-04-30T09:30:00.000Z'),
                  endedAt: new Date('2026-04-30T10:00:00.000Z'),
                  breakSeconds: 1800,
                },
              ],
            }),
          },
        }),
    );

    const result = await service.end('student-1', 'session-1');

    expect(pointsService.awardStudySessionTime).toHaveBeenCalledWith(
      'student-1',
      'session-1',
      1800,
    );
    expect(result.data.studySeconds).toBe(1800);
    expect(result.data.studyMinutes).toBe(30);
    expect(result.data.breakSeconds).toBe(1800);
  });
});
