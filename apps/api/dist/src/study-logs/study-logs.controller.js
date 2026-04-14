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
exports.StudyLogsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const create_study_log_dto_1 = require("./dto/create-study-log.dto");
const update_study_log_dto_1 = require("./dto/update-study-log.dto");
const study_logs_service_1 = require("./study-logs.service");
let StudyLogsController = class StudyLogsController {
    studyLogsService;
    constructor(studyLogsService) {
        this.studyLogsService = studyLogsService;
    }
    list(user, date, startDate, endDate) {
        return this.studyLogsService.list(user.studentId, date, startDate, endDate);
    }
    create(user, dto) {
        return this.studyLogsService.create(user.studentId, dto);
    }
    update(user, logId, dto) {
        return this.studyLogsService.update(user.studentId, logId, dto);
    }
    remove(user, logId) {
        return this.studyLogsService.remove(user.studentId, logId);
    }
};
exports.StudyLogsController = StudyLogsController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('date')),
    __param(2, (0, common_1.Query)('startDate')),
    __param(3, (0, common_1.Query)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String, String]),
    __metadata("design:returntype", void 0)
], StudyLogsController.prototype, "list", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_study_log_dto_1.CreateStudyLogDto]),
    __metadata("design:returntype", void 0)
], StudyLogsController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)(':logId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('logId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_study_log_dto_1.UpdateStudyLogDto]),
    __metadata("design:returntype", void 0)
], StudyLogsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':logId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('logId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudyLogsController.prototype, "remove", null);
exports.StudyLogsController = StudyLogsController = __decorate([
    (0, swagger_1.ApiTags)('study-logs'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Controller)({ path: 'student/study-logs', version: '1' }),
    __metadata("design:paramtypes", [study_logs_service_1.StudyLogsService])
], StudyLogsController);
//# sourceMappingURL=study-logs.controller.js.map