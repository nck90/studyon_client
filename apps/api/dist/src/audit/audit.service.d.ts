import { PrismaService } from "../database/prisma.service";
export declare class AuditService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    log(input: {
        actorUserId?: string;
        actionType: string;
        targetType: string;
        targetId?: string | null;
        beforeData?: unknown;
        afterData?: unknown;
    }): Promise<void>;
}
