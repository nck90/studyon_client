export declare class CreateStudyLogDto {
    planId?: string;
    studySessionId?: string;
    logDate: string;
    subjectName: string;
    studyMinutes?: number;
    studySeconds?: number;
    pagesCompleted: number;
    problemsSolved: number;
    progressPercent: number;
    isCompleted: boolean;
    memo?: string;
}
