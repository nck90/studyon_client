import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsDateString,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export class CreateStudyLogDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  planId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  studySessionId?: string;

  @ApiProperty()
  @IsDateString()
  logDate!: string;

  @ApiProperty()
  @IsString()
  subjectName!: string;

  @ApiProperty()
  @IsInt()
  @Min(0)
  pagesCompleted!: number;

  @ApiProperty()
  @IsInt()
  @Min(0)
  problemsSolved!: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  @Max(100)
  progressPercent!: number;

  @ApiProperty()
  @IsBoolean()
  isCompleted!: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  memo?: string;
}
