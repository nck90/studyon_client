import { JwtPayload } from "../auth/types/jwt-payload.type";
import { CreateNotificationDto } from './dto/create-notification.dto';
import { NotificationsService } from './notifications.service';
export declare class NotificationsController {
    private readonly notificationsService;
    constructor(notificationsService: NotificationsService);
    studentNotifications(user: JwtPayload): Promise<{
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
    read(user: JwtPayload, notificationId: string): Promise<{
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
    create(user: JwtPayload, body: CreateNotificationDto): Promise<{
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
}
