import { PrismaService } from "../database/prisma.service";
export declare class BadgeAutomationService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    awardBadges(): Promise<void>;
    private ensureDefaultBadges;
    private give;
}
