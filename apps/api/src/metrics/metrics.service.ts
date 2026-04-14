import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
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
export class MetricsService {
  constructor(private readonly prisma: PrismaService) {}

  @Cron('0 */10 * * * *')
  async refreshTodayMetrics() {
    await this.refreshForDate(dateOnly());
  }

  async refreshForDate(targetDate: Date) {
    const students = await this.prisma.student.findMany({
      select: { id: true },
    });

    for (const student of students) {
      await this.refreshStudentMetrics(student.id, targetDate);
    }
  }

  async refreshStudentMetrics(studentId: string, targetDate: Date) {
    const [attendance, sessions, logs, plans] = await Promise.all([
      this.prisma.attendance.findUnique({
        where: {
          studentId_attendanceDate: { studentId, attendanceDate: targetDate },
        },
      }),
      this.prisma.studySession.findMany({
        where: { studentId, sessionDate: targetDate },
      }),
      this.prisma.studyLog.findMany({
        where: { studentId, logDate: targetDate },
      }),
      this.prisma.studyPlan.findMany({
        where: { studentId, planDate: targetDate },
      }),
    ]);

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
    const pagesCompleted = logs.reduce(
      (sum, item) => sum + item.pagesCompleted,
      0,
    );
    const problemsSolved = logs.reduce(
      (sum, item) => sum + item.problemsSolved,
      0,
    );
    const attendanceStatus =
      attendance?.attendanceStatus ?? AttendanceStatus.ABSENT;
    const achievedRate =
      targetMinutes === 0
        ? 0
        : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));
    const previousDate = dateOnly(
      new Date(targetDate.getTime() - 24 * 60 * 60 * 1000),
    );
    const previousMetric = await this.prisma.dailyStudentMetric.findUnique({
      where: {
        studentId_metricDate: { studentId, metricDate: previousDate },
      },
    });
    const streakDays =
      attendanceStatus === AttendanceStatus.CHECKED_IN ||
      attendanceStatus === AttendanceStatus.CHECKED_OUT
        ? (previousMetric?.streakDays ?? 0) + 1
        : 0;

    await this.prisma.dailyStudentMetric.upsert({
      where: {
        studentId_metricDate: { studentId, metricDate: targetDate },
      },
      update: {
        attendanceMinutes: attendance?.stayMinutes ?? 0,
        studyMinutes,
        breakMinutes,
        targetMinutes,
        achievedRate,
        pagesCompleted,
        problemsSolved,
        studySessionCount: sessions.length,
        attendanceStatus,
        streakDays,
      },
      create: {
        studentId,
        metricDate: targetDate,
        attendanceMinutes: attendance?.stayMinutes ?? 0,
        studyMinutes,
        breakMinutes,
        targetMinutes,
        achievedRate,
        pagesCompleted,
        problemsSolved,
        studySessionCount: sessions.length,
        attendanceStatus,
        streakDays,
      },
    });

    await this.refreshWeeklyMetric(studentId, targetDate);
    await this.refreshMonthlyMetric(studentId, targetDate);
  }

  private async refreshWeeklyMetric(studentId: string, targetDate: Date) {
    const start = weekStart(targetDate);
    const end = endOfDay(
      new Date(start.getFullYear(), start.getMonth(), start.getDate() + 6),
    );
    const metrics = await this.prisma.dailyStudentMetric.findMany({
      where: { studentId, metricDate: { gte: start, lte: end } },
    });
    const studyMinutes = metrics.reduce(
      (sum, item) => sum + item.studyMinutes,
      0,
    );
    const attendanceDays = metrics.filter(
      (item) =>
        item.attendanceStatus === AttendanceStatus.CHECKED_IN ||
        item.attendanceStatus === AttendanceStatus.CHECKED_OUT,
    ).length;
    const targetMinutes = metrics.reduce(
      (sum, item) => sum + item.targetMinutes,
      0,
    );
    const pagesCompleted = metrics.reduce(
      (sum, item) => sum + item.pagesCompleted,
      0,
    );
    const problemsSolved = metrics.reduce(
      (sum, item) => sum + item.problemsSolved,
      0,
    );
    const achievedRate =
      targetMinutes === 0
        ? 0
        : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));

    await this.prisma.weeklyStudentMetric.upsert({
      where: { studentId_weekStartDate: { studentId, weekStartDate: start } },
      update: {
        studyMinutes,
        attendanceDays,
        targetMinutes,
        achievedRate,
        pagesCompleted,
        problemsSolved,
      },
      create: {
        studentId,
        weekStartDate: start,
        studyMinutes,
        attendanceDays,
        targetMinutes,
        achievedRate,
        pagesCompleted,
        problemsSolved,
      },
    });
  }

  private async refreshMonthlyMetric(studentId: string, targetDate: Date) {
    const key = monthKey(targetDate);
    const [year, monthNumber] = key.split('-').map(Number);
    const start = startOfDay(new Date(year, monthNumber - 1, 1));
    const end = endOfDay(new Date(year, monthNumber, 0));
    const metrics = await this.prisma.dailyStudentMetric.findMany({
      where: { studentId, metricDate: { gte: start, lte: end } },
    });
    const studyMinutes = metrics.reduce(
      (sum, item) => sum + item.studyMinutes,
      0,
    );
    const attendanceDays = metrics.filter(
      (item) =>
        item.attendanceStatus === AttendanceStatus.CHECKED_IN ||
        item.attendanceStatus === AttendanceStatus.CHECKED_OUT,
    ).length;
    const targetMinutes = metrics.reduce(
      (sum, item) => sum + item.targetMinutes,
      0,
    );
    const pagesCompleted = metrics.reduce(
      (sum, item) => sum + item.pagesCompleted,
      0,
    );
    const problemsSolved = metrics.reduce(
      (sum, item) => sum + item.problemsSolved,
      0,
    );
    const achievedRate =
      targetMinutes === 0
        ? 0
        : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));

    await this.prisma.monthlyStudentMetric.upsert({
      where: { studentId_monthKey: { studentId, monthKey: key } },
      update: {
        studyMinutes,
        attendanceDays,
        targetMinutes,
        achievedRate,
        pagesCompleted,
        problemsSolved,
      },
      create: {
        studentId,
        monthKey: key,
        studyMinutes,
        attendanceDays,
        targetMinutes,
        achievedRate,
        pagesCompleted,
        problemsSolved,
      },
    });
  }
}
