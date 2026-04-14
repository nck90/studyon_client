import { PrismaService } from "../database/prisma.service";
import { CreateStudyPlanDto } from './dto/create-study-plan.dto';
import { UpdateStudyPlanDto } from './dto/update-study-plan.dto';
export declare class StudyPlansService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    list(studentId: string, date?: string): Promise<{
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
    get(studentId: string, planId: string): Promise<{
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
    create(studentId: string, dto: CreateStudyPlanDto): Promise<{
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
    update(studentId: string, planId: string, dto: UpdateStudyPlanDto): Promise<{
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
    remove(studentId: string, planId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
            planId: string;
        };
        meta: {};
    }>;
    complete(studentId: string, planId: string): Promise<{
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
