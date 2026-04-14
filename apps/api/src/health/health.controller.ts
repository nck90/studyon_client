import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  PrismaHealthIndicator,
} from '@nestjs/terminus';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '@/common/decorators/public.decorator';
import { PrismaService } from '@/database/prisma.service';
import { RedisService } from '@/redis/redis.service';

@ApiTags('health')
@Controller()
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly prismaHealthIndicator: PrismaHealthIndicator,
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  @Public()
  @Get('health')
  @HealthCheck()
  async check() {
    return this.health.check([
      async () => this.prismaHealthIndicator.pingCheck('postgres', this.prisma),
      async () => {
        await this.redis.client.ping();
        return { redis: { status: 'up' } };
      },
    ]);
  }
}
