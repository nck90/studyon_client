import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { SessionStatus } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { RedisService } from '@/redis/redis.service';

@Injectable()
export class AuthAutomationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  @Cron('0 */5 * * * *')
  async expireIdleSessions() {
    const enabled = process.env.AUTO_LOGOUT_ENABLED !== 'false';
    if (!enabled) {
      return;
    }

    const idleTimeoutMinutes = Number(
      process.env.SESSION_IDLE_TIMEOUT_MINUTES ?? 120,
    );
    const cutoff = new Date(Date.now() - idleTimeoutMinutes * 60 * 1000);

    const sessions = await this.prisma.authSession.findMany({
      where: {
        sessionStatus: SessionStatus.ACTIVE,
        lastActivityAt: { lt: cutoff },
      },
      select: { id: true },
      take: 500,
    });

    for (const session of sessions) {
      await this.prisma.authSession.update({
        where: { id: session.id },
        data: {
          sessionStatus: SessionStatus.EXPIRED,
          endedAt: new Date(),
        },
      });
      await this.redis.client.del(`auth:refresh:${session.id}`);
    }
  }
}
