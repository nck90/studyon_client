import { OnModuleDestroy } from '@nestjs/common';
export declare class RedisService implements OnModuleDestroy {
    private readonly logger;
    private readonly client?;
    private hasLoggedUnavailable;
    constructor();
    onModuleDestroy(): Promise<void>;
    isEnabled(): boolean;
    get(key: string): Promise<string | null | undefined>;
    set(key: string, value: string, ttlSeconds?: number): Promise<'OK' | undefined>;
    del(key: string): Promise<number | undefined>;
    ping(): Promise<boolean | undefined>;
    private withClient;
}
