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
exports.SeatsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const assign_seat_dto_1 = require("./dto/assign-seat.dto");
const seat_change_request_dto_1 = require("./dto/seat-change-request.dto");
const seats_service_1 = require("./seats.service");
let SeatsController = class SeatsController {
    seatsService;
    constructor(seatsService) {
        this.seatsService = seatsService;
    }
    mySeat(user) {
        return this.seatsService.getMySeat(user.studentId);
    }
    seatMap(zone) {
        return this.seatsService.getSeatMap(zone);
    }
    available(zone) {
        return this.seatsService.getAvailableSeats(zone);
    }
    requestChange(user, dto) {
        return this.seatsService.requestSeatChange(user.studentId, dto.toSeatId, dto.reason);
    }
    myRequests(user) {
        return this.seatsService.mySeatChangeRequests(user.studentId);
    }
    adminSeats(zone, status) {
        return this.seatsService.listAdmin(zone, status);
    }
    createSeat(user, seatNo, zone) {
        return this.seatsService.createSeat(seatNo, zone, user.sub);
    }
    updateSeat(user, seatId, status, zone) {
        return this.seatsService.updateSeat(seatId, status, zone, user.sub);
    }
    assign(user, seatId, dto) {
        return this.seatsService.assign(seatId, dto.studentId, dto.assignmentType, user.sub);
    }
    lock(user, seatId) {
        return this.seatsService.lock(seatId, true, user.sub);
    }
    unlock(user, seatId) {
        return this.seatsService.lock(seatId, false, user.sub);
    }
    deleteSeat(user, seatId) {
        return this.seatsService.deleteSeat(seatId, user.sub);
    }
    listRequests() {
        return this.seatsService.listChangeRequests();
    }
    approve(user, requestId) {
        return this.seatsService.reviewRequest(requestId, true, user.sub);
    }
    reject(user, requestId) {
        return this.seatsService.reviewRequest(requestId, false, user.sub);
    }
};
exports.SeatsController = SeatsController;
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/seats/my'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "mySeat", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/seats/map'),
    __param(0, (0, common_1.Query)('zone')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "seatMap", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/seats/available'),
    __param(0, (0, common_1.Query)('zone')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "available", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Post)('student/seat-change-requests'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, seat_change_request_dto_1.SeatChangeRequestDto]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "requestChange", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/seat-change-requests'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "myRequests", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/seats'),
    __param(0, (0, common_1.Query)('zone')),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "adminSeats", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Post)('admin/seats'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)('seatNo')),
    __param(2, (0, common_1.Body)('zone')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "createSeat", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Patch)('admin/seats/:seatId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('seatId')),
    __param(2, (0, common_1.Query)('status')),
    __param(3, (0, common_1.Query)('zone')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "updateSeat", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Post)('admin/seats/:seatId/assign'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('seatId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, assign_seat_dto_1.AssignSeatDto]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "assign", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Post)('admin/seats/:seatId/lock'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('seatId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "lock", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Post)('admin/seats/:seatId/unlock'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('seatId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "unlock", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Delete)('admin/seats/:seatId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('seatId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "deleteSeat", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Get)('admin/seat-change-requests'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "listRequests", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Post)('admin/seat-change-requests/:requestId/approve'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('requestId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "approve", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    (0, common_1.Post)('admin/seat-change-requests/:requestId/reject'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('requestId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], SeatsController.prototype, "reject", null);
exports.SeatsController = SeatsController = __decorate([
    (0, swagger_1.ApiTags)('seats'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Controller)({ version: '1' }),
    __metadata("design:paramtypes", [seats_service_1.SeatsService])
], SeatsController);
//# sourceMappingURL=seats.controller.js.map