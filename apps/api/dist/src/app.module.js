"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const throttler_1 = require("@nestjs/throttler");
const schedule_1 = require("@nestjs/schedule");
const nestjs_pino_1 = require("nestjs-pino");
const audit_module_1 = require("./audit/audit.module");
const env_schema_1 = require("./config/env.schema");
const prisma_module_1 = require("./database/prisma.module");
const redis_module_1 = require("./redis/redis.module");
const events_module_1 = require("./events/events.module");
const health_module_1 = require("./health/health.module");
const auth_module_1 = require("./auth/auth.module");
const students_module_1 = require("./students/students.module");
const attendances_module_1 = require("./attendances/attendances.module");
const seats_module_1 = require("./seats/seats.module");
const study_plans_module_1 = require("./study-plans/study-plans.module");
const study_sessions_module_1 = require("./study-sessions/study-sessions.module");
const study_logs_module_1 = require("./study-logs/study-logs.module");
const reports_module_1 = require("./reports/reports.module");
const rankings_module_1 = require("./rankings/rankings.module");
const notifications_module_1 = require("./notifications/notifications.module");
const settings_module_1 = require("./settings/settings.module");
const display_module_1 = require("./display/display.module");
const insights_module_1 = require("./insights/insights.module");
const admin_module_1 = require("./admin/admin.module");
const badges_module_1 = require("./badges/badges.module");
const common_module_1 = require("./common/common.module");
const metrics_module_1 = require("./metrics/metrics.module");
const parent_module_1 = require("./parent/parent.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                expandVariables: true,
                validate: (raw) => env_schema_1.envSchema.parse(raw),
            }),
            nestjs_pino_1.LoggerModule.forRoot({
                pinoHttp: {
                    level: process.env.LOG_LEVEL ?? 'info',
                    transport: process.env.NODE_ENV !== 'production'
                        ? {
                            target: 'pino-pretty',
                            options: { singleLine: true, translateTime: 'SYS:standard' },
                        }
                        : undefined,
                    redact: ['req.headers.authorization'],
                },
            }),
            throttler_1.ThrottlerModule.forRoot([
                {
                    ttl: Number(process.env.RATE_LIMIT_TTL ?? 60_000),
                    limit: Number(process.env.RATE_LIMIT_LIMIT ?? 100),
                },
            ]),
            schedule_1.ScheduleModule.forRoot(),
            audit_module_1.AuditModule,
            events_module_1.EventsModule,
            prisma_module_1.PrismaModule,
            redis_module_1.RedisModule,
            common_module_1.CommonModule,
            health_module_1.HealthModule,
            auth_module_1.AuthModule,
            students_module_1.StudentsModule,
            attendances_module_1.AttendancesModule,
            seats_module_1.SeatsModule,
            study_plans_module_1.StudyPlansModule,
            study_sessions_module_1.StudySessionsModule,
            study_logs_module_1.StudyLogsModule,
            reports_module_1.ReportsModule,
            metrics_module_1.MetricsModule,
            badges_module_1.BadgesModule,
            rankings_module_1.RankingsModule,
            notifications_module_1.NotificationsModule,
            settings_module_1.SettingsModule,
            display_module_1.DisplayModule,
            insights_module_1.InsightsModule,
            parent_module_1.ParentModule,
            admin_module_1.AdminModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map