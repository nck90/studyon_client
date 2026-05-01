import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { PointsService } from './points.service';

@ApiTags('points')
@ApiBearerAuth()
@Controller({ version: '1' })
export class PointsController {
  constructor(private readonly pointsService: PointsService) {}

  @Roles(UserRole.STUDENT)
  @Get('student/points')
  getBalance(@CurrentUser() user: JwtPayload) {
    return this.pointsService.getBalance(user.studentId!);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/points/history')
  getHistory(
    @CurrentUser() user: JwtPayload,
    @Query('take') take?: string,
    @Query('skip') skip?: string,
  ) {
    return this.pointsService.getHistory(
      user.studentId!,
      take ? parseInt(take) : 50,
      skip ? parseInt(skip) : 0,
    );
  }
}
