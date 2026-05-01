import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
  AttendanceStatus,
  DeviceStatus,
  DeviceType,
  LoginMethod,
  QrTokenType,
  SessionStatus,
  UserRole,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { dateOnly } from '@/common/utils/date.util';
import { AttendancesService } from '@/attendances/attendances.service';
import { PrismaService } from '@/database/prisma.service';
import { RedisService } from '@/redis/redis.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import { AutoLoginDto } from './dto/auto-login.dto';
import { CreateQrTokenDto } from './dto/create-qr-token.dto';
import { QrLoginDto } from './dto/qr-login.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { StudentLoginDto } from './dto/student-login.dto';
import { AdminSignupDto } from './dto/admin-signup.dto';
import { StudentSignupDto } from './dto/student-signup.dto';
import { JwtPayload } from './types/jwt-payload.type';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly jwtService: JwtService,
    private readonly attendancesService: AttendancesService,
  ) {}

  async studentSignup(dto: StudentSignupDto) {
    const existingLogin = await this.prisma.student.findUnique({
      where: { loginId: dto.loginId },
      select: { id: true },
    });

    if (existingLogin) {
      throw new ConflictException('이미 사용 중인 아이디입니다.');
    }

    const existingStudent = await this.prisma.student.findUnique({
      where: { studentNo: dto.studentNo },
      include: { user: true, class: true, assignedSeat: true },
    });

    const passwordHash = await bcrypt.hash(dto.password, 10);

    if (existingStudent?.user.status === 'ACTIVE') {
      throw new ConflictException('이미 가입된 학번입니다.');
    }

    if (existingStudent) {
      await this.prisma.user.update({
        where: { id: existingStudent.userId },
        data: {
          name: dto.name,
          phone: dto.phone,
          status: 'ACTIVE',
        },
      });

      await this.prisma.student.update({
        where: { id: existingStudent.id },
        data: {
          loginId: dto.loginId,
          passwordHash,
        },
      });

      await this.revokeActiveStudentSessions(existingStudent.id);

      return this.createSessionAndTokens({
        userId: existingStudent.userId,
        role: UserRole.STUDENT,
        name: dto.name,
        studentId: existingStudent.id,
        loginMethod: LoginMethod.STUDENT_ID_PASSWORD,
        deviceCode: dto.deviceCode,
        meta: {
          student: {
            id: existingStudent.id,
            studentNo: existingStudent.studentNo,
            className: existingStudent.class?.name ?? null,
            assignedSeatNo: existingStudent.assignedSeat?.seatNo ?? null,
          },
        },
      });
    }

    const created = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          role: UserRole.STUDENT,
          status: 'ACTIVE',
          name: dto.name,
          phone: dto.phone,
        },
      });

      const student = await tx.student.create({
        data: {
          userId: user.id,
          loginId: dto.loginId,
          passwordHash,
          studentNo: dto.studentNo,
        },
        include: { class: true, assignedSeat: true },
      });

      return { user, student };
    });

    return this.createSessionAndTokens({
      userId: created.user.id,
      role: UserRole.STUDENT,
      name: created.user.name,
      studentId: created.student.id,
      loginMethod: LoginMethod.STUDENT_ID_PASSWORD,
      deviceCode: dto.deviceCode,
      meta: {
        student: {
          id: created.student.id,
          studentNo: created.student.studentNo,
          className: created.student.class?.name ?? null,
          assignedSeatNo: created.student.assignedSeat?.seatNo ?? null,
        },
      },
    });
  }

  async studentLogin(dto: StudentLoginDto) {
    if (!dto.loginId.trim() || !dto.password.trim()) {
      throw new BadRequestException('아이디와 비밀번호를 입력해 주세요.');
    }

    const student = await this.prisma.student.findFirst({
      where: {
        loginId: dto.loginId,
        user: { status: 'ACTIVE' },
      },
      include: { user: true, class: true, assignedSeat: true },
    });

    if (
      !student ||
      !(await bcrypt.compare(dto.password, student.passwordHash))
    ) {
      throw new UnauthorizedException('아이디 또는 비밀번호를 확인해 주세요.');
    }

    await this.revokeActiveStudentSessions(student.id);

    return this.createSessionAndTokens({
      userId: student.userId,
      role: UserRole.STUDENT,
      name: student.user.name,
      studentId: student.id,
      loginMethod: LoginMethod.STUDENT_ID_PASSWORD,
      deviceCode: dto.deviceCode,
      meta: {
        student: {
          id: student.id,
          studentNo: student.studentNo,
          className: student.class?.name ?? null,
          assignedSeatNo: student.assignedSeat?.seatNo ?? null,
        },
      },
    });
  }

  async qrLogin(dto: QrLoginDto) {
    const qrToken = await this.prisma.qrLoginToken.findFirst({
      where: {
        token: dto.qrToken,
        usedAt: null,
        expiresAt: { gt: new Date() },
      },
      include: {
        student: { include: { user: true, class: true, assignedSeat: true } },
      },
    });

    if (!qrToken?.student) {
      throw new UnauthorizedException('QR 토큰이 유효하지 않습니다.');
    }

    await this.prisma.qrLoginToken.update({
      where: { id: qrToken.id },
      data: { usedAt: new Date() },
    });

    await this.revokeActiveStudentSessions(qrToken.student.id);

    if (qrToken.deviceId) {
      await this.prisma.device.update({
        where: { id: qrToken.deviceId },
        data: { lastSeenAt: new Date() },
      });
    }

    return this.createSessionAndTokens({
      userId: qrToken.student.userId,
      role: UserRole.STUDENT,
      name: qrToken.student.user.name,
      studentId: qrToken.student.id,
      loginMethod: LoginMethod.QR,
      deviceCode: dto.deviceCode,
      meta: {
        student: {
          id: qrToken.student.id,
          studentNo: qrToken.student.studentNo,
          className: qrToken.student.class?.name ?? null,
          assignedSeatNo: qrToken.student.assignedSeat?.seatNo ?? null,
        },
      },
    });
  }

  async autoLogin(dto: AutoLoginDto) {
    const device = await this.prisma.device.findFirst({
      where: {
        deviceCode: dto.deviceCode,
        status: DeviceStatus.ACTIVE,
        deviceType: DeviceType.TABLET,
      },
      include: {
        seat: {
          include: {
            currentStudent: {
              include: { user: true, class: true, assignedSeat: true },
            },
            assignedStudents: {
              include: { user: true, class: true, assignedSeat: true },
            },
          },
        },
      },
    });

    const assignedStudent = device?.seat
      ? await this.prisma.student.findFirst({
          where: { assignedSeatId: device.seat.id, enrollmentStatus: 'ACTIVE' },
          include: { user: true, class: true, assignedSeat: true },
          orderBy: { updatedAt: 'desc' },
        })
      : null;
    const student = device?.seat?.currentStudent ?? assignedStudent ?? null;

    if (!device || !student) {
      throw new UnauthorizedException(
        '자동 로그인 가능한 좌석 태블릿 정보가 없습니다.',
      );
    }

    await this.prisma.device.update({
      where: { id: device.id },
      data: { lastSeenAt: new Date() },
    });
    await this.revokeActiveStudentSessions(student.id);

    return this.createSessionAndTokens({
      userId: student.userId,
      role: UserRole.STUDENT,
      name: student.user.name,
      studentId: student.id,
      loginMethod: LoginMethod.AUTO,
      deviceCode: dto.deviceCode,
      meta: {
        student: {
          id: student.id,
          studentNo: student.studentNo,
          className: student.class?.name ?? null,
          assignedSeatNo: student.assignedSeat?.seatNo ?? null,
        },
      },
    });
  }

  async adminSignup(dto: AdminSignupDto) {
    const existing = await this.prisma.adminUser.findUnique({
      where: { email: dto.email },
    });
    if (existing) {
      throw new ConflictException('이미 사용 중인 이메일입니다.');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    const result = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          role: UserRole.ADMIN,
          status: 'ACTIVE',
          name: dto.name,
        },
      });
      const admin = await tx.adminUser.create({
        data: {
          userId: user.id,
          adminType: UserRole.ADMIN,
          email: dto.email,
          passwordHash,
        },
      });
      return { user, admin };
    });

    return this.createSessionAndTokens({
      userId: result.user.id,
      role: UserRole.ADMIN,
      name: result.user.name,
      loginMethod: LoginMethod.ADMIN_PASSWORD,
      meta: {
        user: {
          id: result.user.id,
          role: result.user.role,
          name: result.user.name,
          email: result.admin.email,
        },
      },
    });
  }

  async adminLogin(dto: AdminLoginDto) {
    const admin = await this.prisma.adminUser.findUnique({
      where: { email: dto.email },
      include: { user: true },
    });

    if (!admin || admin.user.status !== 'ACTIVE') {
      throw new UnauthorizedException('관리자 정보를 확인할 수 없습니다.');
    }

    const isMatched = await bcrypt.compare(dto.password, admin.passwordHash);
    if (!isMatched) {
      throw new UnauthorizedException('관리자 정보를 확인할 수 없습니다.');
    }

    return this.createSessionAndTokens({
      userId: admin.userId,
      role: admin.adminType,
      name: admin.user.name,
      loginMethod: LoginMethod.ADMIN_PASSWORD,
      meta: {
        user: {
          id: admin.user.id,
          role: admin.user.role,
          name: admin.user.name,
          email: admin.email,
        },
      },
    });
  }

  async refresh(refreshToken: string) {
    const payload = await this.verifyToken(refreshToken, 'refresh');
    const saved = await this.redis.client.get(
      this.refreshTokenKey(payload.sessionId),
    );

    if (!saved || saved !== refreshToken) {
      throw new UnauthorizedException('세션이 만료되었습니다.');
    }

    const session = await this.prisma.authSession.findUnique({
      where: { id: payload.sessionId },
    });

    if (!session || session.sessionStatus !== SessionStatus.ACTIVE) {
      throw new UnauthorizedException('세션이 비활성화되었습니다.');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
    });
    if (!user) {
      throw new UnauthorizedException();
    }

    return this.issueTokens({
      sub: user.id,
      role: payload.role,
      name: user.name,
      studentId: payload.studentId,
      sessionId: payload.sessionId,
    });
  }

  async logout(sessionId: string, refreshToken: string) {
    const session = await this.prisma.authSession.findUnique({
      where: { id: sessionId },
      select: { studentId: true, sessionStatus: true },
    });

    if (session?.studentId && session.sessionStatus === SessionStatus.ACTIVE) {
      const attendance = await this.prisma.attendance.findUnique({
        where: {
          studentId_attendanceDate: {
            studentId: session.studentId,
            attendanceDate: dateOnly(),
          },
        },
        select: { attendanceStatus: true },
      });

      if (attendance?.attendanceStatus === AttendanceStatus.CHECKED_IN) {
        await this.attendancesService.checkOut(session.studentId, true);
      }
    }

    await this.prisma.authSession.update({
      where: { id: sessionId },
      data: { sessionStatus: SessionStatus.LOGGED_OUT, endedAt: new Date() },
    });

    await this.redis.client.del(this.refreshTokenKey(sessionId));
    await this.redis.client.set(
      this.blacklistTokenKey(refreshToken),
      '1',
      'EX',
      60 * 60 * 24 * 30,
    );

    return {
      success: true,
      data: { sessionId, loggedOut: true },
      meta: {},
    };
  }

  async me(user: JwtPayload) {
    const entity = await this.prisma.user.findUnique({
      where: { id: user.sub },
      include: {
        student: {
          include: {
            class: true,
            group: true,
            assignedSeat: true,
          },
        },
        adminUser: true,
      },
    });

    return { success: true, data: entity, meta: {} };
  }

  async createQrToken(user: JwtPayload, dto: CreateQrTokenDto) {
    const studentId =
      user.role === UserRole.STUDENT ? user.studentId : dto.studentId;
    if (!studentId) {
      throw new UnauthorizedException('학생 정보가 필요합니다.');
    }

    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
    });
    if (!student) {
      throw new UnauthorizedException('학생 정보를 확인할 수 없습니다.');
    }

    const device = dto.deviceCode
      ? await this.prisma.device.findFirst({
          where: { deviceCode: dto.deviceCode, status: DeviceStatus.ACTIVE },
        })
      : null;
    const token = `${student.studentNo}-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
    const record = await this.prisma.qrLoginToken.create({
      data: {
        studentId,
        deviceId: device?.id,
        token,
        tokenType: device ? QrTokenType.SEAT_LOGIN : QrTokenType.STUDENT_LOGIN,
        expiresAt: new Date(Date.now() + 1000 * 60 * 5),
      },
    });

    return { success: true, data: record, meta: {} };
  }

  async registerDevice(dto: RegisterDeviceDto) {
    const record = await this.prisma.device.upsert({
      where: { deviceCode: dto.deviceCode },
      update: {
        deviceType: dto.deviceType,
        seatId: dto.seatId,
        status: DeviceStatus.ACTIVE,
        lastSeenAt: new Date(),
      },
      create: {
        deviceCode: dto.deviceCode,
        deviceType: dto.deviceType,
        seatId: dto.seatId,
        status: DeviceStatus.ACTIVE,
        lastSeenAt: new Date(),
      },
    });

    return { success: true, data: record, meta: {} };
  }

  private async createSessionAndTokens(params: {
    userId: string;
    role: UserRole;
    name: string;
    studentId?: string;
    loginMethod: LoginMethod;
    deviceCode?: string;
    meta: Record<string, unknown>;
  }) {
    const deviceId = params.deviceCode
      ? (
          await this.prisma.device.findFirst({
            where: { deviceCode: params.deviceCode },
          })
        )?.id
      : null;

    const session = await this.prisma.authSession.create({
      data: {
        userId: params.userId,
        studentId: params.studentId,
        deviceId: deviceId ?? undefined,
        loginMethod: params.loginMethod,
        sessionStatus: SessionStatus.ACTIVE,
      },
    });

    await this.prisma.user.update({
      where: { id: params.userId },
      data: { lastLoginAt: new Date() },
    });

    const tokens = await this.issueTokens({
      sub: params.userId,
      role: params.role,
      name: params.name,
      studentId: params.studentId,
      sessionId: session.id,
    });

    return {
      success: true,
      data: {
        ...tokens,
        sessionId: session.id,
        user: {
          id: params.userId,
          role: params.role,
          name: params.name,
        },
        ...params.meta,
      },
      meta: {},
    };
  }

  private async issueTokens(payload: Omit<JwtPayload, 'tokenType'>) {
    const accessTokenPayload: JwtPayload = { ...payload, tokenType: 'access' };
    const refreshTokenPayload: JwtPayload = {
      ...payload,
      tokenType: 'refresh',
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(accessTokenPayload, {
        secret: process.env.JWT_ACCESS_SECRET,
        expiresIn: process.env.JWT_ACCESS_EXPIRES_IN as never,
      }),
      this.jwtService.signAsync(refreshTokenPayload, {
        secret: process.env.JWT_REFRESH_SECRET,
        expiresIn: process.env.JWT_REFRESH_EXPIRES_IN as never,
      }),
    ]);

    await this.redis.client.set(
      this.refreshTokenKey(payload.sessionId),
      refreshToken,
      'EX',
      60 * 60 * 24 * 30,
    );

    return { accessToken, refreshToken };
  }

  private async verifyToken(
    token: string,
    tokenType: 'access' | 'refresh',
  ): Promise<JwtPayload> {
    const blacklistExists = await this.redis.client.get(
      this.blacklistTokenKey(token),
    );
    if (blacklistExists) {
      throw new UnauthorizedException('토큰이 만료되었습니다.');
    }

    const payload = await this.jwtService.verifyAsync<JwtPayload>(token, {
      secret:
        tokenType === 'access'
          ? process.env.JWT_ACCESS_SECRET
          : process.env.JWT_REFRESH_SECRET,
    });

    if (payload.tokenType !== tokenType) {
      throw new UnauthorizedException('토큰 타입이 올바르지 않습니다.');
    }

    return payload;
  }

  private async revokeActiveStudentSessions(studentId: string) {
    const existing = await this.prisma.authSession.findMany({
      where: {
        studentId,
        sessionStatus: SessionStatus.ACTIVE,
      },
    });

    if (existing.length === 0) {
      return;
    }

    await this.prisma.authSession.updateMany({
      where: { id: { in: existing.map((item) => item.id) } },
      data: {
        sessionStatus: SessionStatus.REVOKED,
        endedAt: new Date(),
        duplicateReplaced: true,
      },
    });

    await Promise.all(
      existing.map((session) =>
        this.redis.client.del(this.refreshTokenKey(session.id)),
      ),
    );
  }

  private refreshTokenKey(sessionId: string) {
    return `auth:refresh:${sessionId}`;
  }

  private blacklistTokenKey(token: string) {
    return `auth:blacklist:${token}`;
  }
}
