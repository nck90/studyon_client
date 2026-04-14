import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '@/database/prisma.service';
import { JwtPayload } from './types/jwt-payload.type';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_ACCESS_SECRET!,
    });
  }

  async validate(payload: JwtPayload): Promise<JwtPayload> {
    if (payload.tokenType !== 'access') {
      throw new UnauthorizedException();
    }

    const [user, session] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: payload.sub },
        select: { id: true, role: true, name: true, status: true },
      }),
      this.prisma.authSession.findUnique({
        where: { id: payload.sessionId },
        select: { id: true, sessionStatus: true },
      }),
    ]);

    if (
      !user ||
      user.status !== 'ACTIVE' ||
      !session ||
      session.sessionStatus !== 'ACTIVE'
    ) {
      throw new UnauthorizedException();
    }

    await this.prisma.authSession.update({
      where: { id: payload.sessionId },
      data: { lastActivityAt: new Date() },
    });

    return {
      sub: user.id,
      role: user.role,
      name: user.name,
      studentId: payload.studentId,
      sessionId: payload.sessionId,
      tokenType: 'access',
    };
  }
}
