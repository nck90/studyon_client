import { Module } from '@nestjs/common';
import { MetricsModule } from '@/metrics/metrics.module';
import { RankingsController } from './rankings.controller';
import { RankingsService } from './rankings.service';

@Module({
  imports: [MetricsModule],
  controllers: [RankingsController],
  providers: [RankingsService],
  exports: [RankingsService],
})
export class RankingsModule {}
