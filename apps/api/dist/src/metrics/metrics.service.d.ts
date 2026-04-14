import { PrismaService } from "../database/prisma.service";
export declare class MetricsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    refreshTodayMetrics(): Promise<void>;
    refreshForDate(targetDate: Date): Promise<void>;
    refreshStudentMetrics(studentId: string, targetDate: Date): Promise<void>;
    private refreshWeeklyMetric;
    private refreshMonthlyMetric;
}
