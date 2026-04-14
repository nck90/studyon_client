"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthAutomationService = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../database/prisma.service");
const redis_service_1 = require("../redis/redis.service");
let AuthAutomationService = class AuthAutomationService {
    prisma;
    redis;
    constructor(prisma, redis) {
        this.prisma = prisma;
        this.redis = redis;
    }
    async expireIdleSessions() {
        const enabled = process.env.AUTO_LOGOUT_ENABLED !== 'false';
        if (!enabled) {
            return;
        }
        const idleTimeoutMinutes = Number(process.env.SESSION_IDLE_TIMEOUT_MINUTES ?? 120);
        const cutoff = new Date(Date.now() - idleTimeoutMinutes * 60 * 1000);
        const sessions = await this.prisma.authSession.findMany({
            where: {
                sessionStatus: client_1.SessionStatus.ACTIVE,
                lastActivityAt: { lt: cutoff },
            },
            select: { id: true },
            take: 500,
        });
        for (const session of sessions) {
            await this.prisma.authSession.update({
                where: { id: session.id },
                data: {
                    sessionStatus: client_1.SessionStatus.EXPIRED,
                    endedAt: new Date(),
                },
            });
            await this.redis.client.del(`auth:refresh:${session.id}`);
        }
    }
};
exports.AuthAutomationService = AuthAutomationService;
__decorate([
    (0, schedule_1.Cron)('0 */5 * * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AuthAutomationService.prototype, "expireIdleSessions", null);
exports.AuthAutomationService = AuthAutomationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService])
], AuthAutomationService);
//# sourceMappingURL=auth.automation.service.js.map