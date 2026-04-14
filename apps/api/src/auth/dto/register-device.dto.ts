import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DeviceType } from '@prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';

export class RegisterDeviceDto {
  @ApiProperty()
  @IsString()
  deviceCode!: string;

  @ApiProperty({ enum: DeviceType })
  @IsEnum(DeviceType)
  deviceType!: DeviceType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  seatId?: string;
}
