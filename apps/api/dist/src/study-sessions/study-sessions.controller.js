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
exports.StudySessionsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const start_study_session_dto_1 = require("./dto/start-study-session.dto");
const study_sessions_service_1 = require("./study-sessions.service");
let StudySessionsController = class StudySessionsController {
    studySessionsService;
    constructor(studySessionsService) {
        this.studySessionsService = studySessionsService;
    }
    active(user) {
        return this.studySessionsService.active(user.studentId);
    }
    list(user, startDate, endDate) {
        return this.studySessionsService.list(user.studentId, startDate, endDate);
    }
    start(user, dto) {
        return this.studySessionsService.start(user.studentId, dto.linkedPlanId);
    }
    pause(user, sessionId) {
        return this.studySessionsService.pause(user.studentId, sessionId);
    }
    resume(user, sessionId) {
        return this.studySessionsService.resume(user.studentId, sessionId);
    }
    end(user, sessionId) {
        return this.studySessionsService.end(user.studentId, sessionId);
    }
};
exports.StudySessionsController = StudySessionsController;
__decorate([
    (0, common_1.Get)('active'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudySessionsController.prototype, "active", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('startDate')),
    __param(2, (0, common_1.Query)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], StudySessionsController.prototype, "list", null);
__decorate([
    (0, common_1.Post)('start'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, start_study_session_dto_1.StartStudySessionDto]),
    __metadata("design:returntype", void 0)
], StudySessionsController.prototype, "start", null);
__decorate([
    (0, common_1.Post)(':sessionId/pause'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('sessionId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudySessionsController.prototype, "pause", null);
__decorate([
    (0, common_1.Post)(':sessionId/resume'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('sessionId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudySessionsController.prototype, "resume", null);
__decorate([
    (0, common_1.Post)(':sessionId/end'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('sessionId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudySessionsController.prototype, "end", null);
exports.StudySessionsController = StudySessionsController = __decorate([
    (0, swagger_1.ApiTags)('study-sessions'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Controller)({ path: 'student/study-sessions', version: '1' }),
    __metadata("design:paramtypes", [study_sessions_service_1.StudySessionsService])
], StudySessionsController);
//# sourceMappingURL=study-sessions.controller.js.map