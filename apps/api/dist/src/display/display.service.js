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
exports.DisplayService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const rankings_service_1 = require("../rankings/rankings.service");
const settings_service_1 = require("../settings/settings.service");
let DisplayService = class DisplayService {
    prisma;
    rankingsService;
    settingsService;
    constructor(prisma, rankingsService, settingsService) {
        this.prisma = prisma;
        this.rankingsService = rankingsService;
        this.settingsService = settingsService;
    }
    current() {
        return this.settingsService.getTvDisplay();
    }
    rankings(periodType = client_1.RankingPeriodType.DAILY, rankingType = client_1.RankingType.STUDY_TIME) {
        return this.rankingsService.adminRanking(periodType, rankingType);
    }
    async status() {
        const [checkedInCount, totalSeats, occupiedSeats, sessions] = await Promise.all([
            this.prisma.attendance.count({
                where: {
                    attendanceStatus: 'CHECKED_IN',
                    attendanceDate: (0, date_util_1.startOfDay)(),
                },
            }),
            this.prisma.seat.count({ where: { isActive: true } }),
            this.prisma.seat.count({ where: { status: 'OCCUPIED' } }),
            this.prisma.studySession.findMany({
                where: { sessionDate: (0, date_util_1.startOfDay)() },
                include: { studyBreaks: true },
            }),
        ]);
        const now = new Date();
        const sessionStudyMinutes = sessions.reduce((sum, session) => {
            if (!session.startedAt) {
                return sum + session.studyMinutes;
            }
            const breakMinutes = session.breakMinutes +
                session.studyBreaks
                    .filter((item) => !item.endedAt)
                    .reduce((carry, item) => carry + (0, date_util_1.diffMinutes)(item.startedAt, now), 0);
            if (session.endedAt) {
                return sum + session.studyMinutes;
            }
            const elapsed = (0, date_util_1.diffMinutes)(session.startedAt, now);
            return sum + Math.max(0, elapsed - breakMinutes);
        }, 0);
        const liveStudyMinutes = sessions
            .filter((item) => item.status === 'ACTIVE' && item.startedAt)
            .reduce((sum, session) => {
            const openBreakMinutes = session.studyBreaks
                .filter((item) => !item.endedAt)
                .reduce((carry, item) => carry + (0, date_util_1.diffMinutes)(item.startedAt, now), 0);
            return (sum +
                Math.max(0, (0, date_util_1.diffMinutes)(session.startedAt, now) -
                    session.breakMinutes -
                    openBreakMinutes));
        }, 0);
        return {
            success: true,
            data: {
                checkedInCount,
                seatOccupancyRate: totalSeats === 0
                    ? 0
                    : Number(((occupiedSeats / totalSeats) * 100).toFixed(2)),
                liveStudyMinutes,
                todayTotalStudyMinutes: sessionStudyMinutes,
            },
            meta: {},
        };
    }
    async motivation() {
        const topStudent = await this.prisma.rankingSnapshotItem.findFirst({
            orderBy: [{ createdAt: 'desc' }, { rankNo: 'asc' }],
            include: { student: { include: { user: true } } },
        });
        return {
            success: true,
            data: {
                message: '오늘 목표를 끝까지 완수하세요.',
                topStudent: topStudent
                    ? {
                        name: topStudent.student.user.name,
                        rankNo: topStudent.rankNo,
                        score: Number(topStudent.score),
                    }
                    : null,
                challenge: '연속 출석 7일 챌린지 진행 중',
            },
            meta: {},
        };
    }
    control(activeScreen) {
        return this.settingsService.updateTvDisplay({ activeScreen });
    }
};
exports.DisplayService = DisplayService;
exports.DisplayService = DisplayService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        rankings_service_1.RankingsService,
        settings_service_1.SettingsService])
], DisplayService);
//# sourceMappingURL=display.service.js.map