"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventsService = void 0;
const common_1 = require("@nestjs/common");
const rxjs_1 = require("rxjs");
let EventsService = class EventsService {
    bus = new rxjs_1.Subject();
    emit(event) {
        this.bus.next(event);
    }
    streamPublic(channels) {
        return this.bus.pipe((0, rxjs_1.filter)((item) => !item.userId), (0, rxjs_1.filter)((item) => !channels || channels.length === 0 || channels.includes(item.channel)), (0, rxjs_1.map)((item) => ({
            type: item.event,
            data: item,
        })));
    }
    streamUser(userId, channels) {
        return this.bus.pipe((0, rxjs_1.filter)((item) => !item.userId || item.userId === userId), (0, rxjs_1.filter)((item) => !channels || channels.length === 0 || channels.includes(item.channel)), (0, rxjs_1.map)((item) => ({
            type: item.event,
            data: item,
        })));
    }
};
exports.EventsService = EventsService;
exports.EventsService = EventsService = __decorate([
    (0, common_1.Injectable)()
], EventsService);
//# sourceMappingURL=events.service.js.map