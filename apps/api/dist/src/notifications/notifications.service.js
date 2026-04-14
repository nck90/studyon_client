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
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const events_service_1 = require("../events/events.service");
const prisma_service_1 = require("../database/prisma.service");
let NotificationsService = class NotificationsService {
    prisma;
    events;
    constructor(prisma, events) {
        this.prisma = prisma;
        this.events = events;
    }
    async studentNotifications(userId) {
        const items = await this.prisma.notificationReceipt.findMany({
            where: { userId },
            include: { notification: true },
            orderBy: { createdAt: 'desc' },
        });
        return { success: true, data: items, meta: {} };
    }
    async readNotification(userId, notificationId) {
        const receipt = await this.prisma.notificationReceipt.findFirst({
            where: { userId, notificationId },
        });
        if (!receipt) {
            throw new common_1.NotFoundException('알림을 찾을 수 없습니다.');
        }
        const updated = await this.prisma.notificationReceipt.update({
            where: { id: receipt.id },
            data: { deliveryStatus: 'READ', readAt: new Date() },
        });
        return { success: true, data: updated, meta: {} };
    }
    listAdmin() {
        return this.prisma.notification
            .findMany({
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    getAdmin(notificationId) {
        return this.prisma.notification
            .findUnique({
            where: { id: notificationId },
            include: { receipts: true },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async createAdmin(input) {
        const notification = await this.prisma.notification.create({
            data: {
                notificationType: input.notificationType ?? client_1.NotificationType.NOTICE,
                channel: input.channel ?? client_1.NotificationChannel.IN_APP,
                title: input.title,
                body: input.body,
                targetScope: input.targetScope ?? client_1.NotificationTargetScope.ALL,
                createdById: input.actorUserId,
                scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
                status: input.scheduledAt
                    ? client_1.NotificationStatus.SCHEDULED
                    : client_1.NotificationStatus.DRAFT,
            },
        });
        this.events.emit({
            channel: 'notification',
            event: 'notification.created',
            payload: notification,
        });
        return { success: true, data: notification, meta: {} };
    }
    async send(notificationId) {
        const notification = await this.prisma.notification.findUnique({
            where: { id: notificationId },
        });
        if (!notification) {
            throw new common_1.NotFoundException('알림을 찾을 수 없습니다.');
        }
        const users = await this.prisma.user.findMany({
            where: notification.targetScope === client_1.NotificationTargetScope.ADMIN
                ? { role: { in: ['ADMIN', 'DIRECTOR'] } }
                : notification.targetScope === client_1.NotificationTargetScope.STUDENT
                    ? { role: 'STUDENT' }
                    : undefined,
            take: 500,
        });
        const existingReceipts = await this.prisma.notificationReceipt.findMany({
            where: { notificationId },
            select: { userId: true },
        });
        const existingUserIds = new Set(existingReceipts.map((item) => item.userId));
        const targetUserIds = users
            .map((user) => user.id)
            .filter((userId) => !existingUserIds.has(userId));
        if (targetUserIds.length > 0) {
            await this.prisma.notificationReceipt.createMany({
                data: targetUserIds.map((userId) => ({
                    notificationId,
                    userId,
                    deliveryStatus: 'SENT',
                    deliveredAt: new Date(),
                })),
            });
        }
        const updated = await this.prisma.notification.update({
            where: { id: notificationId },
            data: { status: client_1.NotificationStatus.SENT, sentAt: new Date() },
        });
        this.events.emit({
            channel: 'notification',
            event: 'notification.sent',
            payload: { notificationId, targetUserCount: targetUserIds.length },
        });
        return { success: true, data: updated, meta: {} };
    }
    async sendDirectToUsers(input) {
        if (input.userIds.length === 0) {
            return { success: true, data: { sent: 0 }, meta: {} };
        }
        const notification = await this.prisma.notification.create({
            data: {
                notificationType: input.notificationType,
                channel: input.channel,
                title: input.title,
                body: input.body,
                targetScope: client_1.NotificationTargetScope.STUDENT,
                status: client_1.NotificationStatus.SENT,
                sentAt: new Date(),
            },
        });
        await this.prisma.notificationReceipt.createMany({
            data: input.userIds.map((userId) => ({
                notificationId: notification.id,
                userId,
                deliveryStatus: 'SENT',
                deliveredAt: new Date(),
            })),
        });
        input.userIds.forEach((userId) => {
            this.events.emit({
                channel: 'notification',
                event: 'notification.sent',
                payload: { title: input.title, body: input.body },
                userId,
            });
        });
        return {
            success: true,
            data: { notificationId: notification.id, sent: input.userIds.length },
            meta: {},
        };
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        events_service_1.EventsService])
], NotificationsService);
//# sourceMappingURL=notifications.service.js.map