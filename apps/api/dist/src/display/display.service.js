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
    async current() {
        const settings = await this.settingsService.getTvDisplay();
        return {
            success: true,
            data: this.normalizeSettings(settings.data),
            meta: {},
        };
    }
    async rankings(periodType = client_1.RankingPeriodType.DAILY, rankingType = client_1.RankingType.STUDY_TIME) {
        const ranking = await this.rankingsService.adminRanking(periodType, rankingType);
        return {
            success: true,
            data: {
                ...ranking.data,
                items: ranking.data.items.map((item) => ({
                    ...item,
                    displayName: this.maskName(item.student.user.name),
                    student: {
                        ...item.student,
                        user: { name: this.maskName(item.student.user.name) },
                    },
                })),
            },
            meta: ranking.meta,
        };
    }
    async seats() {
        const seats = await this.prisma.seat.findMany({
            where: { isActive: true },
            include: { currentStudent: { include: { user: true } } },
            orderBy: [{ zone: 'asc' }, { seatNo: 'asc' }],
        });
        return {
            success: true,
            data: seats.map((seat) => ({
                id: seat.id,
                seatNo: seat.seatNo,
                zone: seat.zone,
                status: seat.status,
                uiStatus: this.toSeatUiStatus(seat.status, Boolean(seat.currentStudent)),
                currentStudent: seat.currentStudent
                    ? {
                        id: seat.currentStudent.id,
                        displayName: this.maskName(seat.currentStudent.user.name),
                    }
                    : null,
            })),
            meta: {},
        };
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
                        displayName: this.maskName(topStudent.student.user.name),
                        rankNo: topStudent.rankNo,
                        score: Number(topStudent.score),
                    }
                    : null,
                challenge: '연속 출석 7일 챌린지 진행 중',
            },
            meta: {},
        };
    }
    async goals() {
        const settings = await this.prisma.appSetting.findMany({
            where: {
                settingKey: { startsWith: 'student:', endsWith: ':preferences' },
            },
            take: 200,
        });
        const approved = settings
            .map((setting) => ({
            studentId: this.studentIdFromPreferenceKey(setting.settingKey),
            value: (setting.settingValue ?? {}),
        }))
            .filter((item) => Boolean(item.studentId) &&
            item.value.tvGoalConsent === true &&
            item.value.tvGoalApprovalStatus === 'APPROVED' &&
            typeof item.value.targetUniversityName === 'string' &&
            item.value.targetUniversityName.trim().length > 0);
        const students = approved.length
            ? await this.prisma.student.findMany({
                where: { id: { in: approved.map((item) => item.studentId) } },
                include: { user: true },
            })
            : [];
        const studentById = new Map(students.map((student) => [student.id, student]));
        const mediaIds = approved
            .map((item) => item.value.targetUniversityMediaId)
            .filter((id) => typeof id === 'string');
        const media = mediaIds.length
            ? await this.prisma.mediaAsset.findMany({
                where: { id: { in: mediaIds } },
            })
            : [];
        const mediaById = new Map(media.map((item) => [item.id, item]));
        const today = (0, date_util_1.startOfDay)();
        const achievers = await this.prisma.dailyStudentMetric.findMany({
            where: { metricDate: today, achievedRate: { gte: 100 } },
            include: { student: { include: { user: true } } },
            orderBy: [{ achievedRate: 'desc' }],
            take: 8,
        });
        return {
            success: true,
            data: {
                goals: approved.slice(0, 12).map((item) => {
                    const student = studentById.get(item.studentId);
                    const mediaId = item.value.targetUniversityMediaId;
                    return {
                        studentId: item.studentId,
                        displayName: student ? this.maskName(student.user.name) : '학생',
                        targetUniversityName: item.value.targetUniversityName,
                        targetUniversityMedia: typeof mediaId === 'string'
                            ? (mediaById.get(mediaId) ?? { id: mediaId })
                            : null,
                    };
                }),
                achievers: achievers.map((metric) => ({
                    displayName: this.maskName(metric.student.user.name),
                    achievedRate: Number(metric.achievedRate),
                    studyMinutes: metric.studyMinutes,
                })),
            },
            meta: {},
        };
    }
    control(activeScreen) {
        return this.settingsService.updateTvDisplay({ activeScreen });
    }
    normalizeSettings(settings) {
        const record = settings;
        const options = record?.displayOptions && typeof record.displayOptions === 'object'
            ? record.displayOptions
            : {};
        const activeScreen = this.normalizeScreen(record?.activeScreen);
        const enabledScreens = Array.isArray(options.enabledScreens)
            ? options.enabledScreens
                .map((item) => this.normalizeScreen(item))
                .filter((item, index, list) => list.indexOf(item) === index)
            : [];
        return {
            activeScreen,
            rotationEnabled: record?.rotationEnabled ?? true,
            rotationIntervalSeconds: record?.rotationIntervalSeconds ?? 30,
            enabledScreens: enabledScreens.length > 0
                ? enabledScreens
                : ['RANKING', 'SEAT_MAP', 'MESSAGE', 'CLOCK', 'GOAL_WALL'],
            message: typeof options.message === 'string' && options.message.trim().length > 0
                ? options.message
                : '오늘도 목표를 끝까지 완수하세요.',
            rankingType: typeof options.rankingType === 'string'
                ? options.rankingType
                : client_1.RankingType.STUDY_TIME,
            periodType: typeof options.periodType === 'string'
                ? options.periodType
                : client_1.RankingPeriodType.DAILY,
            updatedAt: record?.updatedAt?.toISOString?.() ?? null,
        };
    }
    normalizeScreen(value) {
        if (value === 'STATUS')
            return 'SEAT_MAP';
        if (value === 'MOTIVATION')
            return 'MESSAGE';
        if (value === 'RANKING' ||
            value === 'SEAT_MAP' ||
            value === 'MESSAGE' ||
            value === 'CLOCK' ||
            value === 'GOAL_WALL') {
            return value;
        }
        return 'RANKING';
    }
    studentIdFromPreferenceKey(key) {
        const match = /^student:([^:]+):preferences$/.exec(key);
        return match?.[1] ?? null;
    }
    toSeatUiStatus(status, occupied) {
        if (status === client_1.SeatStatus.LOCKED)
            return 'locked';
        if (occupied || status === client_1.SeatStatus.OCCUPIED)
            return 'occupied';
        if (status === client_1.SeatStatus.RESERVED)
            return 'reserved';
        return 'empty';
    }
    maskName(name) {
        const trimmed = name.trim();
        if (trimmed.length <= 1)
            return trimmed;
        if (trimmed.length === 2)
            return `${trimmed[0]}*`;
        return `${trimmed[0]}${'*'.repeat(trimmed.length - 2)}${trimmed.at(-1)}`;
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