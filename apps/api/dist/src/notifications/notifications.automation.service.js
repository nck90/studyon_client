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
exports.NotificationsAutomationService = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const settings_service_1 = require("../settings/settings.service");
const notifications_service_1 = require("./notifications.service");
let NotificationsAutomationService = class NotificationsAutomationService {
    prisma;
    settingsService;
    notificationsService;
    constructor(prisma, settingsService, notificationsService) {
        this.prisma = prisma;
        this.settingsService = settingsService;
        this.notificationsService = notificationsService;
    }
    async run() {
        await this.processScheduledNotifications();
        await this.processAbsenceAlerts();
        await this.processBreakAlerts();
        await this.processGoalShortfallAlerts();
    }
    async processScheduledNotifications() {
        const scheduled = await this.prisma.notification.findMany({
            where: {
                status: 'SCHEDULED',
                scheduledAt: { lte: new Date() },
            },
            select: { id: true },
            take: 50,
        });
        for (const item of scheduled) {
            await this.notificationsService.send(item.id);
        }
    }
    async processAbsenceAlerts() {
        const policyResult = await this.settingsService.getAttendancePolicy();
        const cutoff = policyResult.data?.lateCutoffTime ?? '09:00';
        if (!this.hasPassedTime(cutoff)) {
            return;
        }
        const today = new Date(new Date().toISOString().slice(0, 10));
        const students = await this.prisma.student.findMany({
            where: {
                enrollmentStatus: 'ACTIVE',
                attendances: {
                    none: {
                        attendanceDate: today,
                        attendanceStatus: {
                            in: [client_1.AttendanceStatus.CHECKED_IN, client_1.AttendanceStatus.CHECKED_OUT],
                        },
                    },
                },
            },
            include: { user: true },
            take: 100,
        });
        for (const student of students) {
            await this.sendAutomatedStudentNotification({
                userId: student.userId,
                title: '미입실 알림',
                body: `${student.user.name} 학생이 아직 입실하지 않았습니다.`,
                notificationType: client_1.NotificationType.ABSENCE,
            });
        }
    }
    async processBreakAlerts() {
        const sessions = await this.prisma.studySession.findMany({
            where: { status: client_1.StudySessionStatus.PAUSED },
            include: {
                student: { include: { user: true } },
                studyBreaks: { orderBy: { createdAt: 'desc' }, take: 1 },
            },
            take: 100,
        });
        const thresholdMinutes = 15;
        for (const session of sessions) {
            const latestBreak = session.studyBreaks[0];
            if (!latestBreak?.startedAt || latestBreak.endedAt) {
                continue;
            }
            const elapsedMinutes = Math.floor((Date.now() - latestBreak.startedAt.getTime()) / 60000);
            if (elapsedMinutes < thresholdMinutes) {
                continue;
            }
            await this.sendAutomatedStudentNotification({
                userId: session.student.userId,
                title: '휴식 시간 초과 알림',
                body: `${session.student.user.name} 학생의 휴식 시간이 ${thresholdMinutes}분을 초과했습니다.`,
                notificationType: client_1.NotificationType.BREAK_OVER,
            });
        }
    }
    async processGoalShortfallAlerts() {
        if (!this.hasPassedTime('21:00')) {
            return;
        }
        const today = new Date(new Date().toISOString().slice(0, 10));
        const students = await this.prisma.student.findMany({
            where: { enrollmentStatus: 'ACTIVE' },
            include: { user: true },
            take: 100,
        });
        for (const student of students) {
            const [plans, sessions] = await Promise.all([
                this.prisma.studyPlan.findMany({
                    where: { studentId: student.id, planDate: today },
                }),
                this.prisma.studySession.findMany({
                    where: { studentId: student.id, sessionDate: today },
                }),
            ]);
            const targetMinutes = plans.reduce((sum, item) => sum + item.targetMinutes, 0);
            if (targetMinutes <= 0) {
                continue;
            }
            const studyMinutes = sessions.reduce((sum, item) => sum + item.studyMinutes, 0);
            if (studyMinutes >= targetMinutes) {
                continue;
            }
            await this.sendAutomatedStudentNotification({
                userId: student.userId,
                title: '목표 미달성 알림',
                body: `${student.user.name} 학생의 오늘 공부 시간이 목표 대비 부족합니다.`,
                notificationType: client_1.NotificationType.GOAL_SHORTFALL,
            });
        }
    }
    async sendAutomatedStudentNotification(input) {
        const existing = await this.prisma.notificationReceipt.findFirst({
            where: {
                userId: input.userId,
                notification: {
                    notificationType: input.notificationType,
                    title: input.title,
                    createdAt: { gte: (0, date_util_1.startOfDay)() },
                },
            },
        });
        if (existing) {
            return;
        }
        await this.notificationsService.sendDirectToUsers({
            userIds: [input.userId],
            notificationType: input.notificationType,
            channel: client_1.NotificationChannel.IN_APP,
            title: input.title,
            body: input.body,
        });
    }
    hasPassedTime(time) {
        const [hours, minutes] = time.split(':').map(Number);
        const now = new Date();
        return (now.getHours() > hours ||
            (now.getHours() === hours && now.getMinutes() >= minutes));
    }
};
exports.NotificationsAutomationService = NotificationsAutomationService;
__decorate([
    (0, schedule_1.Cron)('0 */5 * * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], NotificationsAutomationService.prototype, "run", null);
exports.NotificationsAutomationService = NotificationsAutomationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        settings_service_1.SettingsService,
        notifications_service_1.NotificationsService])
], NotificationsAutomationService);
//# sourceMappingURL=notifications.automation.service.js.map