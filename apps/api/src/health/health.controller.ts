import { Controller, Get } from '@nestjs/common';
import { PrismaHealthIndicator } from '@nestjs/terminus';
import { ApiTags } from '@nestjs/swagger';
import { promises as fs } from 'node:fs';
import { join } from 'node:path';
import { Public } from '@/common/decorators/public.decorator';
import { PrismaService } from '@/database/prisma.service';
import { RedisService } from '@/redis/redis.service';

const MEDIA_UPLOAD_DIR =
  process.env.MEDIA_UPLOAD_DIR ?? 'uploads/student-media';

@ApiTags('health')
@Controller()
export class HealthController {
  constructor(
    private readonly prismaHealthIndicator: PrismaHealthIndicator,
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  @Public()
  @Get('health')
  async check() {
    const postgres = await this.prismaHealthIndicator.pingCheck(
      'postgres',
      this.prisma,
    );
    const redisPing = await this.redis.ping();
    const redisStatus =
      redisPing === true ? 'up' : this.redis.isEnabled() ? 'down' : 'disabled';
    const media = await this.checkMediaStorage();
    const hasDegradedDependency =
      redisStatus === 'down' || media.status === 'down';

    return {
      status: hasDegradedDependency ? 'degraded' : 'ok',
      info: {
        ...postgres,
        redis: { status: redisStatus },
        media,
      },
      error: {},
      details: {
        ...postgres,
        redis: { status: redisStatus },
        media,
      },
    };
  }

  private async checkMediaStorage() {
    const probePath = join(
      MEDIA_UPLOAD_DIR,
      `.healthcheck-${process.pid}-${Date.now()}`,
    );

    try {
      await fs.mkdir(MEDIA_UPLOAD_DIR, { recursive: true });
      await fs.writeFile(probePath, 'ok');
      await fs.unlink(probePath);
      return { status: 'up' as const, path: MEDIA_UPLOAD_DIR };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'unknown media storage error';
      return { status: 'down' as const, path: MEDIA_UPLOAD_DIR, message };
    }
  }
}
