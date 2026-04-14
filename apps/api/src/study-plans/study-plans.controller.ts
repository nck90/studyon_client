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
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CreateStudyPlanDto } from './dto/create-study-plan.dto';
import { UpdateStudyPlanDto } from './dto/update-study-plan.dto';
import { StudyPlansService } from './study-plans.service';

@ApiTags('study-plans')
@ApiBearerAuth()
@Roles(UserRole.STUDENT)
@Controller({ path: 'student/study-plans', version: '1' })
export class StudyPlansController {
  constructor(private readonly studyPlansService: StudyPlansService) {}

  @Get()
  list(@CurrentUser() user: JwtPayload, @Query('date') date?: string) {
    return this.studyPlansService.list(user.studentId!, date);
  }

  @Get(':planId')
  get(@CurrentUser() user: JwtPayload, @Param('planId') planId: string) {
    return this.studyPlansService.get(user.studentId!, planId);
  }

  @Post()
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateStudyPlanDto) {
    return this.studyPlansService.create(user.studentId!, dto);
  }

  @Patch(':planId')
  update(
    @CurrentUser() user: JwtPayload,
    @Param('planId') planId: string,
    @Body() dto: UpdateStudyPlanDto,
  ) {
    return this.studyPlansService.update(user.studentId!, planId, dto);
  }

  @Delete(':planId')
  remove(@CurrentUser() user: JwtPayload, @Param('planId') planId: string) {
    return this.studyPlansService.remove(user.studentId!, planId);
  }

  @Post(':planId/complete')
  complete(@CurrentUser() user: JwtPayload, @Param('planId') planId: string) {
    return this.studyPlansService.complete(user.studentId!, planId);
  }
}
