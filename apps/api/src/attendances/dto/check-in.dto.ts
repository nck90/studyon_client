import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsUUID } from 'class-validator';

export class CheckInDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  seatId?: string;
}
