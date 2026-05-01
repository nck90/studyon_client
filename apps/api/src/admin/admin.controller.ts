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
import { UserRole } from '@prisma/client';
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
