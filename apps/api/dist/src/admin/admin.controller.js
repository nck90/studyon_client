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
exports.AdminController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const admin_service_1 = require("./admin.service");
function optionalString(value) {
    return typeof value === 'string' && value.length > 0 ? value : undefined;
}
let AdminController = class AdminController {
    adminService;
    constructor(adminService) {
        this.adminService = adminService;
    }
    dashboard(date, classId, groupId) {
        return this.adminService.dashboard(date, classId, groupId);
    }
    students(keyword, gradeId, classId, groupId, status) {
        return this.adminService.listStudents({
            keyword,
            gradeId,
            classId,
            groupId,
            status,
        });
    }
    createStudent(user, body) {
        return this.adminService.createStudent({
            actorUserId: user.sub,
            studentNo: optionalString(body.studentNo) ?? '',
            name: optionalString(body.name) ?? '',
            gradeId: optionalString(body.gradeId),
            classId: optionalString(body.classId),
            groupId: optionalString(body.groupId),
            assignedSeatId: optionalString(body.assignedSeatId),
        });
    }
    student(studentId) {
        return this.adminService.getStudent(studentId);
    }
    patchStudent(user, studentId, body) {
        return this.adminService.updateStudent(studentId, body, user.sub);
    }
    deleteStudent(user, studentId) {
        return this.adminService.deleteStudent(studentId, user.sub);
    }
    studyOverview(startDate, endDate, classId, groupId) {
        return this.adminService.getStudyOverview(startDate, endDate, classId, groupId);
    }
    studyOverviewSubjects(startDate, endDate, classId, groupId) {
        return this.adminService.getStudyOverviewSubjects(startDate, endDate, classId, groupId);
    }
    studentStudySummary(studentId) {
        return this.adminService.studentStudySummary(studentId);
    }
    classStudySummary(classId) {
        return this.adminService.classStudySummary(classId);
    }
    grades() {
        return this.adminService.grades();
    }
    createGrade(user, name) {
        return this.adminService.createGrade(name, user.sub);
    }
    classes() {
        return this.adminService.classes();
    }
    createClass(user, name, gradeId) {
        return this.adminService.createClass(name, gradeId, user.sub);
    }
    groups() {
        return this.adminService.groups();
    }
    createGroup(user, name, classId) {
        return this.adminService.createGroup(name, classId, user.sub);
    }
    auditLogs(actionType, targetType) {
        return this.adminService.auditLogs(actionType, targetType);
    }
    directorOverview(startDate, endDate) {
        return this.adminService.directorOverview(startDate, endDate);
    }
    operationsReport(periodType = 'monthly', periodKey) {
        return this.adminService.operationsReport(periodType, periodKey);
    }
    performanceAnalytics(startDate, endDate, classId) {
        return this.adminService.performanceAnalytics(startDate, endDate, classId);
    }
};
exports.AdminController = AdminController;
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/dashboard'),
    __param(0, (0, common_1.Query)('date')),
    __param(1, (0, common_1.Query)('classId')),
    __param(2, (0, common_1.Query)('groupId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "dashboard", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/students'),
    __param(0, (0, common_1.Query)('keyword')),
    __param(1, (0, common_1.Query)('gradeId')),
    __param(2, (0, common_1.Query)('classId')),
    __param(3, (0, common_1.Query)('groupId')),
    __param(4, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "students", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('admin/students'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createStudent", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/students/:studentId'),
    __param(0, (0, common_1.Param)('studentId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "student", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Patch)('admin/students/:studentId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('studentId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "patchStudent", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Delete)('admin/students/:studentId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('studentId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "deleteStudent", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/study-overview'),
    __param(0, (0, common_1.Query)('startDate')),
    __param(1, (0, common_1.Query)('endDate')),
    __param(2, (0, common_1.Query)('classId')),
    __param(3, (0, common_1.Query)('groupId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "studyOverview", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/study-overview/subjects'),
    __param(0, (0, common_1.Query)('startDate')),
    __param(1, (0, common_1.Query)('endDate')),
    __param(2, (0, common_1.Query)('classId')),
    __param(3, (0, common_1.Query)('groupId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "studyOverviewSubjects", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/students/:studentId/study-summary'),
    __param(0, (0, common_1.Param)('studentId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "studentStudySummary", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/classes/:classId/study-summary'),
    __param(0, (0, common_1.Param)('classId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "classStudySummary", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/grades'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "grades", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('admin/grades'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)('name')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createGrade", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/classes'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "classes", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('admin/classes'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)('name')),
    __param(2, (0, common_1.Body)('gradeId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createClass", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/groups'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "groups", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('admin/groups'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)('name')),
    __param(2, (0, common_1.Body)('classId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createGroup", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/audit-logs'),
    __param(0, (0, common_1.Query)('actionType')),
    __param(1, (0, common_1.Query)('targetType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "auditLogs", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('director/overview'),
    __param(0, (0, common_1.Query)('startDate')),
    __param(1, (0, common_1.Query)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "directorOverview", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('director/reports/operations'),
    __param(0, (0, common_1.Query)('periodType')),
    __param(1, (0, common_1.Query)('periodKey')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "operationsReport", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('director/analytics/performance'),
    __param(0, (0, common_1.Query)('startDate')),
    __param(1, (0, common_1.Query)('endDate')),
    __param(2, (0, common_1.Query)('classId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "performanceAnalytics", null);
exports.AdminController = AdminController = __decorate([
    (0, swagger_1.ApiTags)('admin'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Controller)({ version: '1' }),
    __metadata("design:paramtypes", [admin_service_1.AdminService])
], AdminController);
//# sourceMappingURL=admin.controller.js.map