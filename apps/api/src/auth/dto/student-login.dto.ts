import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class StudentLoginDto {
  @ApiProperty()
  @IsString()
  loginId!: string;

  @ApiProperty()
  @IsString()
  password!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  deviceCode?: string;
}
