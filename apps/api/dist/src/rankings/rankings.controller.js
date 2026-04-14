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
exports.RankingsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const roles_decorator_1 = require("../common/decorators/roles.decorator");
const prisma_service_1 = require("../database/prisma.service");
const rankings_service_1 = require("./rankings.service");
function optionalString(value) {
    return typeof value === 'string' && value.length > 0 ? value : undefined;
}
let RankingsController = class RankingsController {
    rankingsService;
    prisma;
    constructor(rankingsService, prisma) {
        this.rankingsService = rankingsService;
        this.prisma = prisma;
    }
    studentRankings(user, periodType = client_1.RankingPeriodType.DAILY, rankingType = client_1.RankingType.STUDY_TIME) {
        return this.rankingsService.studentRanking(user.studentId, periodType, rankingType);
    }
    adminRankings(periodType = client_1.RankingPeriodType.DAILY, rankingType = client_1.RankingType.STUDY_TIME) {
        return this.rankingsService.adminRanking(periodType, rankingType);
    }
    getActivePolicy() {
        return this.prisma.rankingPolicy
            .findFirst({
            where: { isActive: true },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    createPolicy(body) {
        return this.prisma.rankingPolicy
            .create({
            data: {
                policyName: optionalString(body.policyName) ?? 'Default Policy',
                studyTimeWeight: Number(body.studyTimeWeight ?? 1),
                studyVolumeWeight: Number(body.studyVolumeWeight ?? 1),
                attendanceWeight: Number(body.attendanceWeight ?? 1),
                tieBreakerRule: body.tieBreakerRule ?? { order: ['score'] },
            },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    patchPolicy(policyId, body) {
        return this.prisma.rankingPolicy
            .update({
            where: { id: policyId },
            data: {
                policyName: optionalString(body.policyName),
                studyTimeWeight: body.studyTimeWeight !== undefined
                    ? Number(body.studyTimeWeight)
                    : undefined,
                studyVolumeWeight: body.studyVolumeWeight !== undefined
                    ? Number(body.studyVolumeWeight)
                    : undefined,
                attendanceWeight: body.attendanceWeight !== undefined
                    ? Number(body.attendanceWeight)
                    : undefined,
                tieBreakerRule: body.tieBreakerRule,
            },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
};
exports.RankingsController = RankingsController;
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.STUDENT),
    (0, common_1.Get)('student/rankings'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('periodType')),
    __param(2, (0, common_1.Query)('rankingType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], RankingsController.prototype, "studentRankings", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/rankings'),
    __param(0, (0, common_1.Query)('periodType')),
    __param(1, (0, common_1.Query)('rankingType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], RankingsController.prototype, "adminRankings", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN, client_1.UserRole.DIRECTOR),
    (0, common_1.Get)('admin/ranking-policies/active'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], RankingsController.prototype, "getActivePolicy", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.DIRECTOR),
    (0, common_1.Post)('admin/ranking-policies'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], RankingsController.prototype, "createPolicy", null);
__decorate([
    (0, roles_decorator_1.Roles)(client_1.UserRole.DIRECTOR),
    (0, common_1.Patch)('admin/ranking-policies/:policyId'),
    __param(0, (0, common_1.Param)('policyId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], RankingsController.prototype, "patchPolicy", null);
exports.RankingsController = RankingsController = __decorate([
    (0, swagger_1.ApiTags)('rankings'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Controller)({ version: '1' }),
    __metadata("design:paramtypes", [rankings_service_1.RankingsService,
        prisma_service_1.PrismaService])
], RankingsController);
//# sourceMappingURL=rankings.controller.js.map