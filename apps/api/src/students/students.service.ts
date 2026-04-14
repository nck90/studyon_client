import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '@/database/prisma.service';
import { dateOnly } from '@/common/utils/date.util';

@Injectable()
export class StudentsService {
  constructor(private readonly prisma: PrismaService) {}

  async getStudentHome(studentId: string) {
    const today = dateOnly();
    const [student, attendance, activeSession, plans, notifications] =
      await Promise.all([
        this.prisma.student.findUnique({
          where: { id: studentId },
          include: { user: true, assignedSeat: true, class: true },
        }),
        this.prisma.attendance.findUnique({
          where: {
            studentId_attendanceDate: { studentId, attendanceDate: today },
          },
        }),
        this.prisma.studySession.findFirst({
          where: { studentId, status: { in: ['ACTIVE', 'PAUSED'] } },
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.studyPlan.findMany({
          where: { studentId, planDate: today },
        }),
        this.prisma.notificationReceipt.findMany({
          where: { user: { student: { id: studentId } } },
          include: { notification: true },
          take: 5,
          orderBy: { createdAt: 'desc' },
        }),
      ]);

    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }

    return {
      success: true,
      data: {
        todayAttendance: attendance,
        seat: student.assignedSeat
          ? {
              seatId: student.assignedSeat.id,
              seatNo: student.assignedSeat.seatNo,
              status: student.assignedSeat.status,
            }
          : null,
        study: activeSession,
        plans: {
          totalCount: plans.length,
          completedCount: plans.filter((item) => item.status === 'COMPLETED')
            .length,
          targetMinutes: plans.reduce(
            (sum, item) => sum + item.targetMinutes,
            0,
          ),
        },
        notifications: notifications.map((receipt) => ({
          id: receipt.notification.id,
          title: receipt.notification.title,
          body: receipt.notification.body,
          readAt: receipt.readAt,
        })),
        student: {
          id: student.id,
          name: student.user.name,
          studentNo: student.studentNo,
          className: student.class?.name ?? null,
        },
      },
      meta: {},
    };
  }

  async getProfile(studentId: string) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      include: {
        user: true,
        class: true,
        group: true,
        grade: true,
        assignedSeat: true,
      },
    });
    if (!student) {
      throw new NotFoundException('학생을 찾을 수 없습니다.');
    }
    return { success: true, data: student, meta: {} };
  }

  async getBadges(studentId: string) {
    const badges = await this.prisma.studentBadge.findMany({
      where: { studentId },
      include: { badge: true },
      orderBy: { awardedAt: 'desc' },
    });
    return { success: true, data: badges, meta: {} };
  }
}
