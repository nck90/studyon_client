import { PrismaService } from "../database/prisma.service";
import { SettingsService } from "../settings/settings.service";
import { NotificationsService } from './notifications.service';
export declare class NotificationsAutomationService {
    private readonly prisma;
    private readonly settingsService;
    private readonly notificationsService;
    constructor(prisma: PrismaService, settingsService: SettingsService, notificationsService: NotificationsService);
    run(): Promise<void>;
    private processScheduledNotifications;
    private processAbsenceAlerts;
    private processBreakAlerts;
    private processGoalShortfallAlerts;
    private sendAutomatedStudentNotification;
    private hasPassedTime;
}
