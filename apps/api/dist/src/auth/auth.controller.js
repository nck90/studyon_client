"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const public_decorator_1 = require("../common/decorators/public.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const auth_service_1 = require("./auth.service");
const admin_login_dto_1 = require("./dto/admin-login.dto");
const auto_login_dto_1 = require("./dto/auto-login.dto");
const create_qr_token_dto_1 = require("./dto/create-qr-token.dto");
const logout_dto_1 = require("./dto/logout.dto");
const qr_login_dto_1 = require("./dto/qr-login.dto");
const refresh_token_dto_1 = require("./dto/refresh-token.dto");
const register_device_dto_1 = require("./dto/register-device.dto");
const student_signup_dto_1 = require("./dto/student-signup.dto");
const student_login_dto_1 = require("./dto/student-login.dto");
let AuthController = class AuthController {
    authService;
    constructor(authService) {
        this.authService = authService;
    }
    studentSignup(dto) {
        return this.authService.studentSignup(dto);
    }
    studentLogin(dto) {
        return this.authService.studentLogin(dto);
    }
    studentQrLogin(dto) {
        return this.authService.qrLogin(dto);
    }
    studentAutoLogin(dto) {
        return this.authService.autoLogin(dto);
    }
    adminLogin(dto) {
        return this.authService.adminLogin(dto);
    }
    refresh(dto) {
        return this.authService.refresh(dto.refreshToken);
    }
    logout(dto) {
        return this.authService.logout(dto.sessionId, dto.refreshToken);
    }
    me(user) {
        return this.authService.me(user);
    }
    createQrToken(user, dto) {
        return this.authService.createQrToken(user, dto);
    }
    registerDevice(dto) {
        return this.authService.registerDevice(dto);
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('student/signup'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [student_signup_dto_1.StudentSignupDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "studentSignup", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('student/login'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [student_login_dto_1.StudentLoginDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "studentLogin", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('student/qr-login'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [qr_login_dto_1.QrLoginDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "studentQrLogin", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('student/auto-login'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [auto_login_dto_1.AutoLoginDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "studentAutoLogin", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('admin/login'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [admin_login_dto_1.AdminLoginDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "adminLogin", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('refresh'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [refresh_token_dto_1.RefreshTokenDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "refresh", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('logout'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [logout_dto_1.LogoutDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "logout", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)('me'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "me", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT, client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('student/qr-token'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_qr_token_dto_1.CreateQrTokenDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "createQrToken", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('devices/register'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_device_dto_1.RegisterDeviceDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "registerDevice", null);
exports.AuthController = AuthController = __decorate([
    (0, swagger_1.ApiTags)('auth'),
    (0, common_1.Controller)({ path: 'auth', version: '1' }),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map