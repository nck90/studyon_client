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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var RedisService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RedisService = void 0;
const common_1 = require("@nestjs/common");
const ioredis_1 = __importDefault(require("ioredis"));
let RedisService = RedisService_1 = class RedisService {
    logger = new common_1.Logger(RedisService_1.name);
    client;
    hasLoggedUnavailable = false;
    constructor() {
        if (!process.env.REDIS_URL) {
            this.logger.warn('REDIS_URL is not configured. Redis-backed features are disabled.');
            return;
        }
        this.client = new ioredis_1.default(process.env.REDIS_URL, {
            lazyConnect: true,
            maxRetriesPerRequest: 1,
            enableReadyCheck: false,
            connectTimeout: 5000,
        });
    }
    async onModuleDestroy() {
        if (this.client) {
            await this.client.quit();
        }
    }
    isEnabled() {
        return Boolean(this.client);
    }
    async get(key) {
        return this.withClient((client) => client.get(key));
    }
    async set(key, value, ttlSeconds) {
        return this.withClient((client) => ttlSeconds
            ? client.set(key, value, 'EX', ttlSeconds)
            : client.set(key, value));
    }
    async del(key) {
        return this.withClient((client) => client.del(key));
    }
    async ping() {
        const result = await this.withClient((client) => client.ping());
        return result === undefined ? undefined : result === 'PONG';
    }
    async withClient(action) {
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
        }
        catch (error) {
            if (!this.hasLoggedUnavailable) {
                const message = error instanceof Error ? error.message : 'unknown Redis error';
                this.logger.warn(`Redis unavailable, continuing in degraded mode: ${message}`);
                this.hasLoggedUnavailable = true;
            }
            return undefined;
        }
    }
};
exports.RedisService = RedisService;
exports.RedisService = RedisService = RedisService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], RedisService);
//# sourceMappingURL=redis.service.js.map