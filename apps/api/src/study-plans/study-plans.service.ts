import { Injectable, NotFoundException } from '@nestjs/common';
import { StudyPlanStatus } from '@prisma/client';
import { dateOnly } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { CreateStudyPlanDto } from './dto/create-study-plan.dto';
import { UpdateStudyPlanDto } from './dto/update-study-plan.dto';

@Injectable()
export class StudyPlansService {
  constructor(private readonly prisma: PrismaService) {}

  list(studentId: string, date?: string) {
    return this.prisma.studyPlan
      .findMany({
        where: {
          studentId,
          planDate: date ? dateOnly(date) : undefined,
        },
        orderBy: [{ priority: 'asc' }, { createdAt: 'desc' }],
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  async get(studentId: string, planId: string) {
    const plan = await this.prisma.studyPlan.findFirst({
      where: { id: planId, studentId },
    });
    if (!plan) {
      throw new NotFoundException('계획을 찾을 수 없습니다.');
    }
    return { success: true, data: plan, meta: {} };
  }

  create(studentId: string, dto: CreateStudyPlanDto) {
    return this.prisma.studyPlan
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
      .then((data) => ({ success: true, data, meta: {} }));
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
    return { success: true, data: plan, meta: {} };
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
    return { success: true, data: plan, meta: {} };
  }
}
