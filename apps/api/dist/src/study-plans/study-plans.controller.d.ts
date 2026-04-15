import { JwtPayload } from "../auth/types/jwt-payload.type";
import { CreateStudyPlanDto } from './dto/create-study-plan.dto';
import { UpdateStudyPlanDto } from './dto/update-study-plan.dto';
import { StudyPlansService } from './study-plans.service';
export declare class StudyPlansController {
    private readonly studyPlansService;
    constructor(studyPlansService: StudyPlansService);
    list(user: JwtPayload, date?: string): Promise<{
        success: boolean;
        data: {
            planDate: string;
            priority: string;
            status: string;
            id: string;
            studentId: string;
            subjectName: string;
            title: string;
            description: string | null;
            targetMinutes: number;
        }[];
        meta: {};
    }>;
    get(user: JwtPayload, planId: string): Promise<{
        success: boolean;
        data: {
            planDate: string;
            priority: string;
            status: string;
            id: string;
            studentId: string;
            subjectName: string;
            title: string;
            description: string | null;
            targetMinutes: number;
        };
        meta: {};
    }>;
    create(user: JwtPayload, dto: CreateStudyPlanDto): Promise<{
        success: boolean;
        data: {
            planDate: string;
            priority: string;
            status: string;
            id: string;
            studentId: string;
            subjectName: string;
            title: string;
            description: string | null;
            targetMinutes: number;
        };
        meta: {};
    }>;
    update(user: JwtPayload, planId: string, dto: UpdateStudyPlanDto): Promise<{
        success: boolean;
        data: {
            planDate: string;
            priority: string;
            status: string;
            id: string;
            studentId: string;
            subjectName: string;
            title: string;
            description: string | null;
            targetMinutes: number;
        };
        meta: {};
    }>;
    remove(user: JwtPayload, planId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
            planId: string;
        };
        meta: {};
    }>;
    complete(user: JwtPayload, planId: string): Promise<{
        success: boolean;
        data: {
            planDate: string;
            priority: string;
            status: string;
            id: string;
            studentId: string;
            subjectName: string;
            title: string;
            description: string | null;
            targetMinutes: number;
        };
        meta: {};
    }>;
}
