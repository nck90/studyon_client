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
exports.HealthController = void 0;
const common_1 = require("@nestjs/common");
const terminus_1 = require("@nestjs/terminus");
const swagger_1 = require("@nestjs/swagger");
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
const public_decorator_1 = require("../common/decorators/public.decorator");
const prisma_service_1 = require("../database/prisma.service");
const redis_service_1 = require("../redis/redis.service");
const MEDIA_UPLOAD_DIR = process.env.MEDIA_UPLOAD_DIR ?? 'uploads/student-media';
let HealthController = class HealthController {
    prismaHealthIndicator;
    prisma;
    redis;
    constructor(prismaHealthIndicator, prisma, redis) {
        this.prismaHealthIndicator = prismaHealthIndicator;
        this.prisma = prisma;
        this.redis = redis;
    }
    async check() {
        const postgres = await this.prismaHealthIndicator.pingCheck('postgres', this.prisma);
        const redisPing = await this.redis.ping();
        const redisStatus = redisPing === true ? 'up' : this.redis.isEnabled() ? 'down' : 'disabled';
        const media = await this.checkMediaStorage();
        const hasDegradedDependency = redisStatus === 'down' || media.status === 'down';
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
    async checkMediaStorage() {
        const probePath = (0, node_path_1.join)(MEDIA_UPLOAD_DIR, `.healthcheck-${process.pid}-${Date.now()}`);
        try {
            await node_fs_1.promises.mkdir(MEDIA_UPLOAD_DIR, { recursive: true });
            await node_fs_1.promises.writeFile(probePath, 'ok');
            await node_fs_1.promises.unlink(probePath);
            return { status: 'up', path: MEDIA_UPLOAD_DIR };
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'unknown media storage error';
            return { status: 'down', path: MEDIA_UPLOAD_DIR, message };
        }
    }
};
exports.HealthController = HealthController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('health'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], HealthController.prototype, "check", null);
exports.HealthController = HealthController = __decorate([
    (0, swagger_1.ApiTags)('health'),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [terminus_1.PrismaHealthIndicator,
        prisma_service_1.PrismaService,
        redis_service_1.RedisService])
], HealthController);
//# sourceMappingURL=health.controller.js.map