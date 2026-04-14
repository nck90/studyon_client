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
exports.RankingsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const metrics_service_1 = require("../metrics/metrics.service");
let RankingsService = class RankingsService {
    prisma;
    metricsService;
    constructor(prisma, metricsService) {
        this.prisma = prisma;
        this.metricsService = metricsService;
    }
    async studentRanking(studentId, periodType, rankingType) {
        const snapshot = await this.ensureSnapshot(periodType, rankingType);
        const items = await this.prisma.rankingSnapshotItem.findMany({
            where: { rankingSnapshotId: snapshot.id },
            include: { student: { include: { user: true } } },
            orderBy: { rankNo: 'asc' },
            take: 50,
        });
        const myRank = items.find((item) => item.studentId === studentId) ?? null;
        return {
            success: true,
            data: {
                myRank,
                items: items.map((item) => ({
                    studentId: item.studentId,
                    studentName: item.student.user.name,
                    rankNo: item.rankNo,
                    score: Number(item.score),
                })),
            },
            meta: {},
        };
    }
    async adminRanking(periodType, rankingType) {
        const snapshot = await this.ensureSnapshot(periodType, rankingType);
        const items = await this.prisma.rankingSnapshotItem.findMany({
            where: { rankingSnapshotId: snapshot.id },
            include: { student: { include: { user: true } } },
            orderBy: { rankNo: 'asc' },
        });
        return { success: true, data: { snapshot, items }, meta: {} };
    }
    async ensureSnapshot(periodType, rankingType) {
        const key = periodType === client_1.RankingPeriodType.DAILY
            ? new Date().toISOString().slice(0, 10)
            : periodType === client_1.RankingPeriodType.WEEKLY
                ? (0, date_util_1.weekStart)().toISOString().slice(0, 10)
                : (0, date_util_1.monthKey)();
        const range = periodType === client_1.RankingPeriodType.DAILY
            ? {
                start: (0, date_util_1.startOfDay)(new Date()),
                end: (0, date_util_1.endOfDay)(new Date()),
            }
            : periodType === client_1.RankingPeriodType.WEEKLY
                ? {
                    start: (0, date_util_1.weekStart)(),
                    end: (0, date_util_1.endOfDay)(new Date((0, date_util_1.weekStart)().getFullYear(), (0, date_util_1.weekStart)().getMonth(), (0, date_util_1.weekStart)().getDate() + 6)),
                }
                : (() => {
                    const keyDate = new Date(`${(0, date_util_1.monthKey)()}-01T00:00:00`);
                    return {
                        start: (0, date_util_1.startOfDay)(keyDate),
                        end: (0, date_util_1.endOfDay)(new Date(keyDate.getFullYear(), keyDate.getMonth() + 1, 0)),
                    };
                })();
        await this.metricsService.refreshForDate((0, date_util_1.startOfDay)(new Date()));
        let snapshot = await this.prisma.rankingSnapshot.findFirst({
            where: { periodType, rankingType, periodKey: key },
        });
        if (!snapshot) {
            snapshot = await this.prisma.rankingSnapshot.create({
                data: { periodType, rankingType, periodKey: key },
            });
        }
        else {
            snapshot = await this.prisma.rankingSnapshot.update({
                where: { id: snapshot.id },
                data: { generatedAt: new Date() },
            });
            await this.prisma.rankingSnapshotItem.deleteMany({
                where: { rankingSnapshotId: snapshot.id },
            });
        }
        const metrics = await this.prisma.dailyStudentMetric.findMany({
            where: { metricDate: { gte: range.start, lte: range.end } },
        });
        const students = await this.prisma.student.findMany({
            include: { user: true },
        });
        const scores = students.map((student) => {
            const studentMetrics = metrics.filter((item) => item.studentId === student.id);
            if (rankingType === client_1.RankingType.STUDY_TIME) {
                return {
                    studentId: student.id,
                    score: studentMetrics.reduce((sum, item) => sum + item.studyMinutes, 0),
                };
            }
            if (rankingType === client_1.RankingType.STUDY_VOLUME) {
                return {
                    studentId: student.id,
                    score: studentMetrics.reduce((sum, item) => sum + item.pagesCompleted + item.problemsSolved, 0),
                };
            }
            const latestMetric = studentMetrics.sort((a, b) => a.metricDate.getTime() - b.metricDate.getTime())[studentMetrics.length - 1];
            return { studentId: student.id, score: latestMetric?.streakDays ?? 0 };
        });
        scores.sort((a, b) => b.score - a.score);
        await this.prisma.rankingSnapshotItem.createMany({
            data: scores.map((item, index) => ({
                rankingSnapshotId: snapshot.id,
                studentId: item.studentId,
                rankNo: index + 1,
                score: item.score,
                subScore1: 0,
                subScore2: 0,
            })),
        });
        return snapshot;
    }
};
exports.RankingsService = RankingsService;
exports.RankingsService = RankingsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        metrics_service_1.MetricsService])
], RankingsService);
//# sourceMappingURL=rankings.service.js.map