import { Injectable } from '@nestjs/common';
import { AttendanceStatus } from '@prisma/client';
import {
  dateOnly,
  endOfDay,
  monthKey,
  startOfDay,
  weekStart,
} from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async daily(studentId: string, date?: string) {
    const targetDate = dateOnly(date);
    const attendance = await this.prisma.attendance.findUnique({
      where: {
        studentId_attendanceDate: { studentId, attendanceDate: targetDate },
      },
    });
    const plans = await this.prisma.studyPlan.findMany({
      where: { studentId, planDate: targetDate },
    });
    const sessions = await this.prisma.studySession.findMany({
      where: { studentId, sessionDate: targetDate },
    });
    const logs = await this.prisma.studyLog.findMany({
      where: { studentId, logDate: targetDate },
    });

    const studyMinutes = sessions.reduce(
      (sum, item) => sum + item.studyMinutes,
      0,
    );
    const breakMinutes = sessions.reduce(
      (sum, item) => sum + item.breakMinutes,
      0,
    );
    const targetMinutes = plans.reduce(
      (sum, item) => sum + item.targetMinutes,
      0,
    );
    const achievedRate =
      targetMinutes === 0
        ? 0
        : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));
    const subjectMap = new Map<string, number>();
    logs.forEach((log) =>
      subjectMap.set(
        log.subjectName,
        (subjectMap.get(log.subjectName) ?? 0) + log.pagesCompleted,
      ),
    );
    sessions.forEach((session) => {
      if (session.linkedPlanId) {
        // no-op; sessions are already counted in studyMinutes aggregate
      }
    });

    return {
      success: true,
      data: {
        date: targetDate.toISOString().slice(0, 10),
        attendanceMinutes: attendance?.stayMinutes ?? 0,
        studyMinutes,
        breakMinutes,
        targetMinutes,
        achievedRate,
        attendanceStatus:
          attendance?.attendanceStatus ?? AttendanceStatus.ABSENT,
        subjectBreakdown: Array.from(subjectMap.entries()).map(
          ([subjectName, pagesCompleted]) => ({
            subjectName,
            pagesCompleted,
          }),
        ),
        logs,
      },
      meta: {},
    };
  }

  async weekly(studentId: string, startDate?: string) {
    const start = weekStart(startDate);
    const end = endOfDay(
      new Date(start.getFullYear(), start.getMonth(), start.getDate() + 6),
    );

    const [sessions, attendances, logs, plans] = await Promise.all([
      this.prisma.studySession.findMany({
        where: { studentId, sessionDate: { gte: start, lte: end } },
      }),
      this.prisma.attendance.findMany({
        where: { studentId, attendanceDate: { gte: start, lte: end } },
      }),
      this.prisma.studyLog.findMany({
        where: { studentId, logDate: { gte: start, lte: end } },
      }),
      this.prisma.studyPlan.findMany({
        where: { studentId, planDate: { gte: start, lte: end } },
      }),
    ]);

    return {
      success: true,
      data: {
        weekStartDate: start.toISOString().slice(0, 10),
        studyMinutes: sessions.reduce(
          (sum, item) => sum + item.studyMinutes,
          0,
        ),
        attendanceDays: attendances.filter(
          (item) => item.attendanceStatus !== AttendanceStatus.ABSENT,
        ).length,
        targetMinutes: plans.reduce((sum, item) => sum + item.targetMinutes, 0),
        pagesCompleted: logs.reduce(
          (sum, item) => sum + item.pagesCompleted,
          0,
        ),
        problemsSolved: logs.reduce(
          (sum, item) => sum + item.problemsSolved,
          0,
        ),
      },
      meta: {},
    };
  }

  async monthly(studentId: string, month?: string) {
    const key = month ?? monthKey();
    const [year, monthNumber] = key.split('-').map(Number);
    const start = startOfDay(new Date(year, monthNumber - 1, 1));
    const end = endOfDay(new Date(year, monthNumber, 0));

    const [sessions, attendances, logs, plans] = await Promise.all([
      this.prisma.studySession.findMany({
        where: { studentId, sessionDate: { gte: start, lte: end } },
      }),
      this.prisma.attendance.findMany({
        where: { studentId, attendanceDate: { gte: start, lte: end } },
      }),
      this.prisma.studyLog.findMany({
        where: { studentId, logDate: { gte: start, lte: end } },
      }),
      this.prisma.studyPlan.findMany({
        where: { studentId, planDate: { gte: start, lte: end } },
      }),
    ]);

    return {
      success: true,
      data: {
        month: key,
        studyMinutes: sessions.reduce(
          (sum, item) => sum + item.studyMinutes,
          0,
        ),
        attendanceDays: attendances.filter(
          (item) => item.attendanceStatus !== AttendanceStatus.ABSENT,
        ).length,
        targetMinutes: plans.reduce((sum, item) => sum + item.targetMinutes, 0),
        pagesCompleted: logs.reduce(
          (sum, item) => sum + item.pagesCompleted,
          0,
        ),
        problemsSolved: logs.reduce(
          (sum, item) => sum + item.problemsSolved,
          0,
        ),
      },
      meta: {},
    };
  }
}
