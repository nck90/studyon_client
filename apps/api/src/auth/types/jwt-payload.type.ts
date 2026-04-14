import { UserRole } from '@prisma/client';

export type JwtPayload = {
  sub: string;
  role: UserRole;
  name: string;
  studentId?: string;
  sessionId: string;
  tokenType: 'access' | 'refresh';
};
