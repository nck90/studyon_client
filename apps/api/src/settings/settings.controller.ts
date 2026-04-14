import { Body, Controller, Get, Patch } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { SettingsService } from './settings.service';

@ApiTags('settings')
@ApiBearerAuth()
@Roles(UserRole.ADMIN, UserRole.DIRECTOR)
@Controller({ path: 'admin/settings', version: '1' })
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get('attendance-policy')
  getAttendancePolicy() {
    return this.settingsService.getAttendancePolicy();
  }

  @Roles(UserRole.DIRECTOR)
  @Patch('attendance-policy')
  patchAttendancePolicy(
    @CurrentUser() user: JwtPayload,
    @Body() body: Record<string, unknown>,
  ) {
    return this.settingsService.updateAttendancePolicy(body, user.sub);
  }

  @Get('ranking-policy')
  getRankingPolicy() {
    return this.settingsService.getRankingPolicy();
  }

  @Get('tv-display')
  getTvDisplay() {
    return this.settingsService.getTvDisplay();
  }

  @Patch('tv-display')
  patchTvDisplay(
    @CurrentUser() user: JwtPayload,
    @Body() body: Record<string, unknown>,
  ) {
    return this.settingsService.updateTvDisplay(body, user.sub);
  }
}
