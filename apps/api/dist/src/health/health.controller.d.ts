import { PrismaHealthIndicator } from '@nestjs/terminus';
import { PrismaService } from "../database/prisma.service";
import { RedisService } from "../redis/redis.service";
export declare class HealthController {
    private readonly prismaHealthIndicator;
    private readonly prisma;
    private readonly redis;
    constructor(prismaHealthIndicator: PrismaHealthIndicator, prisma: PrismaService, redis: RedisService);
    check(): Promise<{
        status: string;
        info: {
            redis: {
                status: string;
            };
            media: {
                status: "up";
                path: string;
                message?: undefined;
            } | {
                status: "down";
                path: string;
                message: string;
            };
            postgres: {
                status: import("@nestjs/terminus").HealthIndicatorStatus;
            } & Record<string, any>;
        };
        error: {};
        details: {
            redis: {
                status: string;
            };
            media: {
                status: "up";
                path: string;
                message?: undefined;
            } | {
                status: "down";
                path: string;
                message: string;
            };
            postgres: {
                status: import("@nestjs/terminus").HealthIndicatorStatus;
            } & Record<string, any>;
        };
    }>;
    private checkMediaStorage;
}
