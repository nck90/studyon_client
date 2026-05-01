import { PrismaService } from "../database/prisma.service";
import { NotificationsService } from "../notifications/notifications.service";
import { CreateStudyPlanDto } from './dto/create-study-plan.dto';
import { UpdateStudyPlanDto } from './dto/update-study-plan.dto';
export declare class StudyPlansService {
    private readonly prisma;
    private readonly notificationsService;
    constructor(prisma: PrismaService, notificationsService: NotificationsService);
    private serializePlan;
    list(studentId: string, date?: string): Promise<{
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
    get(studentId: string, planId: string): Promise<{
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
    create(studentId: string, dto: CreateStudyPlanDto): Promise<{
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
    update(studentId: string, planId: string, dto: UpdateStudyPlanDto): Promise<{
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
    private notifyStudent;
}
