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
exports.AttendancesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const check_in_dto_1 = require("./dto/check-in.dto");
const check_out_dto_1 = require("./dto/check-out.dto");
const update_attendance_dto_1 = require("./dto/update-attendance.dto");
const attendances_service_1 = require("./attendances.service");
let AttendancesController = class AttendancesController {
    attendancesService;
    constructor(attendancesService) {
        this.attendancesService = attendancesService;
    }
    getToday(user) {
        return this.attendancesService.getToday(user.studentId);
    }
    listStudent(user, startDate, endDate) {
        return this.attendancesService.listStudentAttendances(user.studentId, startDate, endDate);
    }
    checkIn(user, dto) {
        return this.attendancesService.checkIn(user.studentId, dto.seatId);
    }
    checkOut(user, dto) {
        return this.attendancesService.checkOut(user.studentId, dto.forceCloseStudySession);
    }
    listAdmin(date, classId, groupId, attendanceStatus) {
        return this.attendancesService.listAdmin(date, classId, groupId, attendanceStatus);
    }
    getAdmin(attendanceId) {
        return this.attendancesService.getAdmin(attendanceId);
    }
    stats(startDate, endDate, classId) {
        return this.attendancesService.stats(startDate, endDate, classId);
    }
    patch(user, attendanceId, dto) {
        return this.attendancesService.updateAdmin(attendanceId, dto, user.sub);
    }
};
exports.AttendancesController = AttendancesController;
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/attendances/today'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "getToday", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/attendances'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('startDate')),
    __param(2, (0, common_1.Query)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "listStudent", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Post)('student/attendances/check-in'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, check_in_dto_1.CheckInDto]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "checkIn", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Post)('student/attendances/check-out'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, check_out_dto_1.CheckOutDto]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "checkOut", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/attendances'),
    __param(0, (0, common_1.Query)('date')),
    __param(1, (0, common_1.Query)('classId')),
    __param(2, (0, common_1.Query)('groupId')),
    __param(3, (0, common_1.Query)('attendanceStatus')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "listAdmin", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/attendances/:attendanceId'),
    __param(0, (0, common_1.Param)('attendanceId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "getAdmin", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/attendance-stats'),
    __param(0, (0, common_1.Query)('startDate')),
    __param(1, (0, common_1.Query)('endDate')),
    __param(2, (0, common_1.Query)('classId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "stats", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Patch)('admin/attendances/:attendanceId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('attendanceId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_attendance_dto_1.UpdateAttendanceDto]),
    __metadata("design:returntype", void 0)
], AttendancesController.prototype, "patch", null);
exports.AttendancesController = AttendancesController = __decorate([
    (0, swagger_1.ApiTags)('attendances'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Controller)({ version: '1' }),
    __metadata("design:paramtypes", [attendances_service_1.AttendancesService])
], AttendancesController);
//# sourceMappingURL=attendances.controller.js.map