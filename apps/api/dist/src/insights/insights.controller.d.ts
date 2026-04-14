import { JwtPayload } from "../auth/types/jwt-payload.type";
import { InsightsService } from './insights.service';
export declare class InsightsController {
    private readonly insightsService;
    constructor(insightsService: InsightsService);
    risks(classId?: string): Promise<{
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
    myRecommendation(user: JwtPayload): Promise<{
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
}
