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
exports.CharactersController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const characters_service_1 = require("./characters.service");
let CharactersController = class CharactersController {
    charactersService;
    constructor(charactersService) {
        this.charactersService = charactersService;
    }
    getMyCharacter(user) {
        return this.charactersService.getMyCharacter(user.studentId);
    }
    getShop(user, category) {
        return this.charactersService.getShop(user.studentId, category);
    }
    getOwnedItems(user) {
        return this.charactersService.getOwnedItems(user.studentId);
    }
    buyItem(user, itemId) {
        return this.charactersService.buyItem(user.studentId, itemId);
    }
    equip(user, body) {
        return this.charactersService.equip(user.studentId, body);
    }
};
exports.CharactersController = CharactersController;
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/character'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], CharactersController.prototype, "getMyCharacter", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/character/shop'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('category')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], CharactersController.prototype, "getShop", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/character/items'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], CharactersController.prototype, "getOwnedItems", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Post)('student/character/buy/:itemId'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('itemId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], CharactersController.prototype, "buyItem", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Post)('student/character/equip'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], CharactersController.prototype, "equip", null);
exports.CharactersController = CharactersController = __decorate([
    (0, swagger_1.ApiTags)('characters'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Controller)({ version: '1' }),
    __metadata("design:paramtypes", [characters_service_1.CharactersService])
], CharactersController);
//# sourceMappingURL=characters.controller.js.map