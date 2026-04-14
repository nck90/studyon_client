import { NotificationChannel, NotificationTargetScope, NotificationType } from '@prisma/client';
import { EventsService } from "../events/events.service";
import { PrismaService } from "../database/prisma.service";
export declare class NotificationsService {
    private readonly prisma;
    private readonly events;
    constructor(prisma: PrismaService, events: EventsService);
    studentNotifications(userId: string): Promise<{
        success: boolean;
        data: ({
            notification: {
                id: string;
                createdAt: Date;
                status: import("@prisma/client").$Enums.NotificationStatus;
                updatedAt: Date;
                createdById: string | null;
                title: string;
                notificationType: import("@prisma/client").$Enums.NotificationType;
                channel: import("@prisma/client").$Enums.NotificationChannel;
                body: string;
                targetScope: import("@prisma/client").$Enums.NotificationTargetScope;
                scheduledAt: Date | null;
                sentAt: Date | null;
            };
        } & {
            id: string;
            createdAt: Date;
            userId: string;
            notificationId: string;
            deliveryStatus: import("@prisma/client").$Enums.DeliveryStatus;
            deliveredAt: Date | null;
            readAt: Date | null;
        })[];
        meta: {};
    }>;
    readNotification(userId: string, notificationId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            userId: string;
            notificationId: string;
            deliveryStatus: import("@prisma/client").$Enums.DeliveryStatus;
            deliveredAt: Date | null;
            readAt: Date | null;
        };
        meta: {};
    }>;
    listAdmin(): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.NotificationStatus;
            updatedAt: Date;
            createdById: string | null;
            title: string;
            notificationType: import("@prisma/client").$Enums.NotificationType;
            channel: import("@prisma/client").$Enums.NotificationChannel;
            body: string;
            targetScope: import("@prisma/client").$Enums.NotificationTargetScope;
            scheduledAt: Date | null;
            sentAt: Date | null;
        }[];
        meta: {};
    }>;
    getAdmin(notificationId: string): Promise<{
        success: boolean;
        data: ({
            receipts: {
                id: string;
                createdAt: Date;
                userId: string;
                notificationId: string;
                deliveryStatus: import("@prisma/client").$Enums.DeliveryStatus;
                deliveredAt: Date | null;
                readAt: Date | null;
            }[];
        } & {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.NotificationStatus;
            updatedAt: Date;
            createdById: string | null;
            title: string;
            notificationType: import("@prisma/client").$Enums.NotificationType;
            channel: import("@prisma/client").$Enums.NotificationChannel;
            body: string;
            targetScope: import("@prisma/client").$Enums.NotificationTargetScope;
            scheduledAt: Date | null;
            sentAt: Date | null;
        }) | null;
        meta: {};
    }>;
    createAdmin(input: {
        actorUserId: string;
        notificationType?: NotificationType;
        channel?: NotificationChannel;
        title: string;
        body: string;
        targetScope?: NotificationTargetScope;
        scheduledAt?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.NotificationStatus;
            updatedAt: Date;
            createdById: string | null;
            title: string;
            notificationType: import("@prisma/client").$Enums.NotificationType;
            channel: import("@prisma/client").$Enums.NotificationChannel;
            body: string;
            targetScope: import("@prisma/client").$Enums.NotificationTargetScope;
            scheduledAt: Date | null;
            sentAt: Date | null;
        };
        meta: {};
    }>;
    send(notificationId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.NotificationStatus;
            updatedAt: Date;
            createdById: string | null;
            title: string;
            notificationType: import("@prisma/client").$Enums.NotificationType;
            channel: import("@prisma/client").$Enums.NotificationChannel;
            body: string;
            targetScope: import("@prisma/client").$Enums.NotificationTargetScope;
            scheduledAt: Date | null;
            sentAt: Date | null;
        };
        meta: {};
    }>;
    sendDirectToUsers(input: {
        userIds: string[];
        notificationType: NotificationType;
        channel: NotificationChannel;
        title: string;
        body: string;
    }): Promise<{
        success: boolean;
        data: {
            sent: number;
            notificationId?: undefined;
        };
        meta: {};
    } | {
        success: boolean;
        data: {
            notificationId: string;
            sent: number;
        };
        meta: {};
    }>;
}
