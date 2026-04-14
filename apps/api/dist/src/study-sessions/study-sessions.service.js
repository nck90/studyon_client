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
let StudySessionsService = class StudySessionsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
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
            .then((data) => ({ success: true, data, meta: {} }));
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
            include: { linkedPlan: true },
        });
        if (linkedPlanId) {
            await this.prisma.studyPlan.update({
                where: { id: linkedPlanId },
                data: { status: 'IN_PROGRESS' },
            });
        }
        return { success: true, data: session, meta: {} };
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
            });
        });
        return { success: true, data: updated, meta: {} };
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
        const breakMinutes = (0, date_util_1.diffMinutes)(activeBreak.startedAt, now);
        const updated = await this.prisma.$transaction(async (tx) => {
            await tx.studyBreak.update({
                where: { id: activeBreak.id },
                data: { endedAt: now, breakMinutes },
            });
            const breaks = await tx.studyBreak.findMany({
                where: { studySessionId: sessionId },
            });
            return tx.studySession.update({
                where: { id: sessionId },
                data: {
                    status: client_1.StudySessionStatus.ACTIVE,
                    breakMinutes: breaks.reduce((sum, item) => sum + item.breakMinutes, 0),
                },
            });
        });
        return { success: true, data: updated, meta: {} };
    }
    async end(studentId, sessionId) {
        const session = await this.prisma.studySession.findFirst({
            where: { id: sessionId, studentId },
            include: { studyBreaks: true },
        });
        if (!session || !session.startedAt) {
            throw new common_1.BadRequestException('세션을 종료할 수 없습니다.');
        }
        const now = new Date();
        const result = await this.prisma.$transaction(async (tx) => {
            const openBreak = session.studyBreaks.find((item) => !item.endedAt);
            if (openBreak) {
                await tx.studyBreak.update({
                    where: { id: openBreak.id },
                    data: {
                        endedAt: now,
                        breakMinutes: (0, date_util_1.diffMinutes)(openBreak.startedAt, now),
                    },
                });
            }
            const breaks = await tx.studyBreak.findMany({
                where: { studySessionId: sessionId },
            });
            const breakMinutes = breaks.reduce((sum, item) => sum + item.breakMinutes, 0);
            const totalMinutes = (0, date_util_1.diffMinutes)(session.startedAt, now);
            const studyMinutes = Math.max(0, totalMinutes - breakMinutes);
            return tx.studySession.update({
                where: { id: sessionId },
                data: {
                    status: client_1.StudySessionStatus.COMPLETED,
                    endedAt: now,
                    breakMinutes,
                    studyMinutes,
                },
            });
        });
        return { success: true, data: result, meta: {} };
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
            include: { linkedPlan: true },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
};
exports.StudySessionsService = StudySessionsService;
exports.StudySessionsService = StudySessionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StudySessionsService);
//# sourceMappingURL=study-sessions.service.js.map