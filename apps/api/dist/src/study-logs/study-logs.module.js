"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.StudyLogsModule = void 0;
const common_1 = require("@nestjs/common");
const points_module_1 = require("../points/points.module");
const study_logs_controller_1 = require("./study-logs.controller");
const study_logs_service_1 = require("./study-logs.service");
let StudyLogsModule = class StudyLogsModule {
};
exports.StudyLogsModule = StudyLogsModule;
exports.StudyLogsModule = StudyLogsModule = __decorate([
    (0, common_1.Module)({
        imports: [points_module_1.PointsModule],
        controllers: [study_logs_controller_1.StudyLogsController],
        providers: [study_logs_service_1.StudyLogsService],
        exports: [study_logs_service_1.StudyLogsService],
    })
], StudyLogsModule);
//# sourceMappingURL=study-logs.module.js.map