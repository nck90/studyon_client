"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const date_util_1 = require("../common/utils/date.util");
const attendances_service_1 = require("../attendances/attendances.service");
const prisma_service_1 = require("../database/prisma.service");
const redis_service_1 = require("../redis/redis.service");
let AuthService = class AuthService {
    prisma;
    redis;
    jwtService;
    attendancesService;
    constructor(prisma, redis, jwtService, attendancesService) {
        this.prisma = prisma;
        this.redis = redis;
        this.jwtService = jwtService;
        this.attendancesService = attendancesService;
    }
    async studentSignup(dto) {
        const existingLogin = await this.prisma.student.findUnique({
            where: { loginId: dto.loginId },
            select: { id: true },
        });
        if (existingLogin) {
            throw new common_1.ConflictException('이미 사용 중인 아이디입니다.');
        }
        const existingStudent = await this.prisma.student.findUnique({
            where: { studentNo: dto.studentNo },
            include: { user: true, class: true, assignedSeat: true },
        });
        const passwordHash = await bcrypt.hash(dto.password, 10);
        if (existingStudent?.user.status === 'ACTIVE') {
            throw new common_1.ConflictException('이미 가입된 학번입니다.');
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
                role: client_1.UserRole.STUDENT,
                name: dto.name,
                studentId: existingStudent.id,
                loginMethod: client_1.LoginMethod.STUDENT_ID_PASSWORD,
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
                    role: client_1.UserRole.STUDENT,
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
            role: client_1.UserRole.STUDENT,
            name: created.user.name,
            studentId: created.student.id,
            loginMethod: client_1.LoginMethod.STUDENT_ID_PASSWORD,
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
    async studentLogin(dto) {
        if (!dto.loginId.trim() || !dto.password.trim()) {
            throw new common_1.BadRequestException('아이디와 비밀번호를 입력해 주세요.');
        }
        const student = await this.prisma.student.findFirst({
            where: {
                loginId: dto.loginId,
                user: { status: 'ACTIVE' },
            },
            include: { user: true, class: true, assignedSeat: true },
        });
        if (!student ||
            !(await bcrypt.compare(dto.password, student.passwordHash))) {
            throw new common_1.UnauthorizedException('아이디 또는 비밀번호를 확인해 주세요.');
        }
        await this.revokeActiveStudentSessions(student.id);
        return this.createSessionAndTokens({
            userId: student.userId,
            role: client_1.UserRole.STUDENT,
            name: student.user.name,
            studentId: student.id,
            loginMethod: client_1.LoginMethod.STUDENT_ID_PASSWORD,
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
    async qrLogin(dto) {
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
            throw new common_1.UnauthorizedException('QR 토큰이 유효하지 않습니다.');
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
            role: client_1.UserRole.STUDENT,
            name: qrToken.student.user.name,
            studentId: qrToken.student.id,
            loginMethod: client_1.LoginMethod.QR,
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
    async autoLogin(dto) {
        const device = await this.prisma.device.findFirst({
            where: {
                deviceCode: dto.deviceCode,
                status: client_1.DeviceStatus.ACTIVE,
                deviceType: client_1.DeviceType.TABLET,
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
            throw new common_1.UnauthorizedException('자동 로그인 가능한 좌석 태블릿 정보가 없습니다.');
        }
        await this.prisma.device.update({
            where: { id: device.id },
            data: { lastSeenAt: new Date() },
        });
        await this.revokeActiveStudentSessions(student.id);
        return this.createSessionAndTokens({
            userId: student.userId,
            role: client_1.UserRole.STUDENT,
            name: student.user.name,
            studentId: student.id,
            loginMethod: client_1.LoginMethod.AUTO,
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
    async adminSignup(dto) {
        const existing = await this.prisma.adminUser.findUnique({
            where: { email: dto.email },
        });
        if (existing) {
            throw new common_1.ConflictException('이미 사용 중인 이메일입니다.');
        }
        const passwordHash = await bcrypt.hash(dto.password, 10);
        const result = await this.prisma.$transaction(async (tx) => {
            const user = await tx.user.create({
                data: {
                    role: client_1.UserRole.ADMIN,
                    status: 'ACTIVE',
                    name: dto.name,
                },
            });
            const admin = await tx.adminUser.create({
                data: {
                    userId: user.id,
                    adminType: client_1.UserRole.ADMIN,
                    email: dto.email,
                    passwordHash,
                },
            });
            return { user, admin };
        });
        return this.createSessionAndTokens({
            userId: result.user.id,
            role: client_1.UserRole.ADMIN,
            name: result.user.name,
            loginMethod: client_1.LoginMethod.ADMIN_PASSWORD,
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
    async adminLogin(dto) {
        const admin = await this.prisma.adminUser.findUnique({
            where: { email: dto.email },
            include: { user: true },
        });
        if (!admin || admin.user.status !== 'ACTIVE') {
            throw new common_1.UnauthorizedException('관리자 정보를 확인할 수 없습니다.');
        }
        const isMatched = await bcrypt.compare(dto.password, admin.passwordHash);
        if (!isMatched) {
            throw new common_1.UnauthorizedException('관리자 정보를 확인할 수 없습니다.');
        }
        return this.createSessionAndTokens({
            userId: admin.userId,
            role: admin.adminType,
            name: admin.user.name,
            loginMethod: client_1.LoginMethod.ADMIN_PASSWORD,
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
    async refresh(refreshToken) {
        const payload = await this.verifyToken(refreshToken, 'refresh');
        const saved = await this.redis.client.get(this.refreshTokenKey(payload.sessionId));
        if (!saved || saved !== refreshToken) {
            throw new common_1.UnauthorizedException('세션이 만료되었습니다.');
        }
        const session = await this.prisma.authSession.findUnique({
            where: { id: payload.sessionId },
        });
        if (!session || session.sessionStatus !== client_1.SessionStatus.ACTIVE) {
            throw new common_1.UnauthorizedException('세션이 비활성화되었습니다.');
        }
        const user = await this.prisma.user.findUnique({
            where: { id: payload.sub },
        });
        if (!user) {
            throw new common_1.UnauthorizedException();
        }
        return this.issueTokens({
            sub: user.id,
            role: payload.role,
            name: user.name,
            studentId: payload.studentId,
            sessionId: payload.sessionId,
        });
    }
    async logout(sessionId, refreshToken) {
        const session = await this.prisma.authSession.findUnique({
            where: { id: sessionId },
            select: { studentId: true, sessionStatus: true },
        });
        if (session?.studentId && session.sessionStatus === client_1.SessionStatus.ACTIVE) {
            const attendance = await this.prisma.attendance.findUnique({
                where: {
                    studentId_attendanceDate: {
                        studentId: session.studentId,
                        attendanceDate: (0, date_util_1.dateOnly)(),
                    },
                },
                select: { attendanceStatus: true },
            });
            if (attendance?.attendanceStatus === client_1.AttendanceStatus.CHECKED_IN) {
                await this.attendancesService.checkOut(session.studentId, true);
            }
        }
        await this.prisma.authSession.update({
            where: { id: sessionId },
            data: { sessionStatus: client_1.SessionStatus.LOGGED_OUT, endedAt: new Date() },
        });
        await this.redis.client.del(this.refreshTokenKey(sessionId));
        await this.redis.client.set(this.blacklistTokenKey(refreshToken), '1', 'EX', 60 * 60 * 24 * 30);
        return {
            success: true,
            data: { sessionId, loggedOut: true },
            meta: {},
        };
    }
    async me(user) {
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
    async createQrToken(user, dto) {
        const studentId = user.role === client_1.UserRole.STUDENT ? user.studentId : dto.studentId;
        if (!studentId) {
            throw new common_1.UnauthorizedException('학생 정보가 필요합니다.');
        }
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
        });
        if (!student) {
            throw new common_1.UnauthorizedException('학생 정보를 확인할 수 없습니다.');
        }
        const device = dto.deviceCode
            ? await this.prisma.device.findFirst({
                where: { deviceCode: dto.deviceCode, status: client_1.DeviceStatus.ACTIVE },
            })
            : null;
        const token = `${student.studentNo}-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
        const record = await this.prisma.qrLoginToken.create({
            data: {
                studentId,
                deviceId: device?.id,
                token,
                tokenType: device ? client_1.QrTokenType.SEAT_LOGIN : client_1.QrTokenType.STUDENT_LOGIN,
                expiresAt: new Date(Date.now() + 1000 * 60 * 5),
            },
        });
        return { success: true, data: record, meta: {} };
    }
    async registerDevice(dto) {
        const record = await this.prisma.device.upsert({
            where: { deviceCode: dto.deviceCode },
            update: {
                deviceType: dto.deviceType,
                seatId: dto.seatId,
                status: client_1.DeviceStatus.ACTIVE,
                lastSeenAt: new Date(),
            },
            create: {
                deviceCode: dto.deviceCode,
                deviceType: dto.deviceType,
                seatId: dto.seatId,
                status: client_1.DeviceStatus.ACTIVE,
                lastSeenAt: new Date(),
            },
        });
        return { success: true, data: record, meta: {} };
    }
    async createSessionAndTokens(params) {
        const deviceId = params.deviceCode
            ? (await this.prisma.device.findFirst({
                where: { deviceCode: params.deviceCode },
            }))?.id
            : null;
        const session = await this.prisma.authSession.create({
            data: {
                userId: params.userId,
                studentId: params.studentId,
                deviceId: deviceId ?? undefined,
                loginMethod: params.loginMethod,
                sessionStatus: client_1.SessionStatus.ACTIVE,
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
    async issueTokens(payload) {
        const accessTokenPayload = { ...payload, tokenType: 'access' };
        const refreshTokenPayload = {
            ...payload,
            tokenType: 'refresh',
        };
        const [accessToken, refreshToken] = await Promise.all([
            this.jwtService.signAsync(accessTokenPayload, {
                secret: process.env.JWT_ACCESS_SECRET,
                expiresIn: process.env.JWT_ACCESS_EXPIRES_IN,
            }),
            this.jwtService.signAsync(refreshTokenPayload, {
                secret: process.env.JWT_REFRESH_SECRET,
                expiresIn: process.env.JWT_REFRESH_EXPIRES_IN,
            }),
        ]);
        await this.redis.client.set(this.refreshTokenKey(payload.sessionId), refreshToken, 'EX', 60 * 60 * 24 * 30);
        return { accessToken, refreshToken };
    }
    async verifyToken(token, tokenType) {
        const blacklistExists = await this.redis.client.get(this.blacklistTokenKey(token));
        if (blacklistExists) {
            throw new common_1.UnauthorizedException('토큰이 만료되었습니다.');
        }
        const payload = await this.jwtService.verifyAsync(token, {
            secret: tokenType === 'access'
                ? process.env.JWT_ACCESS_SECRET
                : process.env.JWT_REFRESH_SECRET,
        });
        if (payload.tokenType !== tokenType) {
            throw new common_1.UnauthorizedException('토큰 타입이 올바르지 않습니다.');
        }
        return payload;
    }
    async revokeActiveStudentSessions(studentId) {
        const existing = await this.prisma.authSession.findMany({
            where: {
                studentId,
                sessionStatus: client_1.SessionStatus.ACTIVE,
            },
        });
        if (existing.length === 0) {
            return;
        }
        await this.prisma.authSession.updateMany({
            where: { id: { in: existing.map((item) => item.id) } },
            data: {
                sessionStatus: client_1.SessionStatus.REVOKED,
                endedAt: new Date(),
                duplicateReplaced: true,
            },
        });
        await Promise.all(existing.map((session) => this.redis.client.del(this.refreshTokenKey(session.id))));
    }
    refreshTokenKey(sessionId) {
        return `auth:refresh:${sessionId}`;
    }
    blacklistTokenKey(token) {
        return `auth:blacklist:${token}`;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService,
        jwt_1.JwtService,
        attendances_service_1.AttendancesService])
], AuthService);
//# sourceMappingURL=auth.service.js.map