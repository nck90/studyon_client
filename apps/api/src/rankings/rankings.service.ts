import { Injectable } from '@nestjs/common';
import { RankingPeriodType, RankingType } from '@prisma/client';
import { monthKey, startOfDay, weekStart } from '@/common/utils/date.util';
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
        myRank: myRank
          ? {
              rankNo: myRank.rankNo,
              score: Number(myRank.score),
            }
          : {
              rankNo: 0,
              score: 0,
            },
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

    const students = await this.prisma.student.findMany({
      include: { user: true },
    });
    const scoreMap = await this.buildScoreMap(periodType, rankingType);
    const scores = students.map((student) => ({
      studentId: student.id,
      score: scoreMap.get(student.id) ?? 0,
    }));

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

  private async buildScoreMap(
    periodType: RankingPeriodType,
    rankingType: RankingType,
  ) {
    if (periodType === RankingPeriodType.DAILY) {
      const today = startOfDay(new Date());
      const metrics = await this.prisma.dailyStudentMetric.findMany({
        where: { metricDate: today },
      });
      return new Map(
        metrics.map((metric) => [
          metric.studentId,
          rankingType === RankingType.STUDY_TIME
            ? metric.studyMinutes
            : rankingType === RankingType.STUDY_VOLUME
              ? metric.pagesCompleted + metric.problemsSolved
              : metric.streakDays,
        ]),
      );
    }

    if (periodType === RankingPeriodType.WEEKLY) {
      const metrics = await this.prisma.weeklyStudentMetric.findMany({
        where: { weekStartDate: weekStart() },
      });
      return new Map(
        metrics.map((metric) => [
          metric.studentId,
          rankingType === RankingType.STUDY_TIME
            ? metric.studyMinutes
            : rankingType === RankingType.STUDY_VOLUME
              ? metric.pagesCompleted + metric.problemsSolved
              : metric.attendanceDays,
        ]),
      );
    }

    const metrics = await this.prisma.monthlyStudentMetric.findMany({
      where: { monthKey: monthKey() },
    });
    return new Map(
      metrics.map((metric) => [
        metric.studentId,
        rankingType === RankingType.STUDY_TIME
          ? metric.studyMinutes
          : rankingType === RankingType.STUDY_VOLUME
            ? metric.pagesCompleted + metric.problemsSolved
            : metric.attendanceDays,
      ]),
    );
  }
}
