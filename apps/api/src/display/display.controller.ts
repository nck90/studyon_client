import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { RankingPeriodType, RankingType, UserRole } from '@prisma/client';
import { Public } from '@/common/decorators/public.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { DisplayService } from './display.service';

@ApiTags('display')
@Controller({ path: 'display', version: '1' })
export class DisplayController {
  constructor(private readonly displayService: DisplayService) {}

  @Public()
  @Get('current')
  current() {
    return this.displayService.current();
  }

  @Public()
  @Get('rankings')
  rankings(
    @Query('periodType')
    periodType: RankingPeriodType = RankingPeriodType.DAILY,
    @Query('rankingType') rankingType: RankingType = RankingType.STUDY_TIME,
  ) {
    return this.displayService.rankings(periodType, rankingType);
  }

  @Public()
  @Get('status')
  status() {
    return this.displayService.status();
  }

  @Public()
  @Get('motivation')
  motivation() {
    return this.displayService.motivation();
  }

  @ApiBearerAuth()
  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('control')
  control(@Body('activeScreen') activeScreen: string) {
    return this.displayService.control(activeScreen);
  }
}
