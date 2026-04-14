import { PrismaService } from "../database/prisma.service";
export declare class InsightsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    listRiskStudents(classId?: string): Promise<{
        success: boolean;
        data: {
            studentId: string;
            studentName: string;
            className: string | null;
            riskLevel: string;
            attendanceRate: number;
            averageStudyMinutes: number;
            averageAchievedRate: number;
            streakDays: number;
            recommendedTargetMinutes: number;
            recommendedFocusSubjects: string[];
            recommendedPlanTemplate: {
                subjectName: string;
                title: string;
                targetMinutes: number;
            }[];
        }[];
        meta: {};
    }>;
    studentInsight(studentId: string): Promise<{
        success: boolean;
        data: {
            studentId: string;
            studentName: string;
            className: string | null;
            riskLevel: string;
            attendanceRate: number;
            averageStudyMinutes: number;
            averageAchievedRate: number;
            streakDays: number;
            recommendedTargetMinutes: number;
            recommendedFocusSubjects: string[];
            recommendedPlanTemplate: {
                subjectName: string;
                title: string;
                targetMinutes: number;
            }[];
        };
        meta: {};
    }>;
    studentRecommendation(studentId: string): Promise<{
        success: boolean;
        data: {
            recommendedTargetMinutes: number;
            recommendedFocusSubjects: string[];
            recommendedPlanTemplate: {
                subjectName: string;
                title: string;
                targetMinutes: number;
            }[];
            riskLevel: string;
        };
        meta: {};
    }>;
    private buildStudentInsight;
    private riskScore;
}
