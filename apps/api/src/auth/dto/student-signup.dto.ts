import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, Length } from 'class-validator';

export class StudentSignupDto {
  @ApiProperty()
  @IsString()
  @Length(1, 50)
  studentNo!: string;

  @ApiProperty()
  @IsString()
  @Length(1, 100)
  name!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @Length(0, 30)
  phone?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  deviceCode?: string;
}
