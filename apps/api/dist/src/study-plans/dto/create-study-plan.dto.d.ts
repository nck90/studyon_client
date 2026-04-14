import { StudyPlanPriority } from '@prisma/client';
export declare class CreateStudyPlanDto {
    planDate: string;
    subjectName: string;
    title: string;
    description?: string;
    targetMinutes: number;
    priority: StudyPlanPriority;
}
