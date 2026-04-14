import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsUUID } from 'class-validator';

export class StartStudySessionDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  linkedPlanId?: string;
}
