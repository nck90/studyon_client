import { Injectable, NotFoundException } from '@nestjs/common';
import { AttendanceStatus } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';

@Injectable()
export class InsightsService {
  constructor(private readonly prisma: PrismaService) {}

  async listRiskStudents(classId?: string) {
    const students = await this.prisma.student.findMany({
      where: { classId: classId ?? undefined, enrollmentStatus: 'ACTIVE' },
      include: { user: true, class: true },
    });

    const data = await Promise.all(
      students.map(async (student) => this.buildStudentInsight(student.id)),
    );

    return {
      success: true,
      data: data.sort(
        (a, b) => this.riskScore(b.riskLevel) - this.riskScore(a.riskLevel),
      ),
      meta: {},
    };
  }

  async studentInsight(studentId: string) {
    const result = await this.buildStudentInsight(studentId);
    return { success: true, data: result, meta: {} };
  }

  async studentRecommendation(studentId: string) {
    const insight = await this.buildStudentInsight(studentId);
    return {
      success: true,
      data: {
        recommendedTargetMinutes: insight.recommendedTargetMinutes,
        recommendedFocusSubjects: insight.recommendedFocusSubjects,
        recommendedPlanTemplate: insight.recommendedPlanTemplate,
        riskLevel: insight.riskLevel,
      },
      meta: {},
    };
  }

  private async buildStudentInsight(studentId: string) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      include: { user: true, class: true },
    });
    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }

    const [metrics, logs] = await Promise.all([
      this.prisma.dailyStudentMetric.findMany({
        where: { studentId },
        orderBy: { metricDate: 'desc' },
        take: 14,
      }),
      this.prisma.studyLog.findMany({
        where: { studentId },
        orderBy: { logDate: 'desc' },
        take: 30,
      }),
    ]);

    const attendanceDays = metrics.filter(
      (item) =>
        item.attendanceStatus === AttendanceStatus.CHECKED_IN ||
        item.attendanceStatus === AttendanceStatus.CHECKED_OUT,
    ).length;
    const attendanceRate =
      metrics.length === 0
        ? 0
        : Number(((attendanceDays / metrics.length) * 100).toFixed(2));
    const averageStudyMinutes =
      metrics.length === 0
        ? 0
        : Number(
            (
              metrics.reduce((sum, item) => sum + item.studyMinutes, 0) /
              metrics.length
            ).toFixed(2),
          );
    const averageAchievedRate =
      metrics.length === 0
        ? 0
        : Number(
            (
              metrics.reduce(
                (sum, item) => sum + Number(item.achievedRate),
                0,
              ) / metrics.length
            ).toFixed(2),
          );
    const streakDays = metrics[0]?.streakDays ?? 0;
    const riskLevel =
      attendanceRate < 60 ||
      averageStudyMinutes < 90 ||
      averageAchievedRate < 50
        ? 'HIGH'
        : attendanceRate < 80 ||
            averageStudyMinutes < 180 ||
            averageAchievedRate < 75
          ? 'MEDIUM'
          : 'LOW';

    const subjectStats = new Map<
      string,
      { pages: number; problems: number; completionCount: number }
    >();
    for (const log of logs) {
      const current = subjectStats.get(log.subjectName) ?? {
        pages: 0,
        problems: 0,
        completionCount: 0,
      };
      current.pages += log.pagesCompleted;
      current.problems += log.problemsSolved;
      current.completionCount += log.isCompleted ? 1 : 0;
      subjectStats.set(log.subjectName, current);
    }

    const recommendedFocusSubjects = [...subjectStats.entries()]
      .sort((a, b) => a[1].completionCount - b[1].completionCount)
      .slice(0, 3)
      .map(([subjectName]) => subjectName);

    const recommendedTargetMinutes = Math.min(
      480,
      Math.max(60, Math.round(averageStudyMinutes * 1.15 || 180)),
    );

    return {
      studentId: student.id,
      studentName: student.user.name,
      className: student.class?.name ?? null,
      riskLevel,
      attendanceRate,
      averageStudyMinutes,
      averageAchievedRate,
      streakDays,
      recommendedTargetMinutes,
      recommendedFocusSubjects:
        recommendedFocusSubjects.length > 0
          ? recommendedFocusSubjects
          : ['수학', '영어'],
      recommendedPlanTemplate: [
        {
          subjectName: recommendedFocusSubjects[0] ?? '수학',
          title: `${recommendedFocusSubjects[0] ?? '수학'} 핵심 개념 복습`,
          targetMinutes: Math.round(recommendedTargetMinutes * 0.4),
        },
        {
          subjectName: recommendedFocusSubjects[1] ?? '영어',
          title: `${recommendedFocusSubjects[1] ?? '영어'} 문제풀이`,
          targetMinutes: Math.round(recommendedTargetMinutes * 0.35),
        },
        {
          subjectName: recommendedFocusSubjects[2] ?? '국어',
          title: `${recommendedFocusSubjects[2] ?? '국어'} 오답 정리`,
          targetMinutes: Math.round(recommendedTargetMinutes * 0.25),
        },
      ],
    };
  }

  private riskScore(level: string) {
    return level === 'HIGH' ? 3 : level === 'MEDIUM' ? 2 : 1;
  }
}
