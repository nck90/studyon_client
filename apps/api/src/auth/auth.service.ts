import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
  DeviceStatus,
  DeviceType,
  LoginMethod,
  QrTokenType,
  SessionStatus,
  UserRole,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '@/database/prisma.service';
import { RedisService } from '@/redis/redis.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import { AutoLoginDto } from './dto/auto-login.dto';
import { CreateQrTokenDto } from './dto/create-qr-token.dto';
import { QrLoginDto } from './dto/qr-login.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { StudentLoginDto } from './dto/student-login.dto';
import { JwtPayload } from './types/jwt-payload.type';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly jwtService: JwtService,
  ) {}

  async studentLogin(dto: StudentLoginDto) {
    const student = await this.prisma.student.findFirst({
      where: {
        studentNo: dto.studentNo,
        user: { name: dto.name, status: 'ACTIVE' },
      },
      include: { user: true, class: true, assignedSeat: true },
    });

    if (!student) {
      throw new UnauthorizedException('학생 정보를 확인할 수 없습니다.');
    }

    await this.revokeActiveStudentSessions(student.id);

    return this.createSessionAndTokens({
      userId: student.userId,
      role: UserRole.STUDENT,
      name: student.user.name,
      studentId: student.id,
      loginMethod: LoginMethod.STUDENT_NO_NAME,
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
