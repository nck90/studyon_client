import { Module } from '@nestjs/common';
import { SettingsModule } from '@/settings/settings.module';
import { NotificationsController } from './notifications.controller';
import { NotificationsAutomationService } from './notifications.automation.service';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [SettingsModule],
  controllers: [NotificationsController],
  providers: [NotificationsService, NotificationsAutomationService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
