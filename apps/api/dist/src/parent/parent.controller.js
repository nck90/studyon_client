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
exports.ParentController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const public_decorator_1 = require("../common/decorators/public.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const parent_service_1 = require("./parent.service");
let ParentController = class ParentController {
    parentService;
    constructor(parentService) {
        this.parentService = parentService;
    }
    issue(user, studentId, expiresInDays) {
        return this.parentService.issueAccessToken(user.sub, studentId, expiresInDays);
    }
    overview(authorization) {
        return this.parentService.getOverview(authorization);
    }
    attendance(authorization, startDate, endDate) {
        return this.parentService.getAttendance(authorization, startDate, endDate);
    }
    studyReport(authorization, startDate, endDate) {
        return this.parentService.getStudyReport(authorization, startDate, endDate);
    }
};
exports.ParentController = ParentController;
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('admin/parent-access/issue'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)('studentId')),
    __param(2, (0, common_1.Body)('expiresInDays')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Number]),
    __metadata("design:returntype", void 0)
], ParentController.prototype, "issue", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('parent/student/overview'),
    __param(0, (0, common_1.Headers)('authorization')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ParentController.prototype, "overview", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('parent/student/attendance'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Query)('startDate')),
    __param(2, (0, common_1.Query)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], ParentController.prototype, "attendance", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('parent/student/study-report'),
    __param(0, (0, common_1.Headers)('authorization')),
    __param(1, (0, common_1.Query)('startDate')),
    __param(2, (0, common_1.Query)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], ParentController.prototype, "studyReport", null);
exports.ParentController = ParentController = __decorate([
    (0, swagger_1.ApiTags)('parent'),
    (0, common_1.Controller)({ version: '1' }),
    __metadata("design:paramtypes", [parent_service_1.ParentService])
], ParentController);
//# sourceMappingURL=parent.controller.js.map