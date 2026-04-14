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
exports.AttendancesAutomationService = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../database/prisma.service");
const attendances_service_1 = require("./attendances.service");
let AttendancesAutomationService = class AttendancesAutomationService {
    prisma;
    attendancesService;
    constructor(prisma, attendancesService) {
        this.prisma = prisma;
        this.attendancesService = attendancesService;
    }
    async autoCheckout() {
        const policy = await this.prisma.attendancePolicy.findFirst({
            where: { isActive: true, autoCheckoutEnabled: true },
            orderBy: { createdAt: 'desc' },
        });
        if (!policy?.autoCheckoutAfterMinutes) {
            return;
        }
        const cutoff = new Date(Date.now() - policy.autoCheckoutAfterMinutes * 60 * 1000);
        const today = new Date(new Date().toISOString().slice(0, 10));
        const attendances = await this.prisma.attendance.findMany({
            where: {
                attendanceDate: today,
                attendanceStatus: client_1.AttendanceStatus.CHECKED_IN,
                checkInAt: { lte: cutoff },
            },
            select: { studentId: true },
            take: 200,
        });
        for (const attendance of attendances) {
            await this.attendancesService.checkOut(attendance.studentId, true);
        }
    }
};
exports.AttendancesAutomationService = AttendancesAutomationService;
__decorate([
    (0, schedule_1.Cron)('0 */10 * * * *'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AttendancesAutomationService.prototype, "autoCheckout", null);
exports.AttendancesAutomationService = AttendancesAutomationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        attendances_service_1.AttendancesService])
], AttendancesAutomationService);
//# sourceMappingURL=attendances.automation.service.js.map