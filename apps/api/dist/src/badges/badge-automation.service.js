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
exports.BadgeAutomationService = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const DEFAULT_BADGES = [
    {
        code: 'ATTENDANCE_STARTER',
        name: '첫 출석',
        description: '첫 입실을 완료했습니다.',
        badgeType: client_1.BadgeType.ATTENDANCE,
    },
    {
        code: 'ATTENDANCE_STREAK_7',
        name: '7일 연속 출석',
        description: '7일 연속 출석을 달성했습니다.',
        badgeType: client_1.BadgeType.ATTENDANCE,
    },
    {
        code: 'STUDY_5H',
        name: '5시간 집중',
        description: '하루 공부 시간 5시간을 달성했습니다.',
        badgeType: client_1.BadgeType.STUDY_TIME,
    },
    {
        code: 'GOAL_ACHIEVER',
        name: '목표 달성',
        description: '하루 계획 달성률 100%를 달성했습니다.',
        badgeType: client_1.BadgeType.ACHIEVEMENT,
    },
];
let BadgeAutomationService = class BadgeAutomationService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async awardBadges() {
        await this.ensureDefaultBadges();
        const metrics = await this.prisma.dailyStudentMetric.findMany({
            where: { metricDate: (0, date_util_1.dateOnly)() },
        });
        for (const metric of metrics) {
            if (metric.attendanceStatus === 'CHECKED_IN' ||
                metric.attendanceStatus === 'CHECKED_OUT') {
                await this.give(metric.studentId, 'ATTENDANCE_STARTER', '첫 출석 달성');
            }
            if (metric.streakDays >= 7) {
                await this.give(metric.studentId, 'ATTENDANCE_STREAK_7', '7일 연속 출석 달성');
            }
            if (metric.studyMinutes >= 300) {
                await this.give(metric.studentId, 'STUDY_5H', '하루 5시간 공부 달성');
            }
            if (Number(metric.achievedRate) >= 100) {
                await this.give(metric.studentId, 'GOAL_ACHIEVER', '당일 목표 달성');
            }
        }
    }
    async ensureDefaultBadges() {
        for (const badge of DEFAULT_BADGES) {
            await this.prisma.badge.upsert({
                where: { code: badge.code },
                update: badge,
                create: badge,
            });
        }
    }
    async give(studentId, badgeCode, reason) {
        const badge = await this.prisma.badge.findUnique({
            where: { code: badgeCode },
        });
        if (!badge) {
            return;
        }
        const existing = await this.prisma.studentBadge.findFirst({
            where: { studentId, badgeId: badge.id },
        });
        if (existing) {
            return;
        }
        await this.prisma.studentBadge.create({
            data: {
                studentId,
                badgeId: badge.id,
                reason,
            },
        });
    }
};
exports.BadgeAutomationService = BadgeAutomationService;
__decorate([
    (0, schedule_1.Cron)('30 */20 * * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], BadgeAutomationService.prototype, "awardBadges", null);
exports.BadgeAutomationService = BadgeAutomationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], BadgeAutomationService);
//# sourceMappingURL=badge-automation.service.js.map