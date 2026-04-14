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
exports.EventsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const public_decorator_1 = require("../common/decorators/public.decorator");
const events_service_1 = require("./events.service");
function parseChannels(value) {
    return value
        ?.split(',')
        .map((item) => item.trim())
        .filter(Boolean);
}
let EventsController = class EventsController {
    eventsService;
    constructor(eventsService) {
        this.eventsService = eventsService;
    }
    streamPublic(channels) {
        return this.eventsService.streamPublic(parseChannels(channels));
    }
    streamMe(user, channels) {
        return this.eventsService.streamUser(user.sub, parseChannels(channels));
    }
};
exports.EventsController = EventsController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Sse)('public'),
    __param(0, (0, common_1.Query)('channels')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], EventsController.prototype, "streamPublic", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Sse)('me'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('channels')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], EventsController.prototype, "streamMe", null);
exports.EventsController = EventsController = __decorate([
    (0, swagger_1.ApiTags)('events'),
    (0, common_1.Controller)({ path: 'events', version: '1' }),
    __metadata("design:paramtypes", [events_service_1.EventsService])
], EventsController);
//# sourceMappingURL=events.controller.js.map