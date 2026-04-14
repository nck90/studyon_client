import { z } from 'zod';

export const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'test', 'production'])
    .default('development'),
  PORT: z.coerce.number().default(3000),
  APP_NAME: z.string().default('STUDYON API'),
  APP_URL: z.string().url().default('http://localhost:3000'),
  CORS_ORIGIN: z.string().default('http://localhost:3000'),
  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().min(1),
  JWT_ACCESS_SECRET: z.string().min(16),
  JWT_REFRESH_SECRET: z.string().min(16),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('30d'),
  SWAGGER_ENABLED: z.string().default('true'),
  LOG_LEVEL: z.string().default('info'),
  RATE_LIMIT_TTL: z.coerce.number().default(60000),
  RATE_LIMIT_LIMIT: z.coerce.number().default(100),
  AUTO_LOGOUT_ENABLED: z.string().default('true'),
  SESSION_IDLE_TIMEOUT_MINUTES: z.coerce.number().default(120),
  PARENT_PORTAL_SECRET: z.string().min(16).default('parent-portal-secret-key'),
  DEFAULT_ADMIN_EMAIL: z.string().email().default('admin@studyon.local'),
  DEFAULT_ADMIN_PASSWORD: z.string().min(8).default('ChangeMe123!'),
});

export type Env = z.infer<typeof envSchema>;
