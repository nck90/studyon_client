import { Module } from '@nestjs/common';
import { PointsModule } from '@/points/points.module';
import { StudyLogsController } from './study-logs.controller';
import { StudyLogsService } from './study-logs.service';

@Module({
  imports: [PointsModule],
  controllers: [StudyLogsController],
  providers: [StudyLogsService],
  exports: [StudyLogsService],
})
export class StudyLogsModule {}
