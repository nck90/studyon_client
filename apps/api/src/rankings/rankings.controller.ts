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
import {
  Prisma,
  RankingPeriodType,
  RankingType,
  UserRole,
} from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { PrismaService } from '@/database/prisma.service';
import { RankingsService } from './rankings.service';

function optionalString(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

@ApiTags('rankings')
@ApiBearerAuth()
@Controller({ version: '1' })
export class RankingsController {
  constructor(
    private readonly rankingsService: RankingsService,
    private readonly prisma: PrismaService,
  ) {}

  @Roles(UserRole.STUDENT)
  @Get('student/rankings')
  studentRankings(
    @CurrentUser() user: JwtPayload,
    @Query('periodType')
    periodType: RankingPeriodType = RankingPeriodType.DAILY,
    @Query('rankingType') rankingType: RankingType = RankingType.STUDY_TIME,
  ) {
    return this.rankingsService.studentRanking(
      user.studentId!,
      periodType,
      rankingType,
    );
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/rankings')
  adminRankings(
    @Query('periodType')
    periodType: RankingPeriodType = RankingPeriodType.DAILY,
    @Query('rankingType') rankingType: RankingType = RankingType.STUDY_TIME,
  ) {
    return this.rankingsService.adminRanking(periodType, rankingType);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/ranking-policies/active')
  getActivePolicy() {
    return this.prisma.rankingPolicy
      .findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  @Roles(UserRole.DIRECTOR)
  @Post('admin/ranking-policies')
  createPolicy(@Body() body: Record<string, unknown>) {
    return this.prisma.rankingPolicy
      .create({
        data: {
          policyName: optionalString(body.policyName) ?? 'Default Policy',
          studyTimeWeight: Number(body.studyTimeWeight ?? 1),
          studyVolumeWeight: Number(body.studyVolumeWeight ?? 1),
          attendanceWeight: Number(body.attendanceWeight ?? 1),
          tieBreakerRule: body.tieBreakerRule ?? { order: ['score'] },
        },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  @Roles(UserRole.DIRECTOR)
  @Patch('admin/ranking-policies/:policyId')
  patchPolicy(
    @Param('policyId') policyId: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.prisma.rankingPolicy
      .update({
        where: { id: policyId },
        data: {
          policyName: optionalString(body.policyName),
          studyTimeWeight:
            body.studyTimeWeight !== undefined
              ? Number(body.studyTimeWeight)
              : undefined,
          studyVolumeWeight:
            body.studyVolumeWeight !== undefined
              ? Number(body.studyVolumeWeight)
              : undefined,
          attendanceWeight:
            body.attendanceWeight !== undefined
              ? Number(body.attendanceWeight)
              : undefined,
          tieBreakerRule: body.tieBreakerRule as
            | Prisma.InputJsonValue
            | undefined,
        },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }
}
