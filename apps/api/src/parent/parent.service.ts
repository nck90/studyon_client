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
