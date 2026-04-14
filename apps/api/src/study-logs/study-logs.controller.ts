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
import { CreateStudyLogDto } from './dto/create-study-log.dto';
import { UpdateStudyLogDto } from './dto/update-study-log.dto';
import { StudyLogsService } from './study-logs.service';

@ApiTags('study-logs')
@ApiBearerAuth()
@Roles(UserRole.STUDENT)
@Controller({ path: 'student/study-logs', version: '1' })
export class StudyLogsController {
  constructor(private readonly studyLogsService: StudyLogsService) {}

  @Get()
  list(
    @CurrentUser() user: JwtPayload,
    @Query('date') date?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.studyLogsService.list(
      user.studentId!,
      date,
      startDate,
      endDate,
    );
  }

  @Post()
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateStudyLogDto) {
    return this.studyLogsService.create(user.studentId!, dto);
  }

  @Patch(':logId')
  update(
    @CurrentUser() user: JwtPayload,
    @Param('logId') logId: string,
    @Body() dto: UpdateStudyLogDto,
  ) {
    return this.studyLogsService.update(user.studentId!, logId, dto);
  }

  @Delete(':logId')
  remove(@CurrentUser() user: JwtPayload, @Param('logId') logId: string) {
    return this.studyLogsService.remove(user.studentId!, logId);
  }
}
