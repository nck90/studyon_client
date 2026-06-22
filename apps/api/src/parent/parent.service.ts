import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuditService } from '@/audit/audit.service';
import { dateOnly, endOfDay, startOfDay } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';

type ParentAccessPayload = {
  sub: string;
  studentId: string;
  tokenType: 'parent_access';
};

@Injectable()
export class ParentService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly audit: AuditService,
  ) {}

  async issueAccessToken(
    actorUserId: string,
    studentId: string,
    expiresInDays = 30,
  ) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      include: { user: true, class: true },
    });
    if (!student) {
      throw new BadRequestException('학생을 찾을 수 없습니다.');
    }

    const token = await this.jwtService.signAsync(
      {
        sub: student.userId,
        studentId,
        tokenType: 'parent_access',
      } satisfies ParentAccessPayload,
      {
        secret: process.env.PARENT_PORTAL_SECRET!,
        expiresIn: `${expiresInDays}d`,
      },
    );

    await this.audit.log({
      actorUserId,
      actionType: 'PARENT_ACCESS_ISSUED',
      targetType: 'student',
      targetId: studentId,
      afterData: { expiresInDays },
    });

    return {
      success: true,
      data: {
        token,
        expiresInDays,
        student: {
          id: student.id,
          studentNo: student.studentNo,
          name: student.user.name,
          className: student.class?.name ?? null,
        },
      },
      meta: {},
    };
  }

  async getOverview(token?: string) {
    const payload = await this.verifyToken(token);
    const today = dateOnly();
    const [student, attendance, dailyMetric, plans] = await Promise.all([
      this.prisma.student.findUnique({
        where: { id: payload.studentId },
        include: {
          user: true,
          grade: true,
          class: true,
          group: true,
          assignedSeat: true,
        },
      }),
      this.prisma.attendance.findUnique({
        where: {
          studentId_attendanceDate: {
            studentId: payload.studentId,
            attendanceDate: today,
          },
        },
      }),
      this.prisma.dailyStudentMetric.findUnique({
        where: {
          studentId_metricDate: {
            studentId: payload.studentId,
            metricDate: today,
          },
        },
      }),
      this.prisma.studyPlan.findMany({
        where: { studentId: payload.studentId, planDate: today },
      }),
    ]);

    return {
      success: true,
      data: {
        student,
        todayAttendance: attendance,
        todayMetric: dailyMetric,
        todayPlans: plans,
      },
      meta: {},
    };
  }

  async getAttendance(token?: string, startDate?: string, endDate?: string) {
    const payload = await this.verifyToken(token);
    const data = await this.prisma.attendance.findMany({
      where: {
        studentId: payload.studentId,
        attendanceDate: {
          gte: startDate ? startOfDay(startDate) : undefined,
          lte: endDate ? endOfDay(endDate) : undefined,
        },
      },
      orderBy: { attendanceDate: 'desc' },
      take: 90,
    });

    return { success: true, data, meta: {} };
  }

  async getStudyReport(token?: string, startDate?: string, endDate?: string) {
    const payload = await this.verifyToken(token);
    const [dailyMetrics, logs] = await Promise.all([
      this.prisma.dailyStudentMetric.findMany({
        where: {
          studentId: payload.studentId,
          metricDate: {
            gte: startDate ? startOfDay(startDate) : undefined,
            lte: endDate ? endOfDay(endDate) : undefined,
          },
        },
        orderBy: { metricDate: 'desc' },
        take: 90,
      }),
      this.prisma.studyLog.findMany({
        where: {
          studentId: payload.studentId,
          logDate: {
            gte: startDate ? startOfDay(startDate) : undefined,
            lte: endDate ? endOfDay(endDate) : undefined,
          },
        },
        orderBy: { logDate: 'desc' },
        take: 90,
      }),
    ]);

    return {
      success: true,
      data: {
        totalStudyMinutes: dailyMetrics.reduce(
          (sum, item) => sum + item.studyMinutes,
          0,
        ),
        averageAchievedRate:
          dailyMetrics.length === 0
            ? 0
            : Number(
                (
                  dailyMetrics.reduce(
                    (sum, item) => sum + Number(item.achievedRate),
                    0,
                  ) / dailyMetrics.length
                ).toFixed(2),
              ),
        totalPagesCompleted: dailyMetrics.reduce(
          (sum, item) => sum + item.pagesCompleted,
          0,
        ),
        totalProblemsSolved: dailyMetrics.reduce(
          (sum, item) => sum + item.problemsSolved,
          0,
        ),
        recentMetrics: dailyMetrics,
        recentLogs: logs,
      },
      meta: {},
    };
  }

  async getActionReport(authorization?: string, queryToken?: string) {
    const token =
      queryToken?.trim() ||
      authorization?.replace(/^Bearer\s+/i, '').trim() ||
      '';
    if (!token) {
      throw new UnauthorizedException('학부모 조치 리포트 토큰이 필요합니다.');
    }

    const report = await this.prisma.parentActionReport.findUnique({
      where: { tokenId: token },
      include: {
        task: true,
        student: {
          include: { user: true, grade: true, class: true, group: true },
        },
      },
    });
    if (!report || report.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException(
        '만료되었거나 유효하지 않은 리포트입니다.',
      );
    }

    if (!report.viewedAt) {
      await this.prisma.parentActionReport.update({
        where: { id: report.id },
        data: { viewedAt: new Date() },
      });
    }

    const today = dateOnly();
    const sevenDaysAgo = new Date(today);
    sevenDaysAgo.setUTCDate(sevenDaysAgo.getUTCDate() - 6);
    const [attendance, metric, mission, recentMetrics, focusMetric, policy] =
      await Promise.all([
        this.prisma.attendance.findUnique({
          where: {
            studentId_attendanceDate: {
              studentId: report.studentId,
              attendanceDate: today,
            },
          },
        }),
        this.prisma.dailyStudentMetric.findUnique({
          where: {
            studentId_metricDate: {
              studentId: report.studentId,
              metricDate: today,
            },
          },
        }),
        this.prisma.studentDailyMission.findUnique({
          where: {
            studentId_missionDate: {
              studentId: report.studentId,
              missionDate: today,
            },
          },
        }),
        this.prisma.dailyStudentMetric.findMany({
          where: {
            studentId: report.studentId,
            metricDate: { gte: sevenDaysAgo, lte: today },
          },
          orderBy: { metricDate: 'asc' },
        }),
        this.prisma.studentFocusMetric.findUnique({
          where: {
            studentId_metricDate: {
              studentId: report.studentId,
              metricDate: report.task.taskDate,
            },
          },
        }),
        this.prisma.focusPolicy.findFirst({ orderBy: { createdAt: 'asc' } }),
      ]);
    const parentThreshold = policy?.parentReportThreshold ?? 3;
    const focusSummary =
      report.task.reasonType === 'FOCUS_INTERRUPTION' &&
      focusMetric &&
      focusMetric.eventCount >= parentThreshold
        ? {
            eventCount: focusMetric.eventCount,
            returnCount: focusMetric.returnCount,
            totalAwaySeconds: focusMetric.totalAwaySeconds,
            longestAwaySeconds: focusMetric.longestAwaySeconds,
            averageReturnSeconds:
              focusMetric.returnCount === 0
                ? 0
                : Math.round(
                    focusMetric.totalAwaySeconds / focusMetric.returnCount,
                  ),
            lastEventAt: focusMetric.lastEventAt?.toISOString() ?? null,
          }
        : null;

    return {
      success: true,
      data: {
        report: {
          id: report.id,
          message: report.message,
          expiresAt: report.expiresAt.toISOString(),
          viewedAt: (report.viewedAt ?? new Date()).toISOString(),
          createdAt: report.createdAt.toISOString(),
        },
        task: {
          id: report.task.id,
          taskDate: report.task.taskDate.toISOString(),
          reasonType: report.task.reasonType,
          severity: report.task.severity,
          status: report.task.status,
          message: report.task.message,
          sourceSnapshot: report.task.sourceSnapshot,
        },
        student: {
          id: report.student.id,
          studentNo: report.student.studentNo,
          name: report.student.user.name,
          gradeName: report.student.grade?.name ?? null,
          className: report.student.class?.name ?? null,
          groupName: report.student.group?.name ?? null,
        },
        todayAttendance: attendance,
        todayMetric: metric,
        todayMission: mission,
        recentMetrics,
        focusSummary,
      },
      meta: {},
    };
  }

  async getConsultationReport(queryToken?: string) {
    const token = queryToken?.trim() || '';
    if (!token) {
      throw new UnauthorizedException('상담 리포트 토큰이 필요합니다.');
    }
    const report = await this.prisma.parentConsultationReport.findUnique({
      where: { tokenId: token },
      include: {
        consultation: {
          include: {
            guardian: true,
            followUps: { orderBy: { dueAt: 'asc' }, take: 5 },
          },
        },
        student: {
          include: { user: true, grade: true, class: true, group: true },
        },
        guardian: true,
      },
    });
    if (!report || report.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException(
        '만료되었거나 유효하지 않은 리포트입니다.',
      );
    }
    if (!report.viewedAt) {
      await this.prisma.parentConsultationReport.update({
        where: { id: report.id },
        data: { viewedAt: new Date() },
      });
    }

    const today = dateOnly();
    const sevenDaysAgo = new Date(today);
    sevenDaysAgo.setUTCDate(sevenDaysAgo.getUTCDate() - 6);
    const [recentMetrics, recentAttendances, mission, focusMetric] =
      await Promise.all([
        this.prisma.dailyStudentMetric.findMany({
          where: {
            studentId: report.studentId,
            metricDate: { gte: sevenDaysAgo, lte: today },
          },
          orderBy: { metricDate: 'asc' },
        }),
        this.prisma.attendance.findMany({
          where: {
            studentId: report.studentId,
            attendanceDate: { gte: sevenDaysAgo, lte: today },
          },
          orderBy: { attendanceDate: 'asc' },
        }),
        this.prisma.studentDailyMission.findUnique({
          where: {
            studentId_missionDate: {
              studentId: report.studentId,
              missionDate: today,
            },
          },
        }),
        this.prisma.studentFocusMetric.findUnique({
          where: {
            studentId_metricDate: {
              studentId: report.studentId,
              metricDate: today,
            },
          },
        }),
      ]);

    return {
      success: true,
      data: {
        report: {
          id: report.id,
          message: report.message,
          expiresAt: report.expiresAt.toISOString(),
          viewedAt: (report.viewedAt ?? new Date()).toISOString(),
          createdAt: report.createdAt.toISOString(),
        },
        student: {
          id: report.student.id,
          studentNo: report.student.studentNo,
          name: report.student.user.name,
          gradeName: report.student.grade?.name ?? null,
          className: report.student.class?.name ?? null,
          groupName: report.student.group?.name ?? null,
        },
        guardian: report.guardian
          ? {
              id: report.guardian.id,
              name: report.guardian.name,
              relation: report.guardian.relation,
            }
          : null,
        consultation: {
          id: report.consultation.id,
          contactType: report.consultation.contactType,
          direction: report.consultation.direction,
          occurredAt: report.consultation.occurredAt.toISOString(),
          summary: report.consultation.summary,
          detail: report.consultation.detail,
          promisedAction: report.consultation.promisedAction,
          followUps: report.consultation.followUps.map((task) => ({
            id: task.id,
            title: task.title,
            dueAt: task.dueAt.toISOString(),
            status: task.status,
          })),
        },
        recentMetrics,
        recentAttendances,
        todayMission: mission,
        focusSummary: focusMetric
          ? {
              eventCount: focusMetric.eventCount,
              returnCount: focusMetric.returnCount,
              averageReturnSeconds:
                focusMetric.returnCount === 0
                  ? 0
                  : Math.round(
                      focusMetric.totalAwaySeconds / focusMetric.returnCount,
                    ),
              longestAwaySeconds: focusMetric.longestAwaySeconds,
            }
          : null,
      },
      meta: {},
    };
  }

  private async verifyToken(authorization?: string) {
    const token = authorization?.replace(/^Bearer\s+/i, '').trim();
    if (!token) {
      throw new UnauthorizedException('학부모 접근 토큰이 필요합니다.');
    }

    try {
      const payload = await this.jwtService.verifyAsync<ParentAccessPayload>(
        token,
        {
          secret: process.env.PARENT_PORTAL_SECRET!,
        },
      );

      if (payload.tokenType !== 'parent_access') {
        throw new UnauthorizedException('유효하지 않은 토큰입니다.');
      }

      return payload;
    } catch {
      throw new UnauthorizedException('유효하지 않은 토큰입니다.');
    }
  }
}
