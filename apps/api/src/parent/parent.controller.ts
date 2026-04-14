import { Body, Controller, Get, Headers, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Public } from '@/common/decorators/public.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { ParentService } from './parent.service';

@ApiTags('parent')
@Controller({ version: '1' })
export class ParentController {
  constructor(private readonly parentService: ParentService) {}

  @ApiBearerAuth()
  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/parent-access/issue')
  issue(
    @CurrentUser() user: JwtPayload,
    @Body('studentId') studentId: string,
    @Body('expiresInDays') expiresInDays?: number,
  ) {
    return this.parentService.issueAccessToken(
      user.sub,
      studentId,
      expiresInDays,
    );
  }

  @Public()
  @Get('parent/student/overview')
  overview(@Headers('authorization') authorization?: string) {
    return this.parentService.getOverview(authorization);
  }

  @Public()
  @Get('parent/student/attendance')
  attendance(
    @Headers('authorization') authorization?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.parentService.getAttendance(authorization, startDate, endDate);
  }

  @Public()
  @Get('parent/student/study-report')
  studyReport(
    @Headers('authorization') authorization?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.parentService.getStudyReport(authorization, startDate, endDate);
  }
}
