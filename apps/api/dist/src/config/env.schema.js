"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.envSchema = void 0;
const zod_1 = require("zod");
exports.envSchema = zod_1.z.object({
    NODE_ENV: zod_1.z
        .enum(['development', 'test', 'production'])
        .default('development'),
    PORT: zod_1.z.coerce.number().default(3000),
    APP_NAME: zod_1.z.string().default('STUDYON API'),
    APP_URL: zod_1.z.string().url().default('http://localhost:3000'),
    CORS_ORIGIN: zod_1.z.string().default('http://localhost:3000'),
    DATABASE_URL: zod_1.z.string().min(1),
    REDIS_URL: zod_1.z.string().min(1),
    JWT_ACCESS_SECRET: zod_1.z.string().min(16),
    JWT_REFRESH_SECRET: zod_1.z.string().min(16),
    JWT_ACCESS_EXPIRES_IN: zod_1.z.string().default('15m'),
    JWT_REFRESH_EXPIRES_IN: zod_1.z.string().default('30d'),
    SWAGGER_ENABLED: zod_1.z.string().default('true'),
    LOG_LEVEL: zod_1.z.string().default('info'),
    RATE_LIMIT_TTL: zod_1.z.coerce.number().default(60000),
    RATE_LIMIT_LIMIT: zod_1.z.coerce.number().default(100),
    AUTO_LOGOUT_ENABLED: zod_1.z.string().default('true'),
    SESSION_IDLE_TIMEOUT_MINUTES: zod_1.z.coerce.number().default(120),
    PARENT_PORTAL_SECRET: zod_1.z.string().min(16).default('parent-portal-secret-key'),
    DEFAULT_ADMIN_EMAIL: zod_1.z.string().email().default('admin@studyon.local'),
    DEFAULT_ADMIN_PASSWORD: zod_1.z.string().min(8).default('ChangeMe123!'),
});
//# sourceMappingURL=env.schema.js.map