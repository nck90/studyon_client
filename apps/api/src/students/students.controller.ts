import { Body, Controller, Get, Param, Patch, Post, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AppEventType, UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { StudentsService } from './students.service';

@ApiTags('student')
@ApiBearerAuth()
@Roles(UserRole.STUDENT)
@Controller({ path: 'student', version: '1' })
export class StudentsController {
  constructor(private readonly studentsService: StudentsService) {}

  @Get('home')
  home(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getStudentHome(user.studentId!);
  }

  @Get('profile')
  profile(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getProfile(user.studentId!);
  }

  @Get('badges')
  badges(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getBadges(user.studentId!);
  }

  @Get('preferences')
  preferences(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getPreferences(user.studentId!);
  }

  @Get('focus-policy')
  focusPolicy() {
    return this.studentsService.getFocusPolicy();
  }

  @Patch('preferences')
  updatePreferences(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      notificationEnabled?: boolean;
      targetUniversityName?: string | null;
      targetUniversityMediaId?: string | null;
      homeBackgroundMediaId?: string | null;
      checkInBackgroundMediaId?: string | null;
      themePreset?: string | null;
      focusModeEnabled?: boolean;
      tvGoalConsent?: boolean;
    },
  ) {
    return this.studentsService.updatePreferences(user.studentId!, body);
  }

  @Post('focus-events')
  focusEvent(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      sessionId?: string | null;
      studySessionId?: string | null;
      eventType?: string;
      occurredAt?: string;
      durationSeconds?: number | null;
    },
  ) {
    return this.studentsService.recordFocusEvent(user.studentId!, body);
  }

  @Get('motivation-dashboard')
  motivationDashboard(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getMotivationDashboard(user.studentId!);
  }

  @Get('goal-roadmap')
  goalRoadmap(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getGoalRoadmap(user.studentId!);
  }

  @Put('goal-roadmap')
  saveGoalRoadmap(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      targetName?: string;
      targetDate?: string;
      reminderEnabled?: boolean;
      reminderTime?: string;
    },
  ) {
    return this.studentsService.saveGoalRoadmap(user.studentId!, body);
  }

  @Post('goal-roadmap/generate')
  generateGoalRoadmap(@CurrentUser() user: JwtPayload) {
    return this.studentsService.generateGoalRoadmap(user.studentId!);
  }

  @Post('goal-roadmap/missions/:missionId/accept')
  acceptRoadmapMission(
    @CurrentUser() user: JwtPayload,
    @Param('missionId') missionId: string,
  ) {
    return this.studentsService.acceptRoadmapMission(
      user.studentId!,
      missionId,
    );
  }

  @Get('daily-mission/today')
  dailyMissionToday(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getTodayDailyMission(user.studentId!);
  }

  @Get('rpg/dashboard')
  rpgDashboard(@CurrentUser() user: JwtPayload) {
    return this.studentsService.getRpgDashboard(user.studentId!);
  }

  @Post('daily-mission/generate')
  generateDailyMission(@CurrentUser() user: JwtPayload) {
    return this.studentsService.generateTodayDailyMission(user.studentId!);
  }

  @Post('daily-mission/:missionId/complete')
  completeDailyMission(
    @CurrentUser() user: JwtPayload,
    @Param('missionId') missionId: string,
    @Body() body: { completionMethod?: string },
  ) {
    return this.studentsService.completeDailyMission(
      user.studentId!,
      missionId,
      body.completionMethod,
    );
  }

  @Patch('daily-mission/reminder')
  updateDailyMissionReminder(
    @CurrentUser() user: JwtPayload,
    @Body() body: { reminderEnabled?: boolean; reminderTime?: string },
  ) {
    return this.studentsService.updateDailyMissionReminder(
      user.studentId!,
      body,
    );
  }

  @Post('app-events')
  appEvent(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      eventType?: AppEventType;
      occurredAt?: string;
      payload?: Record<string, unknown>;
    },
  ) {
    return this.studentsService.recordAppEvent(user.studentId!, body);
  }
}
