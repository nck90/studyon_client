import { HealthCheckService, PrismaHealthIndicator } from '@nestjs/terminus';
import { PrismaService } from "../database/prisma.service";
import { RedisService } from "../redis/redis.service";
export declare class HealthController {
    private readonly health;
    private readonly prismaHealthIndicator;
    private readonly prisma;
    private readonly redis;
    constructor(health: HealthCheckService, prismaHealthIndicator: PrismaHealthIndicator, prisma: PrismaService, redis: RedisService);
    check(): Promise<import("@nestjs/terminus").HealthCheckResult<import("@nestjs/terminus").HealthIndicatorResult<string, import("@nestjs/terminus").HealthIndicatorStatus, Record<string, any>> & {
        redis: {
            status: "up";
        };
    } & import("@nestjs/terminus").HealthIndicatorResult<"postgres">, Partial<import("@nestjs/terminus").HealthIndicatorResult<string, import("@nestjs/terminus").HealthIndicatorStatus, Record<string, any>> & {
        redis: {
            status: "up";
        };
    } & import("@nestjs/terminus").HealthIndicatorResult<"postgres">> | undefined, Partial<import("@nestjs/terminus").HealthIndicatorResult<string, import("@nestjs/terminus").HealthIndicatorStatus, Record<string, any>> & {
        redis: {
            status: "up";
        };
    } & import("@nestjs/terminus").HealthIndicatorResult<"postgres">> | undefined>>;
}
