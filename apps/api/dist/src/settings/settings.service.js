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
exports.SettingsService = void 0;
const common_1 = require("@nestjs/common");
const audit_service_1 = require("../audit/audit.service");
const prisma_service_1 = require("../database/prisma.service");
const events_service_1 = require("../events/events.service");
function stringWithDefault(value, fallback) {
    return typeof value === 'string' && value.length > 0 ? value : fallback;
}
let SettingsService = class SettingsService {
    prisma;
    audit;
    events;
    constructor(prisma, audit, events) {
        this.prisma = prisma;
        this.audit = audit;
        this.events = events;
    }
    getAttendancePolicy() {
        return this.prisma.attendancePolicy
            .findFirst({
            where: { isActive: true },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    updateAttendancePolicy(data, actorUserId) {
        return this.prisma.attendancePolicy
            .create({
            data: {
                policyName: stringWithDefault(data.policyName, 'Default Attendance Policy'),
                lateCutoffTime: stringWithDefault(data.lateCutoffTime, '09:00'),
                earlyLeaveCutoffTime: stringWithDefault(data.earlyLeaveCutoffTime, '22:00'),
                autoCheckoutEnabled: Boolean(data.autoCheckoutEnabled ?? false),
                autoCheckoutAfterMinutes: data.autoCheckoutAfterMinutes !== undefined
                    ? Number(data.autoCheckoutAfterMinutes)
                    : null,
                isActive: true,
                createdById: actorUserId,
            },
        })
            .then(async (created) => {
            await this.audit.log({
                actorUserId,
                actionType: 'ATTENDANCE_POLICY_UPDATED',
                targetType: 'attendance_policy',
                targetId: created.id,
                afterData: created,
            });
            return { success: true, data: created, meta: {} };
        });
    }
    getRankingPolicy() {
        return this.prisma.rankingPolicy
            .findFirst({
            where: { isActive: true },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    getTvDisplay() {
        return this.prisma.tvDisplaySetting
            .findFirst({
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async updateTvDisplay(data, actorUserId) {
        const existing = await this.prisma.tvDisplaySetting.findFirst({
            orderBy: { createdAt: 'desc' },
        });
        const payload = {
            activeScreen: data.activeScreen,
            rotationEnabled: data.rotationEnabled !== undefined
                ? Boolean(data.rotationEnabled)
                : undefined,
            rotationIntervalSeconds: data.rotationIntervalSeconds !== undefined
                ? Number(data.rotationIntervalSeconds)
                : undefined,
            displayOptions: data.displayOptions ?? {
                rankingType: 'STUDY_TIME',
            },
        };
        const record = existing
            ? await this.prisma.tvDisplaySetting.update({
                where: { id: existing.id },
                data: { ...payload, updatedById: actorUserId },
            })
            : await this.prisma.tvDisplaySetting.create({
                data: { ...payload, updatedById: actorUserId },
            });
        await this.audit.log({
            actorUserId,
            actionType: 'TV_DISPLAY_UPDATED',
            targetType: 'tv_display_setting',
            targetId: record.id,
            beforeData: existing,
            afterData: record,
        });
        this.events.emit({
            channel: 'display',
            event: 'display.updated',
            payload: record,
        });
        return { success: true, data: record, meta: {} };
    }
};
exports.SettingsService = SettingsService;
exports.SettingsService = SettingsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        audit_service_1.AuditService,
        events_service_1.EventsService])
], SettingsService);
//# sourceMappingURL=settings.service.js.map