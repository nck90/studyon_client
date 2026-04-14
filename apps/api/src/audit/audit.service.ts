import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/database/prisma.service';

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async log(input: {
    actorUserId?: string;
    actionType: string;
    targetType: string;
    targetId?: string | null;
    beforeData?: unknown;
    afterData?: unknown;
  }) {
    if (!input.actorUserId) {
      return;
    }

    await this.prisma.adminAuditLog.create({
      data: {
        actorUserId: input.actorUserId,
        actionType: input.actionType,
        targetType: input.targetType,
        targetId: input.targetId ?? undefined,
        beforeData: input.beforeData as never,
        afterData: input.afterData as never,
      },
    });
  }
}
