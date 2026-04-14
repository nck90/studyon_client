import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class AutoLoginDto {
  @ApiProperty()
  @IsString()
  deviceCode!: string;
}
