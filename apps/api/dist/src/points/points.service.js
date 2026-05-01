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
exports.PointsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../database/prisma.service");
const points_util_1 = require("./points.util");
let PointsService = class PointsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getBalance(studentId) {
        const student = await this.prisma.student.findUniqueOrThrow({
            where: { id: studentId },
            select: { pointBalance: true },
        });
        return { success: true, data: { balance: student.pointBalance }, meta: {} };
    }
    async getHistory(studentId, take = 50, skip = 0) {
        const [items, total] = await Promise.all([
            this.prisma.pointTransaction.findMany({
                where: { studentId },
                orderBy: { createdAt: 'desc' },
                take,
                skip,
            }),
            this.prisma.pointTransaction.count({ where: { studentId } }),
        ]);
        return { success: true, data: items, meta: { total, take, skip } };
    }
    async earnStudyTime(studentId, studySeconds, memo, source = client_1.PointSource.STUDY_TIME) {
        const amount = (0, points_util_1.calculateStudyTimePoints)(studySeconds);
        if (amount <= 0) {
            return null;
        }
        return this.earn(studentId, amount, source, memo);
    }
    async awardStudySessionTime(studentId, sessionId, studySeconds) {
        const amount = (0, points_util_1.calculateStudyTimePoints)(studySeconds);
        if (amount <= 0) {
            return null;
        }
        const marker = `[study-session:${sessionId}]`;
        const existing = await this.prisma.pointTransaction.findFirst({
            where: {
                studentId,
                source: client_1.PointSource.STUDY_TIME,
                memo: { startsWith: marker },
            },
            select: { balance: true },
        });
        if (existing) {
            return existing.balance;
        }
        const studyMinutes = Math.floor(studySeconds / 60);
        return this.earn(studentId, amount, client_1.PointSource.STUDY_TIME, `${marker} 타이머 공부 ${studyMinutes}분`);
    }
    async earn(studentId, amount, source, memo) {
        if (amount <= 0)
            return;
        return this.prisma.$transaction(async (tx) => {
            const student = await tx.student.update({
                where: { id: studentId },
                data: { pointBalance: { increment: amount } },
                select: { pointBalance: true },
            });
            await tx.pointTransaction.create({
                data: {
                    studentId,
                    type: client_1.PointTransactionType.EARN,
                    source,
                    amount,
                    balance: student.pointBalance,
                    memo,
                },
            });
            return student.pointBalance;
        });
    }
    async spend(studentId, amount, source, memo) {
        if (amount <= 0)
            throw new common_1.BadRequestException('금액이 올바르지 않습니다.');
        return this.prisma.$transaction(async (tx) => {
            const student = await tx.student.findUniqueOrThrow({
                where: { id: studentId },
                select: { pointBalance: true },
            });
            if (student.pointBalance < amount) {
                throw new common_1.BadRequestException('포인트가 부족합니다.');
            }
            const updated = await tx.student.update({
                where: { id: studentId },
                data: { pointBalance: { decrement: amount } },
                select: { pointBalance: true },
            });
            await tx.pointTransaction.create({
                data: {
                    studentId,
                    type: client_1.PointTransactionType.SPEND,
                    source,
                    amount: -amount,
                    balance: updated.pointBalance,
                    memo,
                },
            });
            return updated.pointBalance;
        });
    }
};
exports.PointsService = PointsService;
exports.PointsService = PointsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PointsService);
//# sourceMappingURL=points.service.js.map