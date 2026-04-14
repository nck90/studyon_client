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
exports.ReportsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
let ReportsService = class ReportsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async daily(studentId, date) {
        const targetDate = (0, date_util_1.dateOnly)(date);
        const attendance = await this.prisma.attendance.findUnique({
            where: {
                studentId_attendanceDate: { studentId, attendanceDate: targetDate },
            },
        });
        const plans = await this.prisma.studyPlan.findMany({
            where: { studentId, planDate: targetDate },
        });
        const sessions = await this.prisma.studySession.findMany({
            where: { studentId, sessionDate: targetDate },
        });
        const logs = await this.prisma.studyLog.findMany({
            where: { studentId, logDate: targetDate },
        });
        const studyMinutes = sessions.reduce((sum, item) => sum + item.studyMinutes, 0);
        const breakMinutes = sessions.reduce((sum, item) => sum + item.breakMinutes, 0);
        const targetMinutes = plans.reduce((sum, item) => sum + item.targetMinutes, 0);
        const achievedRate = targetMinutes === 0
            ? 0
            : Number(((studyMinutes / targetMinutes) * 100).toFixed(2));
        const subjectMap = new Map();
        logs.forEach((log) => subjectMap.set(log.subjectName, (subjectMap.get(log.subjectName) ?? 0) + log.pagesCompleted));
        sessions.forEach((session) => {
            if (session.linkedPlanId) {
            }
        });
        return {
            success: true,
            data: {
                date: targetDate.toISOString().slice(0, 10),
                attendanceMinutes: attendance?.stayMinutes ?? 0,
                studyMinutes,
                breakMinutes,
                targetMinutes,
                achievedRate,
                attendanceStatus: attendance?.attendanceStatus ?? client_1.AttendanceStatus.ABSENT,
                subjectBreakdown: Array.from(subjectMap.entries()).map(([subjectName, pagesCompleted]) => ({
                    subjectName,
                    pagesCompleted,
                })),
                logs,
            },
            meta: {},
        };
    }
    async weekly(studentId, startDate) {
        const start = (0, date_util_1.weekStart)(startDate);
        const end = (0, date_util_1.endOfDay)(new Date(start.getFullYear(), start.getMonth(), start.getDate() + 6));
        const [sessions, attendances, logs, plans] = await Promise.all([
            this.prisma.studySession.findMany({
                where: { studentId, sessionDate: { gte: start, lte: end } },
            }),
            this.prisma.attendance.findMany({
                where: { studentId, attendanceDate: { gte: start, lte: end } },
            }),
            this.prisma.studyLog.findMany({
                where: { studentId, logDate: { gte: start, lte: end } },
            }),
            this.prisma.studyPlan.findMany({
                where: { studentId, planDate: { gte: start, lte: end } },
            }),
        ]);
        return {
            success: true,
            data: {
                weekStartDate: start.toISOString().slice(0, 10),
                studyMinutes: sessions.reduce((sum, item) => sum + item.studyMinutes, 0),
                attendanceDays: attendances.filter((item) => item.attendanceStatus !== client_1.AttendanceStatus.ABSENT).length,
                targetMinutes: plans.reduce((sum, item) => sum + item.targetMinutes, 0),
                pagesCompleted: logs.reduce((sum, item) => sum + item.pagesCompleted, 0),
                problemsSolved: logs.reduce((sum, item) => sum + item.problemsSolved, 0),
            },
            meta: {},
        };
    }
    async monthly(studentId, month) {
        const key = month ?? (0, date_util_1.monthKey)();
        const [year, monthNumber] = key.split('-').map(Number);
        const start = (0, date_util_1.startOfDay)(new Date(year, monthNumber - 1, 1));
        const end = (0, date_util_1.endOfDay)(new Date(year, monthNumber, 0));
        const [sessions, attendances, logs, plans] = await Promise.all([
            this.prisma.studySession.findMany({
                where: { studentId, sessionDate: { gte: start, lte: end } },
            }),
            this.prisma.attendance.findMany({
                where: { studentId, attendanceDate: { gte: start, lte: end } },
            }),
            this.prisma.studyLog.findMany({
                where: { studentId, logDate: { gte: start, lte: end } },
            }),
            this.prisma.studyPlan.findMany({
                where: { studentId, planDate: { gte: start, lte: end } },
            }),
        ]);
        return {
            success: true,
            data: {
                month: key,
                studyMinutes: sessions.reduce((sum, item) => sum + item.studyMinutes, 0),
                attendanceDays: attendances.filter((item) => item.attendanceStatus !== client_1.AttendanceStatus.ABSENT).length,
                targetMinutes: plans.reduce((sum, item) => sum + item.targetMinutes, 0),
                pagesCompleted: logs.reduce((sum, item) => sum + item.pagesCompleted, 0),
                problemsSolved: logs.reduce((sum, item) => sum + item.problemsSolved, 0),
            },
            meta: {},
        };
    }
};
exports.ReportsService = ReportsService;
exports.ReportsService = ReportsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ReportsService);
//# sourceMappingURL=reports.service.js.map