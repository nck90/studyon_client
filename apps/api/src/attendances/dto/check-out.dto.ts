import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional } from 'class-validator';

export class CheckOutDto {
  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  forceCloseStudySession?: boolean = true;
}
