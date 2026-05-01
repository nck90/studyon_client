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
const notifications_service_1 = require("../notifications/notifications.service");
let StudyPlansService = class StudyPlansService {
    prisma;
    notificationsService;
    constructor(prisma, notificationsService) {
        this.prisma = prisma;
        this.notificationsService = notificationsService;
    }
    serializePlan(plan) {
        return {
            ...plan,
            planDate: plan.planDate.toISOString().slice(0, 10),
            priority: plan.priority.toLowerCase(),
            status: plan.status === 'PLANNED'
                ? 'pending'
                : plan.status === 'IN_PROGRESS'
                    ? 'in_progress'
                    : plan.status.toLowerCase(),
        };
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
            .then((data) => ({
            success: true,
            data: data.map((item) => this.serializePlan(item)),
            meta: {},
        }));
    }
    async get(studentId, planId) {
        const plan = await this.prisma.studyPlan.findFirst({
            where: { id: planId, studentId },
        });
        if (!plan) {
            throw new common_1.NotFoundException('계획을 찾을 수 없습니다.');
        }
        return { success: true, data: this.serializePlan(plan), meta: {} };
    }
    async create(studentId, dto) {
        const data = await this.prisma.studyPlan
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
            .then((item) => this.serializePlan(item));
        await this.notifyStudent(studentId, '새 계획이 추가되었어요', `${dto.subjectName} 계획 "${dto.title}"이(가) 오늘 일정에 추가되었습니다.`);
        return { success: true, data, meta: {} };
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
        return { success: true, data: this.serializePlan(plan), meta: {} };
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
        await this.notifyStudent(studentId, '계획 완료', `${plan.title} 계획을 완료했어요.`);
        return { success: true, data: this.serializePlan(plan), meta: {} };
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
exports.StudyPlansService = StudyPlansService;
exports.StudyPlansService = StudyPlansService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        notifications_service_1.NotificationsService])
], StudyPlansService);
//# sourceMappingURL=study-plans.service.js.map