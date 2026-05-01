import { Module } from '@nestjs/common';
import { NotificationsModule } from '@/notifications/notifications.module';
import { PointsModule } from '@/points/points.module';
import { AttendancesAutomationService } from './attendances.automation.service';
import { AttendancesController } from './attendances.controller';
import { AttendancesService } from './attendances.service';

@Module({
  imports: [NotificationsModule, PointsModule],
  controllers: [AttendancesController],
  providers: [AttendancesService, AttendancesAutomationService],
  exports: [AttendancesService],
})
export class AttendancesModule {}
