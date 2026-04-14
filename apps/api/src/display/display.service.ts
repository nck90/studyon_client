import { Injectable } from '@nestjs/common';
import { RankingPeriodType, RankingType } from '@prisma/client';
import { diffMinutes, startOfDay } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { RankingsService } from '@/rankings/rankings.service';
import { SettingsService } from '@/settings/settings.service';

@Injectable()
export class DisplayService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rankingsService: RankingsService,
    private readonly settingsService: SettingsService,
  ) {}

  current() {
    return this.settingsService.getTvDisplay();
  }

  rankings(
    periodType: RankingPeriodType = RankingPeriodType.DAILY,
    rankingType: RankingType = RankingType.STUDY_TIME,
  ) {
    return this.rankingsService.adminRanking(periodType, rankingType);
  }

  async status() {
    const [checkedInCount, totalSeats, occupiedSeats, sessions] =
      await Promise.all([
        this.prisma.attendance.count({
          where: {
            attendanceStatus: 'CHECKED_IN',
            attendanceDate: startOfDay(),
          },
        }),
        this.prisma.seat.count({ where: { isActive: true } }),
        this.prisma.seat.count({ where: { status: 'OCCUPIED' } }),
        this.prisma.studySession.findMany({
          where: { sessionDate: startOfDay() },
          include: { studyBreaks: true },
        }),
      ]);

    const now = new Date();
    const sessionStudyMinutes = sessions.reduce((sum, session) => {
      if (!session.startedAt) {
        return sum + session.studyMinutes;
      }

      const breakMinutes =
        session.breakMinutes +
        session.studyBreaks
          .filter((item) => !item.endedAt)
          .reduce((carry, item) => carry + diffMinutes(item.startedAt, now), 0);

      if (session.endedAt) {
        return sum + session.studyMinutes;
      }

      const elapsed = diffMinutes(session.startedAt, now);
      return sum + Math.max(0, elapsed - breakMinutes);
    }, 0);
    const liveStudyMinutes = sessions
      .filter((item) => item.status === 'ACTIVE' && item.startedAt)
      .reduce((sum, session) => {
        const openBreakMinutes = session.studyBreaks
          .filter((item) => !item.endedAt)
          .reduce((carry, item) => carry + diffMinutes(item.startedAt, now), 0);
        return (
          sum +
          Math.max(
            0,
            diffMinutes(session.startedAt, now) -
              session.breakMinutes -
              openBreakMinutes,
          )
        );
      }, 0);

    return {
      success: true,
      data: {
        checkedInCount,
        seatOccupancyRate:
          totalSeats === 0
            ? 0
            : Number(((occupiedSeats / totalSeats) * 100).toFixed(2)),
        liveStudyMinutes,
        todayTotalStudyMinutes: sessionStudyMinutes,
      },
      meta: {},
    };
  }

  async motivation() {
    const topStudent = await this.prisma.rankingSnapshotItem.findFirst({
      orderBy: [{ createdAt: 'desc' }, { rankNo: 'asc' }],
      include: { student: { include: { user: true } } },
    });

    return {
      success: true,
      data: {
        message: '오늘 목표를 끝까지 완수하세요.',
        topStudent: topStudent
          ? {
              name: topStudent.student.user.name,
              rankNo: topStudent.rankNo,
              score: Number(topStudent.score),
            }
          : null,
        challenge: '연속 출석 7일 챌린지 진행 중',
      },
      meta: {},
    };
  }

  control(activeScreen: string) {
    return this.settingsService.updateTvDisplay({ activeScreen });
  }
}
