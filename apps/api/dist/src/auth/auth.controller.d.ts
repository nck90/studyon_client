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
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    studentSignup(dto: StudentSignupDto): Promise<{
        success: boolean;
        data: {
            sessionId: string;
            user: {
                id: string;
                role: import("@prisma/client").$Enums.UserRole;
                name: string;
            };
            accessToken: string;
            refreshToken: string;
        };
        meta: {};
    }>;
    studentLogin(dto: StudentLoginDto): Promise<{
        success: boolean;
        data: {
            sessionId: string;
            user: {
                id: string;
                role: import("@prisma/client").$Enums.UserRole;
                name: string;
            };
            accessToken: string;
            refreshToken: string;
        };
        meta: {};
    }>;
    studentQrLogin(dto: QrLoginDto): Promise<{
        success: boolean;
        data: {
            sessionId: string;
            user: {
                id: string;
                role: import("@prisma/client").$Enums.UserRole;
                name: string;
            };
            accessToken: string;
            refreshToken: string;
        };
        meta: {};
    }>;
    studentAutoLogin(dto: AutoLoginDto): Promise<{
        success: boolean;
        data: {
            sessionId: string;
            user: {
                id: string;
                role: import("@prisma/client").$Enums.UserRole;
                name: string;
            };
            accessToken: string;
            refreshToken: string;
        };
        meta: {};
    }>;
    adminLogin(dto: AdminLoginDto): Promise<{
        success: boolean;
        data: {
            sessionId: string;
            user: {
                id: string;
                role: import("@prisma/client").$Enums.UserRole;
                name: string;
            };
            accessToken: string;
            refreshToken: string;
        };
        meta: {};
    }>;
    refresh(dto: RefreshTokenDto): Promise<{
        accessToken: string;
        refreshToken: string;
    }>;
    logout(dto: LogoutDto): Promise<{
        success: boolean;
        data: {
            sessionId: string;
            loggedOut: boolean;
        };
        meta: {};
    }>;
    me(user: JwtPayload): Promise<{
        success: boolean;
        data: ({
            student: ({
                class: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                    gradeId: string | null;
                } | null;
                group: {
                    id: string;
                    name: string;
                    sortOrder: number;
                    createdAt: Date;
                    classId: string | null;
                } | null;
                assignedSeat: {
                    id: string;
                    createdAt: Date;
                    seatNo: string;
                    zone: string | null;
                    status: import("@prisma/client").$Enums.SeatStatus;
                    isActive: boolean;
                    currentStudentId: string | null;
                    updatedAt: Date;
                } | null;
            } & {
                id: string;
                createdAt: Date;
                gradeId: string | null;
                classId: string | null;
                updatedAt: Date;
                userId: string;
                studentNo: string;
                groupId: string | null;
                assignedSeatId: string | null;
                enrollmentStatus: import("@prisma/client").$Enums.EnrollmentStatus;
                joinedAt: Date | null;
                memo: string | null;
            }) | null;
            adminUser: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                userId: string;
                email: string;
                adminType: import("@prisma/client").$Enums.UserRole;
                passwordHash: string;
                lastPasswordChangedAt: Date | null;
            } | null;
        } & {
            id: string;
            name: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.UserStatus;
            updatedAt: Date;
            role: import("@prisma/client").$Enums.UserRole;
            phone: string | null;
            lastLoginAt: Date | null;
        }) | null;
        meta: {};
    }>;
    createQrToken(user: JwtPayload, dto: CreateQrTokenDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            studentId: string | null;
            deviceId: string | null;
            token: string;
            tokenType: import("@prisma/client").$Enums.QrTokenType;
            expiresAt: Date;
            usedAt: Date | null;
        };
        meta: {};
    }>;
    registerDevice(dto: RegisterDeviceDto): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            status: import("@prisma/client").$Enums.DeviceStatus;
            updatedAt: Date;
            deviceCode: string;
            deviceType: import("@prisma/client").$Enums.DeviceType;
            seatId: string | null;
            lastSeenAt: Date | null;
        };
        meta: {};
    }>;
}
