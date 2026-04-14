import { Module } from '@nestjs/common';
import { StudyLogsController } from './study-logs.controller';
import { StudyLogsService } from './study-logs.service';

@Module({
  controllers: [StudyLogsController],
  providers: [StudyLogsService],
  exports: [StudyLogsService],
})
export class StudyLogsModule {}
