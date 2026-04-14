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
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudyPlanStatus;
            updatedAt: Date;
            description: string | null;
            studentId: string;
            title: string;
            planDate: Date;
            subjectName: string;
            targetMinutes: number;
            priority: import("@prisma/client").$Enums.StudyPlanPriority;
            completedAt: Date | null;
        }[];
        meta: {};
    }>;
    get(user: JwtPayload, planId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudyPlanStatus;
            updatedAt: Date;
            description: string | null;
            studentId: string;
            title: string;
            planDate: Date;
            subjectName: string;
            targetMinutes: number;
            priority: import("@prisma/client").$Enums.StudyPlanPriority;
            completedAt: Date | null;
        };
        meta: {};
    }>;
    create(user: JwtPayload, dto: CreateStudyPlanDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudyPlanStatus;
            updatedAt: Date;
            description: string | null;
            studentId: string;
            title: string;
            planDate: Date;
            subjectName: string;
            targetMinutes: number;
            priority: import("@prisma/client").$Enums.StudyPlanPriority;
            completedAt: Date | null;
        };
        meta: {};
    }>;
    update(user: JwtPayload, planId: string, dto: UpdateStudyPlanDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudyPlanStatus;
            updatedAt: Date;
            description: string | null;
            studentId: string;
            title: string;
            planDate: Date;
            subjectName: string;
            targetMinutes: number;
            priority: import("@prisma/client").$Enums.StudyPlanPriority;
            completedAt: Date | null;
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
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.StudyPlanStatus;
            updatedAt: Date;
            description: string | null;
            studentId: string;
            title: string;
            planDate: Date;
            subjectName: string;
            targetMinutes: number;
            priority: import("@prisma/client").$Enums.StudyPlanPriority;
            completedAt: Date | null;
        };
        meta: {};
    }>;
}
