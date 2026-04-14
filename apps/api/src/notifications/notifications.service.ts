import { Injectable, NotFoundException } from '@nestjs/common';
import {
  NotificationChannel,
  NotificationStatus,
  NotificationTargetScope,
  NotificationType,
} from '@prisma/client';
import { EventsService } from '@/events/events.service';
import { PrismaService } from '@/database/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly events: EventsService,
  ) {}

  async studentNotifications(userId: string) {
    const items = await this.prisma.notificationReceipt.findMany({
      where: { userId },
      include: { notification: true },
      orderBy: { createdAt: 'desc' },
    });
    return { success: true, data: items, meta: {} };
  }

  async readNotification(userId: string, notificationId: string) {
    const receipt = await this.prisma.notificationReceipt.findFirst({
      where: { userId, notificationId },
    });
    if (!receipt) {
      throw new NotFoundException('알림을 찾을 수 없습니다.');
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

  getAdmin(notificationId: string) {
    return this.prisma.notification
      .findUnique({
        where: { id: notificationId },
        include: { receipts: true },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  async createAdmin(input: {
    actorUserId: string;
    notificationType?: NotificationType;
    channel?: NotificationChannel;
    title: string;
    body: string;
    targetScope?: NotificationTargetScope;
    scheduledAt?: string;
  }) {
    const notification = await this.prisma.notification.create({
      data: {
        notificationType: input.notificationType ?? NotificationType.NOTICE,
        channel: input.channel ?? NotificationChannel.IN_APP,
        title: input.title,
        body: input.body,
        targetScope: input.targetScope ?? NotificationTargetScope.ALL,
        createdById: input.actorUserId,
        scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
        status: input.scheduledAt
          ? NotificationStatus.SCHEDULED
          : NotificationStatus.DRAFT,
      },
    });
    this.events.emit({
      channel: 'notification',
      event: 'notification.created',
      payload: notification,
    });

    return { success: true, data: notification, meta: {} };
  }

  async send(notificationId: string) {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });
    if (!notification) {
      throw new NotFoundException('알림을 찾을 수 없습니다.');
    }

    const users = await this.prisma.user.findMany({
      where:
        notification.targetScope === NotificationTargetScope.ADMIN
          ? { role: { in: ['ADMIN', 'DIRECTOR'] } }
          : notification.targetScope === NotificationTargetScope.STUDENT
            ? { role: 'STUDENT' }
            : undefined,
      take: 500,
    });

    const existingReceipts = await this.prisma.notificationReceipt.findMany({
      where: { notificationId },
      select: { userId: true },
    });
    const existingUserIds = new Set(
      existingReceipts.map((item) => item.userId),
    );
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
      data: { status: NotificationStatus.SENT, sentAt: new Date() },
    });
    this.events.emit({
      channel: 'notification',
      event: 'notification.sent',
      payload: { notificationId, targetUserCount: targetUserIds.length },
    });
    return { success: true, data: updated, meta: {} };
  }

  async sendDirectToUsers(input: {
    userIds: string[];
    notificationType: NotificationType;
    channel: NotificationChannel;
    title: string;
    body: string;
  }) {
    if (input.userIds.length === 0) {
      return { success: true, data: { sent: 0 }, meta: {} };
    }

    const notification = await this.prisma.notification.create({
      data: {
        notificationType: input.notificationType,
        channel: input.channel,
        title: input.title,
        body: input.body,
        targetScope: NotificationTargetScope.STUDENT,
        status: NotificationStatus.SENT,
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
}
