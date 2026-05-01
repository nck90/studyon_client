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
exports.StudyLogsService = void 0;
const common_1 = require("@nestjs/common");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const points_service_1 = require("../points/points.service");
let StudyLogsService = class StudyLogsService {
    prisma;
    pointsService;
    constructor(prisma, pointsService) {
        this.prisma = prisma;
        this.pointsService = pointsService;
    }
    list(studentId, date, startDate, endDate) {
        return this.prisma.studyLog
            .findMany({
            where: {
                studentId,
                logDate: date
                    ? (0, date_util_1.dateOnly)(date)
                    : {
                        gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                        lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                    },
            },
            include: {
                plan: {
                    select: {
                        id: true,
                        title: true,
                        targetMinutes: true,
                    },
                },
                studySession: {
                    select: {
                        id: true,
                        status: true,
                        startedAt: true,
                        endedAt: true,
                        studyMinutes: true,
                        studySeconds: true,
                        breakMinutes: true,
                        breakSeconds: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({
            success: true,
            data: data.map((item) => this.serializeDecimal(item)),
            meta: {},
        }));
    }
    create(studentId, dto) {
        return this.resolveStudyDuration(studentId, dto).then(({ studyMinutes, studySeconds }) => this.prisma.studyLog
            .create({
            data: {
                studentId,
                planId: dto.planId,
                studySessionId: dto.studySessionId,
                logDate: (0, date_util_1.dateOnly)(dto.logDate),
                subjectName: dto.subjectName,
                studyMinutes,
                studySeconds,
                pagesCompleted: dto.pagesCompleted,
                problemsSolved: dto.problemsSolved,
                progressPercent: dto.progressPercent,
                isCompleted: dto.isCompleted,
                memo: dto.memo,
            },
        })
            .then(async (data) => {
            if (!data.studySessionId && (data.studySeconds ?? 0) > 0) {
                await this.pointsService
                    .earnStudyTime(studentId, data.studySeconds, `수기 기록 ${data.subjectName}`)
                    .catch(() => { });
            }
            return {
                success: true,
                data: this.serializeDecimal(data),
                meta: {},
            };
        }));
    }
    async update(studentId, logId, dto) {
        const item = await this.prisma.studyLog.findFirst({
            where: { id: logId, studentId },
        });
        if (!item) {
            throw new common_1.NotFoundException('학습 기록을 찾을 수 없습니다.');
        }
        const duration = dto.studyMinutes !== undefined ||
            dto.studySeconds !== undefined ||
            dto.studySessionId !== undefined
            ? await this.resolveStudyDuration(studentId, dto)
            : undefined;
        const updated = await this.prisma.studyLog.update({
            where: { id: logId },
            data: {
                planId: dto.planId,
                studySessionId: dto.studySessionId,
                logDate: dto.logDate ? (0, date_util_1.dateOnly)(dto.logDate) : undefined,
                subjectName: dto.subjectName,
                studyMinutes: duration?.studyMinutes,
                studySeconds: duration?.studySeconds,
                pagesCompleted: dto.pagesCompleted,
                problemsSolved: dto.problemsSolved,
                progressPercent: dto.progressPercent,
                isCompleted: dto.isCompleted,
                memo: dto.memo,
            },
        });
        return { success: true, data: this.serializeDecimal(updated), meta: {} };
    }
    async remove(studentId, logId) {
        const item = await this.prisma.studyLog.findFirst({
            where: { id: logId, studentId },
        });
        if (!item) {
            throw new common_1.NotFoundException('학습 기록을 찾을 수 없습니다.');
        }
        await this.prisma.studyLog.delete({ where: { id: logId } });
        return { success: true, data: { deleted: true, logId }, meta: {} };
    }
    serializeDecimal(record) {
        return {
            ...record,
            progressPercent: record.progressPercent != null ? Number(record.progressPercent) : 0,
        };
    }
    async resolveStudyDuration(studentId, dto) {
        if (dto.studySeconds !== undefined) {
            return {
                studySeconds: dto.studySeconds,
                studyMinutes: Math.floor(dto.studySeconds / 60),
            };
        }
        if (dto.studyMinutes !== undefined) {
            return {
                studySeconds: dto.studyMinutes * 60,
                studyMinutes: dto.studyMinutes,
            };
        }
        if (!dto.studySessionId) {
            return { studyMinutes: 0, studySeconds: 0 };
        }
        const session = await this.prisma.studySession.findFirst({
            where: { id: dto.studySessionId, studentId },
            select: { studyMinutes: true, studySeconds: true },
        });
        return {
            studyMinutes: session?.studyMinutes ?? 0,
            studySeconds: session?.studySeconds ?? (session?.studyMinutes ?? 0) * 60,
        };
    }
};
exports.StudyLogsService = StudyLogsService;
exports.StudyLogsService = StudyLogsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        points_service_1.PointsService])
], StudyLogsService);
//# sourceMappingURL=study-logs.service.js.map