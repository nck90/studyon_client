import { OnModuleDestroy } from '@nestjs/common';
import Redis from 'ioredis';
export declare class RedisService implements OnModuleDestroy {
    readonly client: Redis;
    constructor();
    onModuleDestroy(): Promise<void>;
}
