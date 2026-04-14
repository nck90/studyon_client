import { Injectable, NotFoundException } from '@nestjs/common';
import { dateOnly } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { CreateStudyLogDto } from './dto/create-study-log.dto';
import { UpdateStudyLogDto } from './dto/update-study-log.dto';

@Injectable()
export class StudyLogsService {
  constructor(private readonly prisma: PrismaService) {}

  list(studentId: string, date?: string, startDate?: string, endDate?: string) {
    return this.prisma.studyLog
      .findMany({
        where: {
          studentId,
          logDate: date
            ? dateOnly(date)
            : {
                gte: startDate ? dateOnly(startDate) : undefined,
                lte: endDate ? dateOnly(endDate) : undefined,
              },
        },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  create(studentId: string, dto: CreateStudyLogDto) {
    return this.prisma.studyLog
      .create({
        data: {
          studentId,
          planId: dto.planId,
          studySessionId: dto.studySessionId,
          logDate: dateOnly(dto.logDate),
          subjectName: dto.subjectName,
          pagesCompleted: dto.pagesCompleted,
          problemsSolved: dto.problemsSolved,
          progressPercent: dto.progressPercent,
          isCompleted: dto.isCompleted,
          memo: dto.memo,
        },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  async update(studentId: string, logId: string, dto: UpdateStudyLogDto) {
    const item = await this.prisma.studyLog.findFirst({
      where: { id: logId, studentId },
    });
    if (!item) {
      throw new NotFoundException('학습 기록을 찾을 수 없습니다.');
    }
    const updated = await this.prisma.studyLog.update({
      where: { id: logId },
      data: {
        planId: dto.planId,
        studySessionId: dto.studySessionId,
        logDate: dto.logDate ? dateOnly(dto.logDate) : undefined,
        subjectName: dto.subjectName,
        pagesCompleted: dto.pagesCompleted,
        problemsSolved: dto.problemsSolved,
        progressPercent: dto.progressPercent,
        isCompleted: dto.isCompleted,
        memo: dto.memo,
      },
    });
    return { success: true, data: updated, meta: {} };
  }

  async remove(studentId: string, logId: string) {
    const item = await this.prisma.studyLog.findFirst({
      where: { id: logId, studentId },
    });
    if (!item) {
      throw new NotFoundException('학습 기록을 찾을 수 없습니다.');
    }
    await this.prisma.studyLog.delete({ where: { id: logId } });
    return { success: true, data: { deleted: true, logId }, meta: {} };
  }
}
