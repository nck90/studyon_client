import { Injectable, NotFoundException } from '@nestjs/common';
import { dateOnly } from '@/common/utils/date.util';
import { PrismaService } from '@/database/prisma.service';
import { PointsService } from '@/points/points.service';
import { CreateStudyLogDto } from './dto/create-study-log.dto';
import { UpdateStudyLogDto } from './dto/update-study-log.dto';

@Injectable()
export class StudyLogsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pointsService: PointsService,
  ) {}

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
        include: {
          plan: {
            select: {
              id: true,
              title: true,
              targetMinutes: true,
            },
          },
          studySession: {
            select: {
              id: true,
              status: true,
              startedAt: true,
              endedAt: true,
              studyMinutes: true,
              studySeconds: true,
              breakMinutes: true,
              breakSeconds: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({
        success: true,
        data: data.map((item) => this.serializeDecimal(item)),
        meta: {},
      }));
  }

  create(studentId: string, dto: CreateStudyLogDto) {
    return this.resolveStudyDuration(studentId, dto).then(
      ({ studyMinutes, studySeconds }) =>
        this.prisma.studyLog
          .create({
            data: {
              studentId,
              planId: dto.planId,
              studySessionId: dto.studySessionId,
              logDate: dateOnly(dto.logDate),
              subjectName: dto.subjectName,
              studyMinutes,
              studySeconds,
              pagesCompleted: dto.pagesCompleted,
              problemsSolved: dto.problemsSolved,
              progressPercent: dto.progressPercent,
              isCompleted: dto.isCompleted,
              memo: dto.memo,
            },
          })
          .then(async (data) => {
            if (!data.studySessionId && (data.studySeconds ?? 0) > 0) {
              await this.pointsService
                .earnStudyTime(
                  studentId,
                  data.studySeconds,
                  `수기 기록 ${data.subjectName}`,
                )
                .catch(() => {});
            }
            return {
              success: true,
              data: this.serializeDecimal(data),
              meta: {},
            };
          }),
    );
  }

  async update(studentId: string, logId: string, dto: UpdateStudyLogDto) {
    const item = await this.prisma.studyLog.findFirst({
      where: { id: logId, studentId },
    });
    if (!item) {
      throw new NotFoundException('학습 기록을 찾을 수 없습니다.');
    }
    const duration =
      dto.studyMinutes !== undefined ||
      dto.studySeconds !== undefined ||
      dto.studySessionId !== undefined
        ? await this.resolveStudyDuration(studentId, dto)
        : undefined;
    const updated = await this.prisma.studyLog.update({
      where: { id: logId },
      data: {
        planId: dto.planId,
        studySessionId: dto.studySessionId,
        logDate: dto.logDate ? dateOnly(dto.logDate) : undefined,
        subjectName: dto.subjectName,
        studyMinutes: duration?.studyMinutes,
        studySeconds: duration?.studySeconds,
        pagesCompleted: dto.pagesCompleted,
        problemsSolved: dto.problemsSolved,
        progressPercent: dto.progressPercent,
        isCompleted: dto.isCompleted,
        memo: dto.memo,
      },
    });
    return { success: true, data: this.serializeDecimal(updated), meta: {} };
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

  private serializeDecimal<T extends Record<string, unknown>>(record: T): T {
    return {
      ...record,
      progressPercent:
        record.progressPercent != null ? Number(record.progressPercent) : 0,
    };
  }

  private async resolveStudyDuration(
    studentId: string,
    dto: Pick<
      CreateStudyLogDto,
      'studyMinutes' | 'studySeconds' | 'studySessionId'
    >,
  ) {
    if (dto.studySeconds !== undefined) {
      return {
        studySeconds: dto.studySeconds,
        studyMinutes: Math.floor(dto.studySeconds / 60),
      };
    }

    if (dto.studyMinutes !== undefined) {
      return {
        studySeconds: dto.studyMinutes * 60,
        studyMinutes: dto.studyMinutes,
      };
    }

    if (!dto.studySessionId) {
      return { studyMinutes: 0, studySeconds: 0 };
    }

    const session = await this.prisma.studySession.findFirst({
      where: { id: dto.studySessionId, studentId },
      select: { studyMinutes: true, studySeconds: true },
    });

    return {
      studyMinutes: session?.studyMinutes ?? 0,
      studySeconds: session?.studySeconds ?? (session?.studyMinutes ?? 0) * 60,
    };
  }
}
