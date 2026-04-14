"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.InsightsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../database/prisma.service");
let InsightsService = class InsightsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async listRiskStudents(classId) {
        const students = await this.prisma.student.findMany({
            where: { classId: classId ?? undefined, enrollmentStatus: 'ACTIVE' },
            include: { user: true, class: true },
        });
        const data = await Promise.all(students.map(async (student) => this.buildStudentInsight(student.id)));
        return {
            success: true,
            data: data.sort((a, b) => this.riskScore(b.riskLevel) - this.riskScore(a.riskLevel)),
            meta: {},
        };
    }
    async studentInsight(studentId) {
        const result = await this.buildStudentInsight(studentId);
        return { success: true, data: result, meta: {} };
    }
    async studentRecommendation(studentId) {
        const insight = await this.buildStudentInsight(studentId);
        return {
            success: true,
            data: {
                recommendedTargetMinutes: insight.recommendedTargetMinutes,
                recommendedFocusSubjects: insight.recommendedFocusSubjects,
                recommendedPlanTemplate: insight.recommendedPlanTemplate,
                riskLevel: insight.riskLevel,
            },
            meta: {},
        };
    }
    async buildStudentInsight(studentId) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
            include: { user: true, class: true },
        });
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        const [metrics, logs] = await Promise.all([
            this.prisma.dailyStudentMetric.findMany({
                where: { studentId },
                orderBy: { metricDate: 'desc' },
                take: 14,
            }),
            this.prisma.studyLog.findMany({
                where: { studentId },
                orderBy: { logDate: 'desc' },
                take: 30,
            }),
        ]);
        const attendanceDays = metrics.filter((item) => item.attendanceStatus === client_1.AttendanceStatus.CHECKED_IN ||
            item.attendanceStatus === client_1.AttendanceStatus.CHECKED_OUT).length;
        const attendanceRate = metrics.length === 0
            ? 0
            : Number(((attendanceDays / metrics.length) * 100).toFixed(2));
        const averageStudyMinutes = metrics.length === 0
            ? 0
            : Number((metrics.reduce((sum, item) => sum + item.studyMinutes, 0) /
                metrics.length).toFixed(2));
        const averageAchievedRate = metrics.length === 0
            ? 0
            : Number((metrics.reduce((sum, item) => sum + Number(item.achievedRate), 0) / metrics.length).toFixed(2));
        const streakDays = metrics[0]?.streakDays ?? 0;
        const riskLevel = attendanceRate < 60 ||
            averageStudyMinutes < 90 ||
            averageAchievedRate < 50
            ? 'HIGH'
            : attendanceRate < 80 ||
                averageStudyMinutes < 180 ||
                averageAchievedRate < 75
                ? 'MEDIUM'
                : 'LOW';
        const subjectStats = new Map();
        for (const log of logs) {
            const current = subjectStats.get(log.subjectName) ?? {
                pages: 0,
                problems: 0,
                completionCount: 0,
            };
            current.pages += log.pagesCompleted;
            current.problems += log.problemsSolved;
            current.completionCount += log.isCompleted ? 1 : 0;
            subjectStats.set(log.subjectName, current);
        }
        const recommendedFocusSubjects = [...subjectStats.entries()]
            .sort((a, b) => a[1].completionCount - b[1].completionCount)
            .slice(0, 3)
            .map(([subjectName]) => subjectName);
        const recommendedTargetMinutes = Math.min(480, Math.max(60, Math.round(averageStudyMinutes * 1.15 || 180)));
        return {
            studentId: student.id,
            studentName: student.user.name,
            className: student.class?.name ?? null,
            riskLevel,
            attendanceRate,
            averageStudyMinutes,
            averageAchievedRate,
            streakDays,
            recommendedTargetMinutes,
            recommendedFocusSubjects: recommendedFocusSubjects.length > 0
                ? recommendedFocusSubjects
                : ['수학', '영어'],
            recommendedPlanTemplate: [
                {
                    subjectName: recommendedFocusSubjects[0] ?? '수학',
                    title: `${recommendedFocusSubjects[0] ?? '수학'} 핵심 개념 복습`,
                    targetMinutes: Math.round(recommendedTargetMinutes * 0.4),
                },
                {
                    subjectName: recommendedFocusSubjects[1] ?? '영어',
                    title: `${recommendedFocusSubjects[1] ?? '영어'} 문제풀이`,
                    targetMinutes: Math.round(recommendedTargetMinutes * 0.35),
                },
                {
                    subjectName: recommendedFocusSubjects[2] ?? '국어',
                    title: `${recommendedFocusSubjects[2] ?? '국어'} 오답 정리`,
                    targetMinutes: Math.round(recommendedTargetMinutes * 0.25),
                },
            ],
        };
    }
    riskScore(level) {
        return level === 'HIGH' ? 3 : level === 'MEDIUM' ? 2 : 1;
    }
};
exports.InsightsService = InsightsService;
exports.InsightsService = InsightsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], InsightsService);
//# sourceMappingURL=insights.service.js.map