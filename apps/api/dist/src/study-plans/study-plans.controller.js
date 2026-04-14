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
exports.StudyPlansController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const create_study_plan_dto_1 = require("./dto/create-study-plan.dto");
const update_study_plan_dto_1 = require("./dto/update-study-plan.dto");
const study_plans_service_1 = require("./study-plans.service");
let StudyPlansController = class StudyPlansController {
    studyPlansService;
    constructor(studyPlansService) {
        this.studyPlansService = studyPlansService;
    }
    list(user, date) {
        return this.studyPlansService.list(user.studentId, date);
    }
    get(user, planId) {
        return this.studyPlansService.get(user.studentId, planId);
    }
    create(user, dto) {
        return this.studyPlansService.create(user.studentId, dto);
    }
    update(user, planId, dto) {
        return this.studyPlansService.update(user.studentId, planId, dto);
    }
    remove(user, planId) {
        return this.studyPlansService.remove(user.studentId, planId);
    }
    complete(user, planId) {
        return this.studyPlansService.complete(user.studentId, planId);
    }
};
exports.StudyPlansController = StudyPlansController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('date')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudyPlansController.prototype, "list", null);
__decorate([
    (0, common_1.Get)(':planId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('planId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudyPlansController.prototype, "get", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_study_plan_dto_1.CreateStudyPlanDto]),
    __metadata("design:returntype", void 0)
], StudyPlansController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)(':planId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('planId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_study_plan_dto_1.UpdateStudyPlanDto]),
    __metadata("design:returntype", void 0)
], StudyPlansController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':planId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('planId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudyPlansController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)(':planId/complete'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('planId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudyPlansController.prototype, "complete", null);
exports.StudyPlansController = StudyPlansController = __decorate([
    (0, swagger_1.ApiTags)('study-plans'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Controller)({ path: 'student/study-plans', version: '1' }),
    __metadata("design:paramtypes", [study_plans_service_1.StudyPlansService])
], StudyPlansController);
//# sourceMappingURL=study-plans.controller.js.map