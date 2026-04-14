import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { StudyPlanPriority } from '@prisma/client';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateStudyPlanDto {
  @ApiProperty()
  @IsDateString()
  planDate!: string;

  @ApiProperty()
  @IsString()
  subjectName!: string;

  @ApiProperty()
  @IsString()
  title!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty()
  @IsInt()
  @Min(0)
  targetMinutes!: number;

  @ApiProperty({ enum: StudyPlanPriority })
  @IsEnum(StudyPlanPriority)
  priority!: StudyPlanPriority;
}
