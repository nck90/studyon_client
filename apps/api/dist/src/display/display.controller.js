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
exports.DisplayController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const public_decorator_1 = require("../common/decorators/public.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const display_service_1 = require("./display.service");
let DisplayController = class DisplayController {
    displayService;
    constructor(displayService) {
        this.displayService = displayService;
    }
    current() {
        return this.displayService.current();
    }
    rankings(periodType = client_1.RankingPeriodType.DAILY, rankingType = client_1.RankingType.STUDY_TIME) {
        return this.displayService.rankings(periodType, rankingType);
    }
    status() {
        return this.displayService.status();
    }
    motivation() {
        return this.displayService.motivation();
    }
    control(activeScreen) {
        return this.displayService.control(activeScreen);
    }
};
exports.DisplayController = DisplayController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('current'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], DisplayController.prototype, "current", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('rankings'),
    __param(0, (0, common_1.Query)('periodType')),
    __param(1, (0, common_1.Query)('rankingType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], DisplayController.prototype, "rankings", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('status'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], DisplayController.prototype, "status", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('motivation'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], DisplayController.prototype, "motivation", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('control'),
    __param(0, (0, common_1.Body)('activeScreen')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DisplayController.prototype, "control", null);
exports.DisplayController = DisplayController = __decorate([
    (0, swagger_1.ApiTags)('display'),
    (0, common_1.Controller)({ path: 'display', version: '1' }),
    __metadata("design:paramtypes", [display_service_1.DisplayService])
], DisplayController);
//# sourceMappingURL=display.controller.js.map