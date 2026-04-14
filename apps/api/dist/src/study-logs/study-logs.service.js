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
let StudyLogsService = class StudyLogsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
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
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    create(studentId, dto) {
        return this.prisma.studyLog
            .create({
            data: {
                studentId,
                planId: dto.planId,
                studySessionId: dto.studySessionId,
                logDate: (0, date_util_1.dateOnly)(dto.logDate),
                subjectName: dto.subjectName,
                pagesCompleted: dto.pagesCompleted,
                problemsSolved: dto.problemsSolved,
                progressPercent: dto.progressPercent,
                isCompleted: dto.isCompleted,
                memo: dto.memo,
            },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async update(studentId, logId, dto) {
        const item = await this.prisma.studyLog.findFirst({
            where: { id: logId, studentId },
        });
        if (!item) {
            throw new common_1.NotFoundException('학습 기록을 찾을 수 없습니다.');
        }
        const updated = await this.prisma.studyLog.update({
            where: { id: logId },
            data: {
                planId: dto.planId,
                studySessionId: dto.studySessionId,
                logDate: dto.logDate ? (0, date_util_1.dateOnly)(dto.logDate) : undefined,
                subjectName: dto.subjectName,
                pagesCompleted: dto.pagesCompleted,
                problemsSolved: dto.problemsSolved,
                progressPercent: dto.progressPercent,
                isCompleted: dto.isCompleted,
                memo: dto.memo,
            },
        });
        return { success: true, data: updated, meta: {} };
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
};
exports.StudyLogsService = StudyLogsService;
exports.StudyLogsService = StudyLogsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StudyLogsService);
//# sourceMappingURL=study-logs.service.js.map