import { Injectable, NotFoundException } from '@nestjs/common';
import {
  NotificationChannel,
  NotificationType,
  StudyPlanStatus,
} from '@prisma/client';
import { dateOnly } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { NotificationsService } from '@/notifications/notifications.service';
import { CreateStudyPlanDto } from './dto/create-study-plan.dto';
import { UpdateStudyPlanDto } from './dto/update-study-plan.dto';

@Injectable()
export class StudyPlansService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  private serializePlan(plan: {
    id: string;
    studentId: string;
    planDate: Date;
    subjectName: string;
    title: string;
    description: string | null;
    targetMinutes: number;
    priority: string;
    status: string;
  }) {
    return {
      ...plan,
      planDate: plan.planDate.toISOString().slice(0, 10),
      priority: plan.priority.toLowerCase(),
      status:
        plan.status === 'PLANNED'
          ? 'pending'
          : plan.status === 'IN_PROGRESS'
            ? 'in_progress'
            : plan.status.toLowerCase(),
    };
  }

  list(studentId: string, date?: string) {
    return this.prisma.studyPlan
      .findMany({
        where: {
          studentId,
          planDate: date ? dateOnly(date) : undefined,
        },
        orderBy: [{ priority: 'asc' }, { createdAt: 'desc' }],
      })
      .then((data) => ({
        success: true,
        data: data.map((item) => this.serializePlan(item)),
        meta: {},
      }));
  }

  async get(studentId: string, planId: string) {
    const plan = await this.prisma.studyPlan.findFirst({
      where: { id: planId, studentId },
    });
    if (!plan) {
      throw new NotFoundException('계획을 찾을 수 없습니다.');
    }
    return { success: true, data: this.serializePlan(plan), meta: {} };
  }

  async create(studentId: string, dto: CreateStudyPlanDto) {
    const data = await this.prisma.studyPlan
      .create({
        data: {
          studentId,
          planDate: dateOnly(dto.planDate),
          subjectName: dto.subjectName,
          title: dto.title,
          description: dto.description,
          targetMinutes: dto.targetMinutes,
          priority: dto.priority,
        },
      })
      .then((item) => this.serializePlan(item));
    await this.notifyStudent(
      studentId,
      '새 계획이 추가되었어요',
      `${dto.subjectName} 계획 "${dto.title}"이(가) 오늘 일정에 추가되었습니다.`,
    );
    return { success: true, data, meta: {} };
  }

  async update(studentId: string, planId: string, dto: UpdateStudyPlanDto) {
    await this.get(studentId, planId);
    const plan = await this.prisma.studyPlan.update({
      where: { id: planId },
      data: {
        planDate: dto.planDate ? dateOnly(dto.planDate) : undefined,
        subjectName: dto.subjectName,
        title: dto.title,
        description: dto.description,
        targetMinutes: dto.targetMinutes,
        priority: dto.priority,
      },
    });
    return { success: true, data: this.serializePlan(plan), meta: {} };
  }

  async remove(studentId: string, planId: string) {
    await this.get(studentId, planId);
    await this.prisma.studyPlan.delete({ where: { id: planId } });
    return { success: true, data: { deleted: true, planId }, meta: {} };
  }

  async complete(studentId: string, planId: string) {
    await this.get(studentId, planId);
    const plan = await this.prisma.studyPlan.update({
      where: { id: planId },
      data: { status: StudyPlanStatus.COMPLETED, completedAt: new Date() },
    });
    await this.notifyStudent(
      studentId,
      '계획 완료',
      `${plan.title} 계획을 완료했어요.`,
    );
    return { success: true, data: this.serializePlan(plan), meta: {} };
  }

  private async notifyStudent(
    studentId: string,
    title: string,
    body: string,
    notificationType: NotificationType = NotificationType.NOTICE,
  ) {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { userId: true },
    });
    if (!student?.userId) {
      return;
    }
    await this.notificationsService.sendDirectToUsers({
      userIds: [student.userId],
      notificationType,
      channel: NotificationChannel.IN_APP,
      title,
      body,
    });
  }
}
