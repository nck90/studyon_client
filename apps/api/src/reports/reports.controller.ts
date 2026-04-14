import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { ReportsService } from './reports.service';

@ApiTags('reports')
@ApiBearerAuth()
@Roles(UserRole.STUDENT)
@Controller({ path: 'student/reports', version: '1' })
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('daily')
  daily(@CurrentUser() user: JwtPayload, @Query('date') date?: string) {
    return this.reportsService.daily(user.studentId!, date);
  }

  @Get('weekly')
  weekly(
    @CurrentUser() user: JwtPayload,
    @Query('weekStartDate') weekStartDate?: string,
  ) {
    return this.reportsService.weekly(user.studentId!, weekStartDate);
  }

  @Get('monthly')
  monthly(@CurrentUser() user: JwtPayload, @Query('month') month?: string) {
    return this.reportsService.monthly(user.studentId!, month);
  }
}
