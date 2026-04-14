import { Module } from '@nestjs/common';
import { BadgeAutomationService } from './badge-automation.service';

@Module({
  providers: [BadgeAutomationService],
})
export class BadgesModule {}
