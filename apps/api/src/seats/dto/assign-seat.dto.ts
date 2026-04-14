import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsUUID } from 'class-validator';
import { SeatAssignmentType } from '@prisma/client';

export class AssignSeatDto {
  @ApiProperty()
  @IsUUID()
  studentId!: string;

  @ApiProperty({ enum: SeatAssignmentType })
  @IsEnum(SeatAssignmentType)
  assignmentType!: SeatAssignmentType;
}
