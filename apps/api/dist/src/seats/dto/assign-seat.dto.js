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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AssignSeatDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class AssignSeatDto {
    studentId;
    assignmentType;
}
exports.AssignSeatDto = AssignSeatDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], AssignSeatDto.prototype, "studentId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: client_1.SeatAssignmentType }),
    (0, class_validator_1.IsEnum)(client_1.SeatAssignmentType),
    __metadata("design:type", String)
], AssignSeatDto.prototype, "assignmentType", void 0);
//# sourceMappingURL=assign-seat.dto.js.map