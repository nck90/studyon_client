import { NotificationChannel, NotificationTargetScope, NotificationType } from '@prisma/client';
export declare class CreateNotificationDto {
    notificationType: NotificationType;
    channel: NotificationChannel;
    title: string;
    body: string;
    targetScope?: NotificationTargetScope;
    scheduledAt?: string;
}
