import { z } from 'zod';
export declare const envSchema: z.ZodObject<{
    NODE_ENV: z.ZodDefault<z.ZodEnum<{
        development: "development";
        test: "test";
        production: "production";
    }>>;
    PORT: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    APP_NAME: z.ZodDefault<z.ZodString>;
    APP_URL: z.ZodDefault<z.ZodString>;
    CORS_ORIGIN: z.ZodDefault<z.ZodString>;
    DATABASE_URL: z.ZodString;
    REDIS_URL: z.ZodString;
    JWT_ACCESS_SECRET: z.ZodString;
    JWT_REFRESH_SECRET: z.ZodString;
    JWT_ACCESS_EXPIRES_IN: z.ZodDefault<z.ZodString>;
    JWT_REFRESH_EXPIRES_IN: z.ZodDefault<z.ZodString>;
    SWAGGER_ENABLED: z.ZodDefault<z.ZodString>;
    LOG_LEVEL: z.ZodDefault<z.ZodString>;
    RATE_LIMIT_TTL: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    RATE_LIMIT_LIMIT: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    AUTO_LOGOUT_ENABLED: z.ZodDefault<z.ZodString>;
    SESSION_IDLE_TIMEOUT_MINUTES: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    PARENT_PORTAL_SECRET: z.ZodDefault<z.ZodString>;
    DEFAULT_ADMIN_EMAIL: z.ZodDefault<z.ZodString>;
    DEFAULT_ADMIN_PASSWORD: z.ZodDefault<z.ZodString>;
}, z.core.$strip>;
export type Env = z.infer<typeof envSchema>;
