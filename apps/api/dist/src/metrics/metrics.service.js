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
exports.MetricsService = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
let MetricsService = class MetricsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async refreshTodayMetrics() {
        await this.refreshForDate((0, date_util_1.dateOnly)());
    }
    async refreshForDate(targetDate) {
        const students = await this.prisma.student.findMany({
            select: { id: true },
        });
        for (const student of students) {
            await this.refreshStudentMetrics(student.id, targetDate);
        }
    }
    async refreshStudentMetrics(studentId, targetDate) {
        const [attendance, sessions, logs, plans] = await Promise.all([
            this.prisma.attendance.findUnique({
                where: {
                    studentId_attendanceDate: { studentId, attendanceDate: targetDate },
                },
            }),
            this.prisma.studySession.findMany({
                where: { studentId, sessionDate: targetDate },
            }),
            this.prisma.studyLog.findMany({
                where: { studentId, logDate: targetDate },
            }),
            this.prisma.studyPlan.findMany({
                where: { studentId, planDate: targetDate },
            }),
        ]);
        const studyMinutes = sessions.reduce((sum, item) => sum + item.studyMinutes, 0);
        const breakMinutes = sessions.reduce((sum, item) => sum + item.breakMinutes, 0);
        const targetMinutes = plans.reduce((sum, item) => sum + item.targetMinutes, 0);
        const pagesCompleted = logs.reduce((sum, item) => sum + item.pagesCompleted, 0);
        const problemsSolved = logs.reduce((sum, item) => sum + item.problemsSolved, 0);
        const attendanceStatus = attendance?.attendanceStatus ?? client_1.AttendanceStatus.ABSENT;
        const achievedRate = targetMinutes === 0
            ? 0
            : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));
        const previousDate = (0, date_util_1.dateOnly)(new Date(targetDate.getTime() - 24 * 60 * 60 * 1000));
        const previousMetric = await this.prisma.dailyStudentMetric.findUnique({
            where: {
                studentId_metricDate: { studentId, metricDate: previousDate },
            },
        });
        const streakDays = attendanceStatus === client_1.AttendanceStatus.CHECKED_IN ||
            attendanceStatus === client_1.AttendanceStatus.CHECKED_OUT
            ? (previousMetric?.streakDays ?? 0) + 1
            : 0;
        await this.prisma.dailyStudentMetric.upsert({
            where: {
                studentId_metricDate: { studentId, metricDate: targetDate },
            },
            update: {
                attendanceMinutes: attendance?.stayMinutes ?? 0,
                studyMinutes,
                breakMinutes,
                targetMinutes,
                achievedRate,
                pagesCompleted,
                problemsSolved,
                studySessionCount: sessions.length,
                attendanceStatus,
                streakDays,
            },
            create: {
                studentId,
                metricDate: targetDate,
                attendanceMinutes: attendance?.stayMinutes ?? 0,
                studyMinutes,
                breakMinutes,
                targetMinutes,
                achievedRate,
                pagesCompleted,
                problemsSolved,
                studySessionCount: sessions.length,
                attendanceStatus,
                streakDays,
            },
        });
        await this.refreshWeeklyMetric(studentId, targetDate);
        await this.refreshMonthlyMetric(studentId, targetDate);
    }
    async refreshWeeklyMetric(studentId, targetDate) {
        const start = (0, date_util_1.weekStart)(targetDate);
        const end = (0, date_util_1.endOfDay)(new Date(start.getFullYear(), start.getMonth(), start.getDate() + 6));
        const metrics = await this.prisma.dailyStudentMetric.findMany({
            where: { studentId, metricDate: { gte: start, lte: end } },
        });
        const studyMinutes = metrics.reduce((sum, item) => sum + item.studyMinutes, 0);
        const attendanceDays = metrics.filter((item) => item.attendanceStatus === client_1.AttendanceStatus.CHECKED_IN ||
            item.attendanceStatus === client_1.AttendanceStatus.CHECKED_OUT).length;
        const targetMinutes = metrics.reduce((sum, item) => sum + item.targetMinutes, 0);
        const pagesCompleted = metrics.reduce((sum, item) => sum + item.pagesCompleted, 0);
        const problemsSolved = metrics.reduce((sum, item) => sum + item.problemsSolved, 0);
        const achievedRate = targetMinutes === 0
            ? 0
            : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));
        await this.prisma.weeklyStudentMetric.upsert({
            where: { studentId_weekStartDate: { studentId, weekStartDate: start } },
            update: {
                studyMinutes,
                attendanceDays,
                targetMinutes,
                achievedRate,
                pagesCompleted,
                problemsSolved,
            },
            create: {
                studentId,
                weekStartDate: start,
                studyMinutes,
                attendanceDays,
                targetMinutes,
                achievedRate,
                pagesCompleted,
                problemsSolved,
            },
        });
    }
    async refreshMonthlyMetric(studentId, targetDate) {
        const key = (0, date_util_1.monthKey)(targetDate);
        const [year, monthNumber] = key.split('-').map(Number);
        const start = (0, date_util_1.startOfDay)(new Date(year, monthNumber - 1, 1));
        const end = (0, date_util_1.endOfDay)(new Date(year, monthNumber, 0));
        const metrics = await this.prisma.dailyStudentMetric.findMany({
            where: { studentId, metricDate: { gte: start, lte: end } },
        });
        const studyMinutes = metrics.reduce((sum, item) => sum + item.studyMinutes, 0);
        const attendanceDays = metrics.filter((item) => item.attendanceStatus === client_1.AttendanceStatus.CHECKED_IN ||
            item.attendanceStatus === client_1.AttendanceStatus.CHECKED_OUT).length;
        const targetMinutes = metrics.reduce((sum, item) => sum + item.targetMinutes, 0);
        const pagesCompleted = metrics.reduce((sum, item) => sum + item.pagesCompleted, 0);
        const problemsSolved = metrics.reduce((sum, item) => sum + item.problemsSolved, 0);
        const achievedRate = targetMinutes === 0
            ? 0
            : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));
        await this.prisma.monthlyStudentMetric.upsert({
            where: { studentId_monthKey: { studentId, monthKey: key } },
            update: {
                studyMinutes,
                attendanceDays,
                targetMinutes,
                achievedRate,
                pagesCompleted,
                problemsSolved,
            },
            create: {
                studentId,
                monthKey: key,
                studyMinutes,
                attendanceDays,
                targetMinutes,
                achievedRate,
                pagesCompleted,
                problemsSolved,
            },
        });
    }
};
exports.MetricsService = MetricsService;
__decorate([
    (0, schedule_1.Cron)('0 */10 * * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], MetricsService.prototype, "refreshTodayMetrics", null);
exports.MetricsService = MetricsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MetricsService);
//# sourceMappingURL=metrics.service.js.map