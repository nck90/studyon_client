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
                myRank: myRank
                    ? {
                        rankNo: myRank.rankNo,
                        score: Number(myRank.score),
                    }
                    : {
                        rankNo: 0,
                        score: 0,
                    },
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
        const students = await this.prisma.student.findMany({
            include: { user: true },
        });
        const scoreMap = await this.buildScoreMap(periodType, rankingType);
        const scores = students.map((student) => ({
            studentId: student.id,
            score: scoreMap.get(student.id) ?? 0,
        }));
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
    async buildScoreMap(periodType, rankingType) {
        if (periodType === client_1.RankingPeriodType.DAILY) {
            const today = (0, date_util_1.startOfDay)(new Date());
            const metrics = await this.prisma.dailyStudentMetric.findMany({
                where: { metricDate: today },
            });
            return new Map(metrics.map((metric) => [
                metric.studentId,
                rankingType === client_1.RankingType.STUDY_TIME
                    ? metric.studyMinutes
                    : rankingType === client_1.RankingType.STUDY_VOLUME
                        ? metric.pagesCompleted + metric.problemsSolved
                        : metric.streakDays,
            ]));
        }
        if (periodType === client_1.RankingPeriodType.WEEKLY) {
            const metrics = await this.prisma.weeklyStudentMetric.findMany({
                where: { weekStartDate: (0, date_util_1.weekStart)() },
            });
            return new Map(metrics.map((metric) => [
                metric.studentId,
                rankingType === client_1.RankingType.STUDY_TIME
                    ? metric.studyMinutes
                    : rankingType === client_1.RankingType.STUDY_VOLUME
                        ? metric.pagesCompleted + metric.problemsSolved
                        : metric.attendanceDays,
            ]));
        }
        const metrics = await this.prisma.monthlyStudentMetric.findMany({
            where: { monthKey: (0, date_util_1.monthKey)() },
        });
        return new Map(metrics.map((metric) => [
            metric.studentId,
            rankingType === client_1.RankingType.STUDY_TIME
                ? metric.studyMinutes
                : rankingType === client_1.RankingType.STUDY_VOLUME
                    ? metric.pagesCompleted + metric.problemsSolved
                    : metric.attendanceDays,
        ]));
    }
};
exports.RankingsService = RankingsService;
exports.RankingsService = RankingsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        metrics_service_1.MetricsService])
], RankingsService);
//# sourceMappingURL=rankings.service.js.map