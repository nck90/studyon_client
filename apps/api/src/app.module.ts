import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { ScheduleModule } from '@nestjs/schedule';
import { LoggerModule } from 'nestjs-pino';
import { AuditModule } from '@/audit/audit.module';
import { envSchema } from '@/config/env.schema';
import { PrismaModule } from '@/database/prisma.module';
import { RedisModule } from '@/redis/redis.module';
import { EventsModule } from '@/events/events.module';
import { HealthModule } from '@/health/health.module';
import { AuthModule } from '@/auth/auth.module';
import { StudentsModule } from '@/students/students.module';
import { AttendancesModule } from '@/attendances/attendances.module';
import { SeatsModule } from '@/seats/seats.module';
import { StudyPlansModule } from '@/study-plans/study-plans.module';
import { StudySessionsModule } from '@/study-sessions/study-sessions.module';
import { StudyLogsModule } from '@/study-logs/study-logs.module';
import { ReportsModule } from '@/reports/reports.module';
import { RankingsModule } from '@/rankings/rankings.module';
import { NotificationsModule } from '@/notifications/notifications.module';
import { SettingsModule } from '@/settings/settings.module';
import { DisplayModule } from '@/display/display.module';
import { InsightsModule } from '@/insights/insights.module';
import { AdminModule } from '@/admin/admin.module';
import { BadgesModule } from '@/badges/badges.module';
import { CommonModule } from '@/common/common.module';
import { MetricsModule } from '@/metrics/metrics.module';
import { ParentModule } from '@/parent/parent.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      expandVariables: true,
      validate: (raw) => envSchema.parse(raw),
    }),
    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL ?? 'info',
        transport:
          process.env.NODE_ENV !== 'production'
            ? {
                target: 'pino-pretty',
                options: { singleLine: true, translateTime: 'SYS:standard' },
              }
            : undefined,
        redact: ['req.headers.authorization'],
      },
    }),
    ThrottlerModule.forRoot([
      {
        ttl: Number(process.env.RATE_LIMIT_TTL ?? 60_000),
        limit: Number(process.env.RATE_LIMIT_LIMIT ?? 100),
      },
    ]),
    ScheduleModule.forRoot(),
    AuditModule,
    EventsModule,
    PrismaModule,
    RedisModule,
    CommonModule,
    HealthModule,
    AuthModule,
    StudentsModule,
    AttendancesModule,
    SeatsModule,
    StudyPlansModule,
    StudySessionsModule,
    StudyLogsModule,
    ReportsModule,
    MetricsModule,
    BadgesModule,
    RankingsModule,
    NotificationsModule,
    SettingsModule,
    DisplayModule,
    InsightsModule,
    ParentModule,
    AdminModule,
  ],
})
export class AppModule {}
