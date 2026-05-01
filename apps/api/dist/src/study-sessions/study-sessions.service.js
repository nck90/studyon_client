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
exports.StudySessionsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const notifications_service_1 = require("../notifications/notifications.service");
const points_service_1 = require("../points/points.service");
let StudySessionsService = class StudySessionsService {
    prisma;
    notificationsService;
    pointsService;
    constructor(prisma, notificationsService, pointsService) {
        this.prisma = prisma;
        this.notificationsService = notificationsService;
        this.pointsService = pointsService;
    }
    active(studentId) {
        return this.prisma.studySession
            .findFirst({
            where: {
                studentId,
                status: {
                    in: [client_1.StudySessionStatus.ACTIVE, client_1.StudySessionStatus.PAUSED],
                },
            },
            include: { linkedPlan: true, studyBreaks: true },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({
            success: true,
            data: data ? this.serializeSession(data) : null,
            meta: {},
        }));
    }
    async start(studentId, linkedPlanId) {
        const existing = await this.prisma.studySession.findFirst({
            where: {
                studentId,
                status: { in: [client_1.StudySessionStatus.ACTIVE, client_1.StudySessionStatus.PAUSED] },
            },
        });
        if (existing) {
            throw new common_1.BadRequestException('이미 진행 중인 공부 세션이 있습니다.');
        }
        const attendance = await this.prisma.attendance.findUnique({
            where: {
                studentId_attendanceDate: { studentId, attendanceDate: (0, date_util_1.dateOnly)() },
            },
        });
        const session = await this.prisma.studySession.create({
            data: {
                studentId,
                attendanceId: attendance?.id,
                linkedPlanId,
                sessionDate: (0, date_util_1.dateOnly)(),
                status: client_1.StudySessionStatus.ACTIVE,
                startedAt: new Date(),
            },
            include: { linkedPlan: true, studyBreaks: true },
        });
        if (linkedPlanId) {
            await this.prisma.studyPlan.update({
                where: { id: linkedPlanId },
                data: { status: 'IN_PROGRESS' },
            });
        }
        await this.notifyStudent(studentId, '공부를 시작했어요', linkedPlanId
            ? '선택한 계획으로 공부 세션이 시작되었습니다.'
            : '새 공부 세션이 시작되었습니다.');
        return { success: true, data: this.serializeSession(session), meta: {} };
    }
    async pause(studentId, sessionId) {
        const session = await this.prisma.studySession.findFirst({
            where: { id: sessionId, studentId, status: client_1.StudySessionStatus.ACTIVE },
        });
        if (!session) {
            throw new common_1.BadRequestException('활성 세션이 아닙니다.');
        }
        const updated = await this.prisma.$transaction(async (tx) => {
            await tx.studyBreak.create({
                data: { studySessionId: sessionId, startedAt: new Date() },
            });
            return tx.studySession.update({
                where: { id: sessionId },
                data: { status: client_1.StudySessionStatus.PAUSED },
                include: { linkedPlan: true, studyBreaks: true },
            });
        });
        await this.notifyStudent(studentId, '휴식 시작', '공부 세션이 일시정지되고 휴식 시간이 기록됩니다.');
        return { success: true, data: this.serializeSession(updated), meta: {} };
    }
    async resume(studentId, sessionId) {
        const session = await this.prisma.studySession.findFirst({
            where: { id: sessionId, studentId, status: client_1.StudySessionStatus.PAUSED },
            include: { studyBreaks: true },
        });
        if (!session) {
            throw new common_1.BadRequestException('일시정지 상태의 세션이 아닙니다.');
        }
        const activeBreak = session.studyBreaks.find((item) => !item.endedAt);
        if (!activeBreak) {
            throw new common_1.BadRequestException('활성 휴식 구간이 없습니다.');
        }
        const now = new Date();
        const breakSeconds = (0, date_util_1.diffSeconds)(activeBreak.startedAt, now);
        const breakMinutes = Math.floor(breakSeconds / 60);
        const updated = await this.prisma.$transaction(async (tx) => {
            await tx.studyBreak.update({
                where: { id: activeBreak.id },
                data: { endedAt: now, breakMinutes, breakSeconds },
            });
            const breaks = await tx.studyBreak.findMany({
                where: { studySessionId: sessionId },
            });
            const totalBreakSeconds = breaks.reduce((sum, item) => sum + item.breakSeconds, 0);
            return tx.studySession.update({
                where: { id: sessionId },
                data: {
                    status: client_1.StudySessionStatus.ACTIVE,
                    breakMinutes: Math.floor(totalBreakSeconds / 60),
                    breakSeconds: totalBreakSeconds,
                },
                include: { linkedPlan: true, studyBreaks: true },
            });
        });
        await this.notifyStudent(studentId, '공부 재개', '휴식이 종료되고 공부 세션이 다시 시작되었습니다.');
        return { success: true, data: this.serializeSession(updated), meta: {} };
    }
    async end(studentId, sessionId) {
        const session = await this.prisma.studySession.findFirst({
            where: {
                id: sessionId,
                studentId,
                status: { in: [client_1.StudySessionStatus.ACTIVE, client_1.StudySessionStatus.PAUSED] },
            },
            include: { studyBreaks: true },
        });
        if (!session || !session.startedAt) {
            throw new common_1.BadRequestException('세션을 종료할 수 없습니다.');
        }
        const now = new Date();
        const result = await this.prisma.$transaction(async (tx) => {
            const openBreak = session.studyBreaks.find((item) => !item.endedAt);
            if (openBreak) {
                const breakSeconds = (0, date_util_1.diffSeconds)(openBreak.startedAt, now);
                await tx.studyBreak.update({
                    where: { id: openBreak.id },
                    data: {
                        endedAt: now,
                        breakMinutes: Math.floor(breakSeconds / 60),
                        breakSeconds,
                    },
                });
            }
            const breaks = await tx.studyBreak.findMany({
                where: { studySessionId: sessionId },
            });
            const breakSeconds = breaks.reduce((sum, item) => sum + item.breakSeconds, 0);
            const totalSeconds = (0, date_util_1.diffSeconds)(session.startedAt, now);
            const studySeconds = Math.max(0, totalSeconds - breakSeconds);
            const studyMinutes = Math.floor(studySeconds / 60);
            const breakMinutes = Math.floor(breakSeconds / 60);
            const updated = await tx.studySession.update({
                where: { id: sessionId },
                data: {
                    status: client_1.StudySessionStatus.COMPLETED,
                    endedAt: now,
                    breakMinutes,
                    breakSeconds,
                    studyMinutes,
                    studySeconds,
                },
                include: { linkedPlan: true, studyBreaks: true },
            });
            return updated;
        });
        await this.pointsService.awardStudySessionTime(studentId, result.id, result.studySeconds);
        await this.notifyStudent(studentId, '공부 세션 완료', `이번 세션에서 ${result.studyMinutes}분 공부를 기록했어요.`);
        return { success: true, data: this.serializeSession(result), meta: {} };
    }
    list(studentId, startDate, endDate) {
        return this.prisma.studySession
            .findMany({
            where: {
                studentId,
                sessionDate: {
                    gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                    lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                },
            },
            include: { linkedPlan: true, studyBreaks: true },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({
            success: true,
            data: data.map((item) => this.serializeSession(item)),
            meta: {},
        }));
    }
    serializeSession(session) {
        const durations = this.resolveSessionDurations(session);
        return {
            ...session,
            studyMinutes: durations.studyMinutes,
            studySeconds: durations.studySeconds,
            breakMinutes: durations.breakMinutes,
            breakSeconds: durations.breakSeconds,
        };
    }
    resolveSessionDurations(session) {
        if (!session.startedAt) {
            return {
                studyMinutes: session.studyMinutes,
                studySeconds: session.studySeconds,
                breakMinutes: session.breakMinutes,
                breakSeconds: session.breakSeconds,
            };
        }
        const now = new Date();
        const closedBreakSeconds = session.studyBreaks
            ?.filter((item) => item.endedAt != null)
            .reduce((sum, item) => sum +
            (item.breakSeconds > 0
                ? item.breakSeconds
                : (0, date_util_1.diffSeconds)(item.startedAt, item.endedAt)), 0) ?? session.breakSeconds;
        const openBreakSeconds = session.studyBreaks
            ?.filter((item) => item.endedAt == null)
            .reduce((sum, item) => sum + (0, date_util_1.diffSeconds)(item.startedAt, now), 0) ?? 0;
        const totalBreakSeconds = closedBreakSeconds + openBreakSeconds;
        const endAt = session.endedAt ?? now;
        const totalSeconds = (0, date_util_1.diffSeconds)(session.startedAt, endAt);
        const studySeconds = Math.max(0, totalSeconds - totalBreakSeconds);
        return {
            studyMinutes: Math.floor(studySeconds / 60),
            studySeconds,
            breakMinutes: Math.floor(totalBreakSeconds / 60),
            breakSeconds: totalBreakSeconds,
        };
    }
    async notifyStudent(studentId, title, body, notificationType = client_1.NotificationType.NOTICE) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
            select: { userId: true },
        });
        if (!student?.userId) {
            return;
        }
        await this.notificationsService.sendDirectToUsers({
            userIds: [student.userId],
            notificationType,
            channel: client_1.NotificationChannel.IN_APP,
            title,
            body,
        });
    }
};
exports.StudySessionsService = StudySessionsService;
exports.StudySessionsService = StudySessionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        notifications_service_1.NotificationsService,
        points_service_1.PointsService])
], StudySessionsService);
//# sourceMappingURL=study-sessions.service.js.map