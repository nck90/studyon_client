import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AttendanceStatus, UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CheckInDto } from './dto/check-in.dto';
import { CheckOutDto } from './dto/check-out.dto';
import { UpdateAttendanceDto } from './dto/update-attendance.dto';
import { AttendancesService } from './attendances.service';

@ApiTags('attendances')
@ApiBearerAuth()
@Controller({ version: '1' })
export class AttendancesController {
  constructor(private readonly attendancesService: AttendancesService) {}

  @Roles(UserRole.STUDENT)
  @Get('student/attendances/today')
  getToday(@CurrentUser() user: JwtPayload) {
    return this.attendancesService.getToday(user.studentId!);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/attendances')
  listStudent(
    @CurrentUser() user: JwtPayload,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.attendancesService.listStudentAttendances(
      user.studentId!,
      startDate,
      endDate,
    );
  }

  @Roles(UserRole.STUDENT)
  @Post('student/attendances/check-in')
  checkIn(@CurrentUser() user: JwtPayload, @Body() dto: CheckInDto) {
    return this.attendancesService.checkIn(user.studentId!, dto.seatId);
  }

  @Roles(UserRole.STUDENT)
  @Post('student/attendances/check-out')
  checkOut(@CurrentUser() user: JwtPayload, @Body() dto: CheckOutDto) {
    return this.attendancesService.checkOut(
      user.studentId!,
      dto.forceCloseStudySession,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/attendances')
  listAdmin(
    @Query('date') date?: string,
    @Query('classId') classId?: string,
    @Query('groupId') groupId?: string,
    @Query('attendanceStatus') attendanceStatus?: AttendanceStatus,
  ) {
    return this.attendancesService.listAdmin(
      date,
      classId,
      groupId,
      attendanceStatus,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/attendances/:attendanceId')
  getAdmin(@Param('attendanceId') attendanceId: string) {
    return this.attendancesService.getAdmin(attendanceId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/attendance-stats')
  stats(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('classId') classId?: string,
  ) {
    return this.attendancesService.stats(startDate, endDate, classId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Patch('admin/attendances/:attendanceId')
  patch(
    @CurrentUser() user: JwtPayload,
    @Param('attendanceId') attendanceId: string,
    @Body() dto: UpdateAttendanceDto,
  ) {
    return this.attendancesService.updateAdmin(attendanceId, dto, user.sub);
  }
}
