import { Body, Controller, Get, Patch } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
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

  @Patch('preferences')
  updatePreferences(
    @CurrentUser() user: JwtPayload,
    @Body() body: { notificationEnabled?: boolean },
  ) {
    return this.studentsService.updatePreferences(user.studentId!, body);
  }
}
