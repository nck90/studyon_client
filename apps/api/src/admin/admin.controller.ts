import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import {
  BadgeRuleMetric,
  ConsultationContactType,
  ConsultationDirection,
  FocusPolicyMode,
  GuardianRelation,
  ParentFollowUpStatus,
  UserRole,
} from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { AdminService } from './admin.service';

function optionalString(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

@ApiTags('admin')
@ApiBearerAuth()
@Controller({ version: '1' })
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/dashboard')
  dashboard(
    @Query('date') date?: string,
    @Query('classId') classId?: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.adminService.dashboard(date, classId, groupId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/students')
  students(
    @Query('keyword') keyword?: string,
    @Query('gradeId') gradeId?: string,
    @Query('classId') classId?: string,
    @Query('groupId') groupId?: string,
    @Query('status') status?: string,
  ) {
    return this.adminService.listStudents({
      keyword,
      gradeId,
      classId,
      groupId,
      status,
    });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/students')
  createStudent(
    @CurrentUser() user: JwtPayload,
    @Body() body: Record<string, unknown>,
  ) {
    return this.adminService.createStudent({
      actorUserId: user.sub,
      studentNo: optionalString(body.studentNo) ?? '',
      name: optionalString(body.name) ?? '',
      gradeId: optionalString(body.gradeId),
      classId: optionalString(body.classId),
      groupId: optionalString(body.groupId),
      assignedSeatId: optionalString(body.assignedSeatId),
    });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/students/:studentId')
  student(@Param('studentId') studentId: string) {
    return this.adminService.getStudent(studentId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/students/:studentId')
  patchStudent(
    @CurrentUser() user: JwtPayload,
    @Param('studentId') studentId: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.adminService.updateStudent(studentId, body, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Delete('admin/students/:studentId')
  deleteStudent(
    @CurrentUser() user: JwtPayload,
    @Param('studentId') studentId: string,
  ) {
    return this.adminService.deleteStudent(studentId, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/study-overview')
  studyOverview(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('classId') classId?: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.adminService.getStudyOverview(
      startDate,
      endDate,
      classId,
      groupId,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/study-overview/subjects')
  studyOverviewSubjects(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('classId') classId?: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.adminService.getStudyOverviewSubjects(
      startDate,
      endDate,
      classId,
      groupId,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/students/:studentId/study-summary')
  studentStudySummary(@Param('studentId') studentId: string) {
    return this.adminService.studentStudySummary(studentId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/classes/:classId/study-summary')
  classStudySummary(@Param('classId') classId: string) {
    return this.adminService.classStudySummary(classId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/grades')
  grades() {
    return this.adminService.grades();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/grades')
  createGrade(@CurrentUser() user: JwtPayload, @Body('name') name: string) {
    return this.adminService.createGrade(name, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/classes')
  classes() {
    return this.adminService.classes();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/classes')
  createClass(
    @CurrentUser() user: JwtPayload,
    @Body('name') name: string,
    @Body('gradeId') gradeId?: string,
  ) {
    return this.adminService.createClass(name, gradeId, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/groups')
  groups() {
    return this.adminService.groups();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/groups')
  createGroup(
    @CurrentUser() user: JwtPayload,
    @Body('name') name: string,
    @Body('classId') classId?: string,
  ) {
    return this.adminService.createGroup(name, classId, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/audit-logs')
  auditLogs(
    @Query('actionType') actionType?: string,
    @Query('targetType') targetType?: string,
  ) {
    return this.adminService.auditLogs(actionType, targetType);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/badge-rules')
  badgeRules() {
    return this.adminService.getBadgeRules();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/badge-rules')
  updateBadgeRules(
    @Body()
    body: {
      rules?: {
        id?: string;
        badgeId: string;
        metric: BadgeRuleMetric;
        threshold: number;
        windowDays?: number | null;
        isActive?: boolean;
      }[];
    },
  ) {
    return this.adminService.updateBadgeRules(body.rules ?? []);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/focus-policy')
  focusPolicy() {
    return this.adminService.getFocusPolicy();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/focus-policy')
  updateFocusPolicy(
    @Body()
    body: {
      policyName?: string;
      mode?: FocusPolicyMode;
      isEnabled?: boolean;
      blockedPackages?: string[];
      allowedPackages?: string[];
      graceSeconds?: number;
      opsQueueThreshold?: number;
      parentReportThreshold?: number;
    },
  ) {
    return this.adminService.updateFocusPolicy(body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/focus/overview')
  focusOverview(@Query('date') date?: string) {
    return this.adminService.focusOverview(date);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/focus/students')
  focusStudents(
    @Query('date') date?: string,
    @Query('classId') classId?: string,
    @Query('status') status?: string,
  ) {
    return this.adminService.focusStudents({ date, classId, status });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/focus/events')
  focusEvents(
    @Query('date') date?: string,
    @Query('studentId') studentId?: string,
  ) {
    return this.adminService.focusEvents({ date, studentId });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/retention/overview')
  retentionOverview() {
    return this.adminService.retentionOverview();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/ops/overview')
  opsOverview(@Query('date') date?: string) {
    return this.adminService.opsOverview(date);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/ops/tasks/generate')
  generateOpsTasks() {
    return this.adminService.generateOpsTasks();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/ops/tasks')
  opsTasks(
    @Query('date') date?: string,
    @Query('status') status?: string,
    @Query('reasonType') reasonType?: string,
    @Query('severity') severity?: string,
  ) {
    return this.adminService.opsTasks({ date, status, reasonType, severity });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/ops/tasks/:taskId/student-message')
  sendOpsStudentMessage(
    @CurrentUser() user: JwtPayload,
    @Param('taskId') taskId: string,
    @Body() body: { message?: string },
  ) {
    return this.adminService.sendOpsStudentMessage(
      taskId,
      user.sub,
      body.message,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/ops/tasks/:taskId/parent-report')
  createOpsParentReport(
    @CurrentUser() user: JwtPayload,
    @Param('taskId') taskId: string,
    @Body() body: { message?: string },
  ) {
    return this.adminService.createOpsParentReport(
      taskId,
      user.sub,
      body.message,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/ops/tasks/:taskId/resolve')
  resolveOpsTask(
    @CurrentUser() user: JwtPayload,
    @Param('taskId') taskId: string,
  ) {
    return this.adminService.resolveOpsTask(taskId, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/ops/tasks/:taskId/dismiss')
  dismissOpsTask(
    @CurrentUser() user: JwtPayload,
    @Param('taskId') taskId: string,
  ) {
    return this.adminService.dismissOpsTask(taskId, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/parents/overview')
  parentCrmOverview() {
    return this.adminService.parentCrmOverview();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/parents/guardians')
  parentGuardians(
    @Query('studentId') studentId?: string,
    @Query('keyword') keyword?: string,
  ) {
    return this.adminService.parentGuardians({ studentId, keyword });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/parents/guardians')
  createParentGuardian(
    @Body()
    body: {
      studentId?: string;
      name?: string;
      relation?: GuardianRelation;
      phone?: string | null;
      email?: string | null;
      isPrimary?: boolean;
      memo?: string | null;
    },
  ) {
    return this.adminService.createParentGuardian(body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/parents/guardians/:guardianId')
  updateParentGuardian(
    @Param('guardianId') guardianId: string,
    @Body()
    body: {
      name?: string;
      relation?: GuardianRelation;
      phone?: string | null;
      email?: string | null;
      isPrimary?: boolean;
      memo?: string | null;
    },
  ) {
    return this.adminService.updateParentGuardian(guardianId, body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/parents/consultations')
  parentConsultations(
    @Query('studentId') studentId?: string,
    @Query('guardianId') guardianId?: string,
  ) {
    return this.adminService.parentConsultations({ studentId, guardianId });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/parents/consultations')
  createParentConsultation(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      studentId?: string;
      guardianId?: string | null;
      contactType?: ConsultationContactType;
      direction?: ConsultationDirection;
      occurredAt?: string;
      summary?: string;
      detail?: string | null;
      promisedAction?: string | null;
      nextFollowUpAt?: string | null;
    },
  ) {
    return this.adminService.createParentConsultation(user.sub, body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/parents/follow-ups')
  parentFollowUps(
    @Query('status') status?: ParentFollowUpStatus,
    @Query('studentId') studentId?: string,
  ) {
    return this.adminService.parentFollowUps({ status, studentId });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/parents/follow-ups')
  createParentFollowUp(
    @Body()
    body: {
      studentId?: string;
      guardianId?: string | null;
      consultationId?: string | null;
      sourceOpsTaskId?: string | null;
      title?: string;
      dueAt?: string;
      assignedToId?: string | null;
    },
  ) {
    return this.adminService.createParentFollowUp(body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/parents/follow-ups/:followUpId')
  updateParentFollowUp(
    @Param('followUpId') followUpId: string,
    @Body()
    body: { status?: ParentFollowUpStatus; dueAt?: string; title?: string },
  ) {
    return this.adminService.updateParentFollowUp(followUpId, body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/parents/consultations/:consultationId/share-report')
  createParentConsultationReport(
    @Param('consultationId') consultationId: string,
    @Body() body: { message?: string; expiresInDays?: number },
  ) {
    return this.adminService.createParentConsultationReport(
      consultationId,
      body.message,
      body.expiresInDays,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/ops/tasks/:taskId/parent-follow-up')
  createOpsParentFollowUp(
    @Param('taskId') taskId: string,
    @Body()
    body: { title?: string; dueAt?: string; guardianId?: string | null },
  ) {
    return this.adminService.createOpsParentFollowUp(taskId, body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/retention/goals')
  retentionGoals() {
    return this.adminService.retentionGoals();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/retention/interventions')
  retentionInterventions() {
    return this.adminService.retentionInterventions();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/retention/interventions/generate')
  generateRetentionInterventions() {
    return this.adminService.generateRetentionInterventions();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/retention/interventions/:interventionId/message')
  messageRetentionIntervention(
    @CurrentUser() user: JwtPayload,
    @Param('interventionId') interventionId: string,
    @Body() body: { message?: string },
  ) {
    return this.adminService.messageRetentionIntervention(
      interventionId,
      user.sub,
      body.message,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/retention/interventions/:interventionId/recommend-plan')
  recommendRetentionPlan(
    @CurrentUser() user: JwtPayload,
    @Param('interventionId') interventionId: string,
  ) {
    return this.adminService.recommendRetentionPlan(interventionId, user.sub);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/retention/mission-templates')
  retentionMissionTemplates() {
    return this.adminService.retentionMissionTemplates();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/retention/mission-templates')
  createRetentionMissionTemplate(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      gradeId?: string | null;
      classId?: string | null;
      title?: string;
      subjectName?: string;
      targetMinutes?: number;
      isActive?: boolean;
      sortOrder?: number;
    },
  ) {
    return this.adminService.createRetentionMissionTemplate(user.sub, body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/retention/mission-templates/:templateId')
  updateRetentionMissionTemplate(
    @Param('templateId') templateId: string,
    @Body()
    body: {
      gradeId?: string | null;
      classId?: string | null;
      title?: string;
      subjectName?: string;
      targetMinutes?: number;
      isActive?: boolean;
      sortOrder?: number;
    },
  ) {
    return this.adminService.updateRetentionMissionTemplate(templateId, body);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/retention/daily-missions/overview')
  retentionDailyMissionOverview() {
    return this.adminService.retentionDailyMissionOverview();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/retention/goals/:studentId/review')
  reviewRetentionGoal(
    @CurrentUser() user: JwtPayload,
    @Param('studentId') studentId: string,
    @Body()
    body: {
      status?: 'APPROVED' | 'REJECTED' | 'PENDING';
      memo?: string;
    },
  ) {
    return this.adminService.reviewRetentionGoal(
      studentId,
      body.status ?? 'PENDING',
      user.sub,
      body.memo,
    );
  }

  @Roles(UserRole.DIRECTOR)
  @Get('director/overview')
  directorOverview(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.adminService.directorOverview(startDate, endDate);
  }

  @Roles(UserRole.DIRECTOR)
  @Get('director/reports/operations')
  operationsReport(
    @Query('periodType') periodType = 'monthly',
    @Query('periodKey') periodKey?: string,
  ) {
    return this.adminService.operationsReport(periodType, periodKey);
  }

  @Roles(UserRole.DIRECTOR)
  @Get('director/analytics/performance')
  performanceAnalytics(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('classId') classId?: string,
  ) {
    return this.adminService.performanceAnalytics(startDate, endDate, classId);
  }
}
