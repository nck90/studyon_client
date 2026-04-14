import { Injectable } from '@nestjs/common';
import { RankingPeriodType, RankingType } from '@prisma/client';
import {
  endOfDay,
  monthKey,
  startOfDay,
  weekStart,
} from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { MetricsService } from '@/metrics/metrics.service';

@Injectable()
export class RankingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly metricsService: MetricsService,
  ) {}

  async studentRanking(
    studentId: string,
    periodType: RankingPeriodType,
    rankingType: RankingType,
  ) {
    const snapshot = await this.ensureSnapshot(periodType, rankingType);
    const items = await this.prisma.rankingSnapshotItem.findMany({
      where: { rankingSnapshotId: snapshot.id },
      include: { student: { include: { user: true } } },
      orderBy: { rankNo: 'asc' },
      take: 50,
    });

    const myRank = items.find((item) => item.studentId === studentId) ?? null;
    return {
      success: true,
      data: {
        myRank,
        items: items.map((item) => ({
          studentId: item.studentId,
          studentName: item.student.user.name,
          rankNo: item.rankNo,
          score: Number(item.score),
        })),
      },
      meta: {},
    };
  }

  async adminRanking(periodType: RankingPeriodType, rankingType: RankingType) {
    const snapshot = await this.ensureSnapshot(periodType, rankingType);
    const items = await this.prisma.rankingSnapshotItem.findMany({
      where: { rankingSnapshotId: snapshot.id },
      include: { student: { include: { user: true } } },
      orderBy: { rankNo: 'asc' },
    });

    return { success: true, data: { snapshot, items }, meta: {} };
  }

  async ensureSnapshot(
    periodType: RankingPeriodType,
    rankingType: RankingType,
  ) {
    const key =
      periodType === RankingPeriodType.DAILY
        ? new Date().toISOString().slice(0, 10)
        : periodType === RankingPeriodType.WEEKLY
          ? weekStart().toISOString().slice(0, 10)
          : monthKey();
    const range =
      periodType === RankingPeriodType.DAILY
        ? {
            start: startOfDay(new Date()),
            end: endOfDay(new Date()),
          }
        : periodType === RankingPeriodType.WEEKLY
          ? {
              start: weekStart(),
              end: endOfDay(
                new Date(
                  weekStart().getFullYear(),
                  weekStart().getMonth(),
                  weekStart().getDate() + 6,
                ),
              ),
            }
          : (() => {
              const keyDate = new Date(`${monthKey()}-01T00:00:00`);
              return {
                start: startOfDay(keyDate),
                end: endOfDay(
                  new Date(keyDate.getFullYear(), keyDate.getMonth() + 1, 0),
                ),
              };
            })();

    await this.metricsService.refreshForDate(startOfDay(new Date()));

    let snapshot = await this.prisma.rankingSnapshot.findFirst({
      where: { periodType, rankingType, periodKey: key },
    });

    if (!snapshot) {
      snapshot = await this.prisma.rankingSnapshot.create({
        data: { periodType, rankingType, periodKey: key },
      });
    } else {
      snapshot = await this.prisma.rankingSnapshot.update({
        where: { id: snapshot.id },
        data: { generatedAt: new Date() },
      });
      await this.prisma.rankingSnapshotItem.deleteMany({
        where: { rankingSnapshotId: snapshot.id },
      });
    }

    const metrics = await this.prisma.dailyStudentMetric.findMany({
      where: { metricDate: { gte: range.start, lte: range.end } },
    });
    const students = await this.prisma.student.findMany({
      include: { user: true },
    });
    const scores = students.map((student) => {
      const studentMetrics = metrics.filter(
        (item) => item.studentId === student.id,
      );
      if (rankingType === RankingType.STUDY_TIME) {
        return {
          studentId: student.id,
          score: studentMetrics.reduce(
            (sum, item) => sum + item.studyMinutes,
            0,
          ),
        };
      }
      if (rankingType === RankingType.STUDY_VOLUME) {
        return {
          studentId: student.id,
          score: studentMetrics.reduce(
            (sum, item) => sum + item.pagesCompleted + item.problemsSolved,
            0,
          ),
        };
      }
      const latestMetric = studentMetrics.sort(
        (a, b) => a.metricDate.getTime() - b.metricDate.getTime(),
      )[studentMetrics.length - 1];
      return { studentId: student.id, score: latestMetric?.streakDays ?? 0 };
    });

    scores.sort((a, b) => b.score - a.score);
    await this.prisma.rankingSnapshotItem.createMany({
      data: scores.map((item, index) => ({
        rankingSnapshotId: snapshot.id,
        studentId: item.studentId,
        rankNo: index + 1,
        score: item.score,
        subScore1: 0,
        subScore2: 0,
      })),
    });

    return snapshot;
  }
}
