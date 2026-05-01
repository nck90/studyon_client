import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AttendancesModule } from '@/attendances/attendances.module';
import { AuthAutomationService } from './auth.automation.service';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';

@Module({
  imports: [PassportModule, JwtModule.register({}), AttendancesModule],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, AuthAutomationService],
  exports: [AuthService],
})
export class AuthModule {}
