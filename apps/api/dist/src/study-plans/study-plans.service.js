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
exports.StudyPlansService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
let StudyPlansService = class StudyPlansService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    list(studentId, date) {
        return this.prisma.studyPlan
            .findMany({
            where: {
                studentId,
                planDate: date ? (0, date_util_1.dateOnly)(date) : undefined,
            },
            orderBy: [{ priority: 'asc' }, { createdAt: 'desc' }],
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async get(studentId, planId) {
        const plan = await this.prisma.studyPlan.findFirst({
            where: { id: planId, studentId },
        });
        if (!plan) {
            throw new common_1.NotFoundException('계획을 찾을 수 없습니다.');
        }
        return { success: true, data: plan, meta: {} };
    }
    create(studentId, dto) {
        return this.prisma.studyPlan
            .create({
            data: {
                studentId,
                planDate: (0, date_util_1.dateOnly)(dto.planDate),
                subjectName: dto.subjectName,
                title: dto.title,
                description: dto.description,
                targetMinutes: dto.targetMinutes,
                priority: dto.priority,
            },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async update(studentId, planId, dto) {
        await this.get(studentId, planId);
        const plan = await this.prisma.studyPlan.update({
            where: { id: planId },
            data: {
                planDate: dto.planDate ? (0, date_util_1.dateOnly)(dto.planDate) : undefined,
                subjectName: dto.subjectName,
                title: dto.title,
                description: dto.description,
                targetMinutes: dto.targetMinutes,
                priority: dto.priority,
            },
        });
        return { success: true, data: plan, meta: {} };
    }
    async remove(studentId, planId) {
        await this.get(studentId, planId);
        await this.prisma.studyPlan.delete({ where: { id: planId } });
        return { success: true, data: { deleted: true, planId }, meta: {} };
    }
    async complete(studentId, planId) {
        await this.get(studentId, planId);
        const plan = await this.prisma.studyPlan.update({
            where: { id: planId },
            data: { status: client_1.StudyPlanStatus.COMPLETED, completedAt: new Date() },
        });
        return { success: true, data: plan, meta: {} };
    }
};
exports.StudyPlansService = StudyPlansService;
exports.StudyPlansService = StudyPlansService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StudyPlansService);
//# sourceMappingURL=study-plans.service.js.map