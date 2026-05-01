import { Module } from '@nestjs/common';
import { NotificationsModule } from '@/notifications/notifications.module';
import { PointsModule } from '@/points/points.module';
import { StudySessionsController } from './study-sessions.controller';
import { StudySessionsService } from './study-sessions.service';

@Module({
  imports: [NotificationsModule, PointsModule],
  controllers: [StudySessionsController],
  providers: [StudySessionsService],
  exports: [StudySessionsService],
})
export class StudySessionsModule {}
