import { Module } from '@nestjs/common';
import { AttendancesAutomationService } from './attendances.automation.service';
import { AttendancesController } from './attendances.controller';
import { AttendancesService } from './attendances.service';

@Module({
  controllers: [AttendancesController],
  providers: [AttendancesService, AttendancesAutomationService],
  exports: [AttendancesService],
})
export class AttendancesModule {}
