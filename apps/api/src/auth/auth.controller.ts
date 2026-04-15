import { Body, Controller, Get, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Public } from '@/common/decorators/public.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { AuthService } from './auth.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import { AutoLoginDto } from './dto/auto-login.dto';
import { CreateQrTokenDto } from './dto/create-qr-token.dto';
import { LogoutDto } from './dto/logout.dto';
import { QrLoginDto } from './dto/qr-login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { StudentSignupDto } from './dto/student-signup.dto';
import { StudentLoginDto } from './dto/student-login.dto';
import { JwtPayload } from './types/jwt-payload.type';

@ApiTags('auth')
@Controller({ path: 'auth', version: '1' })
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('student/signup')
  studentSignup(@Body() dto: StudentSignupDto) {
    return this.authService.studentSignup(dto);
  }

  @Public()
  @Post('student/login')
  studentLogin(@Body() dto: StudentLoginDto) {
    return this.authService.studentLogin(dto);
  }

  @Public()
  @Post('student/qr-login')
  studentQrLogin(@Body() dto: QrLoginDto) {
    return this.authService.qrLogin(dto);
  }

  @Public()
  @Post('student/auto-login')
  studentAutoLogin(@Body() dto: AutoLoginDto) {
    return this.authService.autoLogin(dto);
  }

  @Public()
  @Post('admin/login')
  adminLogin(@Body() dto: AdminLoginDto) {
    return this.authService.adminLogin(dto);
  }

  @Public()
  @Post('refresh')
  refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refresh(dto.refreshToken);
  }

  @ApiBearerAuth()
  @Post('logout')
  logout(@Body() dto: LogoutDto) {
    return this.authService.logout(dto.sessionId, dto.refreshToken);
  }

  @ApiBearerAuth()
  @Get('me')
  me(@CurrentUser() user: JwtPayload) {
    return this.authService.me(user);
  }

  @ApiBearerAuth()
  @Roles(UserRole.STUDENT, UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('student/qr-token')
  createQrToken(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateQrTokenDto,
  ) {
    return this.authService.createQrToken(user, dto);
  }

  @ApiBearerAuth()
  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('devices/register')
  registerDevice(@Body() dto: RegisterDeviceDto) {
    return this.authService.registerDevice(dto);
  }
}
