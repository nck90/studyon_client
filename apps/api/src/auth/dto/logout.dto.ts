import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUUID } from 'class-validator';

export class LogoutDto {
  @ApiProperty()
  @IsUUID()
  sessionId!: string;

  @ApiProperty()
  @IsString()
  refreshToken!: string;
}
