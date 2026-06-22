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
exports.StudentsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const students_service_1 = require("./students.service");
let StudentsController = class StudentsController {
    studentsService;
    constructor(studentsService) {
        this.studentsService = studentsService;
    }
    home(user) {
        return this.studentsService.getStudentHome(user.studentId);
    }
    profile(user) {
        return this.studentsService.getProfile(user.studentId);
    }
    badges(user) {
        return this.studentsService.getBadges(user.studentId);
    }
    preferences(user) {
        return this.studentsService.getPreferences(user.studentId);
    }
    focusPolicy() {
        return this.studentsService.getFocusPolicy();
    }
    updatePreferences(user, body) {
        return this.studentsService.updatePreferences(user.studentId, body);
    }
    focusEvent(user, body) {
        return this.studentsService.recordFocusEvent(user.studentId, body);
    }
    motivationDashboard(user) {
        return this.studentsService.getMotivationDashboard(user.studentId);
    }
    goalRoadmap(user) {
        return this.studentsService.getGoalRoadmap(user.studentId);
    }
    saveGoalRoadmap(user, body) {
        return this.studentsService.saveGoalRoadmap(user.studentId, body);
    }
    generateGoalRoadmap(user) {
        return this.studentsService.generateGoalRoadmap(user.studentId);
    }
    acceptRoadmapMission(user, missionId) {
        return this.studentsService.acceptRoadmapMission(user.studentId, missionId);
    }
    dailyMissionToday(user) {
        return this.studentsService.getTodayDailyMission(user.studentId);
    }
    generateDailyMission(user) {
        return this.studentsService.generateTodayDailyMission(user.studentId);
    }
    completeDailyMission(user, missionId, body) {
        return this.studentsService.completeDailyMission(user.studentId, missionId, body.completionMethod);
    }
    updateDailyMissionReminder(user, body) {
        return this.studentsService.updateDailyMissionReminder(user.studentId, body);
    }
    appEvent(user, body) {
        return this.studentsService.recordAppEvent(user.studentId, body);
    }
};
exports.StudentsController = StudentsController;
__decorate([
    (0, common_1.Get)('home'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "home", null);
__decorate([
    (0, common_1.Get)('profile'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "profile", null);
__decorate([
    (0, common_1.Get)('badges'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "badges", null);
__decorate([
    (0, common_1.Get)('preferences'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "preferences", null);
__decorate([
    (0, common_1.Get)('focus-policy'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "focusPolicy", null);
__decorate([
    (0, common_1.Patch)('preferences'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "updatePreferences", null);
__decorate([
    (0, common_1.Post)('focus-events'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "focusEvent", null);
__decorate([
    (0, common_1.Get)('motivation-dashboard'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "motivationDashboard", null);
__decorate([
    (0, common_1.Get)('goal-roadmap'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "goalRoadmap", null);
__decorate([
    (0, common_1.Put)('goal-roadmap'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "saveGoalRoadmap", null);
__decorate([
    (0, common_1.Post)('goal-roadmap/generate'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "generateGoalRoadmap", null);
__decorate([
    (0, common_1.Post)('goal-roadmap/missions/:missionId/accept'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('missionId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "acceptRoadmapMission", null);
__decorate([
    (0, common_1.Get)('daily-mission/today'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "dailyMissionToday", null);
__decorate([
    (0, common_1.Post)('daily-mission/generate'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "generateDailyMission", null);
__decorate([
    (0, common_1.Post)('daily-mission/:missionId/complete'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('missionId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "completeDailyMission", null);
__decorate([
    (0, common_1.Patch)('daily-mission/reminder'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "updateDailyMissionReminder", null);
__decorate([
    (0, common_1.Post)('app-events'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "appEvent", null);
exports.StudentsController = StudentsController = __decorate([
    (0, swagger_1.ApiTags)('student'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Controller)({ path: 'student', version: '1' }),
    __metadata("design:paramtypes", [students_service_1.StudentsService])
], StudentsController);
//# sourceMappingURL=students.controller.js.map