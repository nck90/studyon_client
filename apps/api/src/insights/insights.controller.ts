import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { InsightsService } from './insights.service';

@ApiTags('insights')
@ApiBearerAuth()
@Controller({ version: '1' })
export class InsightsController {
  constructor(private readonly insightsService: InsightsService) {}

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/insights/students/risks')
  risks(@Query('classId') classId?: string) {
    return this.insightsService.listRiskStudents(classId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/insights/students/:studentId')
  studentInsight(@Param('studentId') studentId: string) {
    return this.insightsService.studentInsight(studentId);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/insights/recommendation')
  myRecommendation(@CurrentUser() user: JwtPayload) {
    return this.insightsService.studentRecommendation(user.studentId!);
  }
}
