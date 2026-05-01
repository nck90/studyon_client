import { Module } from '@nestjs/common';
import { NotificationsModule } from '@/notifications/notifications.module';
import { StudyPlansController } from './study-plans.controller';
import { StudyPlansService } from './study-plans.service';

@Module({
  imports: [NotificationsModule],
  controllers: [StudyPlansController],
  providers: [StudyPlansService],
  exports: [StudyPlansService],
})
export class StudyPlansModule {}
