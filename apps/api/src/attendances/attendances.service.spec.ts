import {
  AttendanceFlag,
  AttendanceStatus,
  StudySessionStatus,
} from '@prisma/client';
import { AuditService } from '@/audit/audit.service';
import { PrismaService } from '@/database/prisma.service';
import { EventsService } from '@/events/events.service';
import { NotificationsService } from '@/notifications/notifications.service';
import { PointsService } from '@/points/points.service';
import { AttendancesService } from './attendances.service';

describe('AttendancesService', () => {
  let service: AttendancesService;
  let prisma: {
    attendance: { findUnique: jest.Mock };
    $transaction: jest.Mock;
    student: { findUnique: jest.Mock };
  };
  let events: { emit: jest.Mock };
  let notificationsService: { sendDirectToUsers: jest.Mock };
  let pointsService: { awardStudySessionTime: jest.Mock; earn: jest.Mock };

  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-04-30T21:00:00.000Z'));

    prisma = {
      attendance: { findUnique: jest.fn() },
      $transaction: jest.fn(),
      student: { findUnique: jest.fn() },
    };
    events = { emit: jest.fn() };
    notificationsService = {
      sendDirectToUsers: jest.fn().mockResolvedValue(undefined),
    };
    pointsService = {
      awardStudySessionTime: jest.fn().mockResolvedValue(50),
      earn: jest.fn().mockResolvedValue(50),
    };

    service = new AttendancesService(
      prisma as unknown as PrismaService,
      {} as AuditService,
      events as unknown as EventsService,
      notificationsService as unknown as NotificationsService,
      pointsService as unknown as PointsService,
    );
    prisma.student.findUnique.mockResolvedValue({ userId: 'user-1' });
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('auto-closes active sessions on checkout and awards timer points', async () => {
    prisma.attendance.findUnique.mockResolvedValue({
      id: 'attendance-1',
      studentId: 'student-1',
      attendanceDate: new Date('2026-04-30T00:00:00.000Z'),
      checkInAt: new Date('2026-04-30T18:00:00.000Z'),
      seatId: null,
    });
    prisma.$transaction.mockImplementation(
      (callback: (tx: unknown) => Promise<unknown>) =>
        callback({
          studySession: {
            findMany: jest.fn().mockResolvedValue([
              {
                id: 'session-1',
                studentId: 'student-1',
                startedAt: new Date('2026-04-30T20:00:00.000Z'),
                status: StudySessionStatus.ACTIVE,
                studyBreaks: [],
              },
            ]),
            update: jest.fn().mockResolvedValue({
              id: 'session-1',
              studySeconds: 3600,
            }),
          },
          studyBreak: {
            update: jest.fn().mockResolvedValue(undefined),
            findMany: jest.fn().mockResolvedValue([]),
          },
          attendance: {
            update: jest.fn().mockResolvedValue({
              id: 'attendance-1',
              studentId: 'student-1',
              attendanceDate: new Date('2026-04-30T00:00:00.000Z'),
              attendanceStatus: AttendanceStatus.CHECKED_OUT,
              checkInAt: new Date('2026-04-30T18:00:00.000Z'),
              checkOutAt: new Date('2026-04-30T21:00:00.000Z'),
              stayMinutes: 180,
              lateStatus: AttendanceFlag.NONE,
              earlyLeaveStatus: AttendanceFlag.EARLY_LEAVE,
            }),
          },
          seat: {
            update: jest.fn().mockResolvedValue(undefined),
          },
          student: {
            findUnique: jest.fn().mockResolvedValue({ assignedSeatId: null }),
          },
        }),
    );

    const result = await service.checkOut('student-1', true);

    expect(pointsService.awardStudySessionTime).toHaveBeenCalledWith(
      'student-1',
      'session-1',
      3600,
    );
    expect(result.data?.status).toBe(AttendanceStatus.CHECKED_OUT);
  });
});
