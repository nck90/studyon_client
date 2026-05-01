import { BadRequestException, Injectable } from '@nestjs/common';
import { PointSource, PointTransactionType } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { calculateStudyTimePoints } from './points.util';

@Injectable()
export class PointsService {
  constructor(private readonly prisma: PrismaService) {}

  async getBalance(studentId: string) {
    const student = await this.prisma.student.findUniqueOrThrow({
      where: { id: studentId },
      select: { pointBalance: true },
    });
    return { success: true, data: { balance: student.pointBalance }, meta: {} };
  }

  async getHistory(studentId: string, take = 50, skip = 0) {
    const [items, total] = await Promise.all([
      this.prisma.pointTransaction.findMany({
        where: { studentId },
        orderBy: { createdAt: 'desc' },
        take,
        skip,
      }),
      this.prisma.pointTransaction.count({ where: { studentId } }),
    ]);
    return { success: true, data: items, meta: { total, take, skip } };
  }

  async earnStudyTime(
    studentId: string,
    studySeconds: number,
    memo?: string,
    source: PointSource = PointSource.STUDY_TIME,
  ) {
    const amount = calculateStudyTimePoints(studySeconds);
    if (amount <= 0) {
      return null;
    }

    return this.earn(studentId, amount, source, memo);
  }

  async awardStudySessionTime(
    studentId: string,
    sessionId: string,
    studySeconds: number,
  ) {
    const amount = calculateStudyTimePoints(studySeconds);
    if (amount <= 0) {
      return null;
    }

    const marker = `[study-session:${sessionId}]`;
    const existing = await this.prisma.pointTransaction.findFirst({
      where: {
        studentId,
        source: PointSource.STUDY_TIME,
        memo: { startsWith: marker },
      },
      select: { balance: true },
    });
    if (existing) {
      return existing.balance;
    }

    const studyMinutes = Math.floor(studySeconds / 60);
    return this.earn(
      studentId,
      amount,
      PointSource.STUDY_TIME,
      `${marker} 타이머 공부 ${studyMinutes}분`,
    );
  }

  async earn(
    studentId: string,
    amount: number,
    source: PointSource,
    memo?: string,
  ) {
    if (amount <= 0) return;
    return this.prisma.$transaction(async (tx) => {
      const student = await tx.student.update({
        where: { id: studentId },
        data: { pointBalance: { increment: amount } },
        select: { pointBalance: true },
      });
      await tx.pointTransaction.create({
        data: {
          studentId,
          type: PointTransactionType.EARN,
          source,
          amount,
          balance: student.pointBalance,
          memo,
        },
      });
      return student.pointBalance;
    });
  }

  async spend(
    studentId: string,
    amount: number,
    source: PointSource,
    memo?: string,
  ) {
    if (amount <= 0) throw new BadRequestException('금액이 올바르지 않습니다.');
    return this.prisma.$transaction(async (tx) => {
      const student = await tx.student.findUniqueOrThrow({
        where: { id: studentId },
        select: { pointBalance: true },
      });
      if (student.pointBalance < amount) {
        throw new BadRequestException('포인트가 부족합니다.');
      }
      const updated = await tx.student.update({
        where: { id: studentId },
        data: { pointBalance: { decrement: amount } },
        select: { pointBalance: true },
      });
      await tx.pointTransaction.create({
        data: {
          studentId,
          type: PointTransactionType.SPEND,
          source,
          amount: -amount,
          balance: updated.pointBalance,
          memo,
        },
      });
      return updated.pointBalance;
    });
  }
}
