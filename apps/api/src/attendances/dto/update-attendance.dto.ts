import { ApiPropertyOptional } from '@nestjs/swagger';
import { AttendanceFlag, AttendanceStatus } from '@prisma/client';
import { IsDateString, IsEnum, IsOptional, IsString } from 'class-validator';

export class UpdateAttendanceDto {
  @ApiPropertyOptional({ enum: AttendanceStatus })
  @IsOptional()
  @IsEnum(AttendanceStatus)
  attendanceStatus?: AttendanceStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  checkInAt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  checkOutAt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  seatId?: string;

  @ApiPropertyOptional({ enum: AttendanceFlag })
  @IsOptional()
  @IsEnum(AttendanceFlag)
  lateStatus?: AttendanceFlag;

  @ApiPropertyOptional({ enum: AttendanceFlag })
  @IsOptional()
  @IsEnum(AttendanceFlag)
  earlyLeaveStatus?: AttendanceFlag;
}
