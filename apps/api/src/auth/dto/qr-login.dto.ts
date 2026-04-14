import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class QrLoginDto {
  @ApiProperty()
  @IsString()
  qrToken!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  deviceCode?: string;
}
