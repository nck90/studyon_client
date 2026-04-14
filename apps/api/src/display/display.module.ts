import { Module } from '@nestjs/common';
import { DisplayController } from './display.controller';
import { DisplayService } from './display.service';
import { RankingsModule } from '@/rankings/rankings.module';
import { SettingsModule } from '@/settings/settings.module';

@Module({
  imports: [RankingsModule, SettingsModule],
  controllers: [DisplayController],
  providers: [DisplayService],
})
export class DisplayModule {}
