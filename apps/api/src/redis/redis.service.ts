import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private readonly client?: Redis;
  private hasLoggedUnavailable = false;

  constructor() {
    if (!process.env.REDIS_URL) {
      this.logger.warn(
        'REDIS_URL is not configured. Redis-backed features are disabled.',
      );
      return;
    }

    this.client = new Redis(process.env.REDIS_URL, {
      lazyConnect: true,
      maxRetriesPerRequest: 1,
      enableReadyCheck: false,
      connectTimeout: 5000,
    });
  }

  async onModuleDestroy(): Promise<void> {
    if (this.client) {
      await this.client.quit();
    }
  }

  isEnabled(): boolean {
    return Boolean(this.client);
  }

  async get(key: string): Promise<string | null | undefined> {
    return this.withClient((client) => client.get(key));
  }

  async set(
    key: string,
    value: string,
    ttlSeconds?: number,
  ): Promise<'OK' | undefined> {
    return this.withClient((client) =>
      ttlSeconds
        ? client.set(key, value, 'EX', ttlSeconds)
        : client.set(key, value),
    );
  }

  async del(key: string): Promise<number | undefined> {
    return this.withClient((client) => client.del(key));
  }

  async ping(): Promise<boolean | undefined> {
    const result = await this.withClient((client) => client.ping());
    return result === undefined ? undefined : result === 'PONG';
  }

  private async withClient<T>(
    action: (client: Redis) => Promise<T>,
  ): Promise<T | undefined> {
    if (!this.client) {
      return undefined;
    }

    try {
      if (this.client.status === 'wait') {
        await this.client.connect();
      }

      const result = await action(this.client);
      this.hasLoggedUnavailable = false;
      return result;
    } catch (error) {
      if (!this.hasLoggedUnavailable) {
        const message =
          error instanceof Error ? error.message : 'unknown Redis error';
        this.logger.warn(
          `Redis unavailable, continuing in degraded mode: ${message}`,
        );
        this.hasLoggedUnavailable = true;
      }
      return undefined;
    }
  }
}
