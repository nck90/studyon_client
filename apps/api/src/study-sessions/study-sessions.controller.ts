import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { StartStudySessionDto } from './dto/start-study-session.dto';
import { StudySessionsService } from './study-sessions.service';

@ApiTags('study-sessions')
@ApiBearerAuth()
@Roles(UserRole.STUDENT)
@Controller({ path: 'student/study-sessions', version: '1' })
export class StudySessionsController {
  constructor(private readonly studySessionsService: StudySessionsService) {}

  @Get('active')
  active(@CurrentUser() user: JwtPayload) {
    return this.studySessionsService.active(user.studentId!);
  }

  @Get()
  list(
    @CurrentUser() user: JwtPayload,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.studySessionsService.list(user.studentId!, startDate, endDate);
  }

  @Post('start')
  start(@CurrentUser() user: JwtPayload, @Body() dto: StartStudySessionDto) {
    return this.studySessionsService.start(user.studentId!, dto.linkedPlanId);
  }

  @Post(':sessionId/pause')
  pause(
    @CurrentUser() user: JwtPayload,
    @Param('sessionId') sessionId: string,
  ) {
    return this.studySessionsService.pause(user.studentId!, sessionId);
  }

  @Post(':sessionId/resume')
  resume(
    @CurrentUser() user: JwtPayload,
    @Param('sessionId') sessionId: string,
  ) {
    return this.studySessionsService.resume(user.studentId!, sessionId);
  }

  @Post(':sessionId/end')
  end(@CurrentUser() user: JwtPayload, @Param('sessionId') sessionId: string) {
    return this.studySessionsService.end(user.studentId!, sessionId);
  }
}
