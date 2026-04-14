import { PrismaService } from "../database/prisma.service";
import { RedisService } from "../redis/redis.service";
export declare class AuthAutomationService {
    private readonly prisma;
    private readonly redis;
    constructor(prisma: PrismaService, redis: RedisService);
    expireIdleSessions(): Promise<void>;
}
