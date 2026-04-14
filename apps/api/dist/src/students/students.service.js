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
exports.StudentsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../database/prisma.service");
const date_util_1 = require("../common/utils/date.util");
let StudentsService = class StudentsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getStudentHome(studentId) {
        const today = (0, date_util_1.dateOnly)();
        const [student, attendance, activeSession, plans, notifications] = await Promise.all([
            this.prisma.student.findUnique({
                where: { id: studentId },
                include: { user: true, assignedSeat: true, class: true },
            }),
            this.prisma.attendance.findUnique({
                where: {
                    studentId_attendanceDate: { studentId, attendanceDate: today },
                },
            }),
            this.prisma.studySession.findFirst({
                where: { studentId, status: { in: ['ACTIVE', 'PAUSED'] } },
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.studyPlan.findMany({
                where: { studentId, planDate: today },
            }),
            this.prisma.notificationReceipt.findMany({
                where: { user: { student: { id: studentId } } },
                include: { notification: true },
                take: 5,
                orderBy: { createdAt: 'desc' },
            }),
        ]);
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        return {
            success: true,
            data: {
                todayAttendance: attendance,
                seat: student.assignedSeat
                    ? {
                        seatId: student.assignedSeat.id,
                        seatNo: student.assignedSeat.seatNo,
                        status: student.assignedSeat.status,
                    }
                    : null,
                study: activeSession,
                plans: {
                    totalCount: plans.length,
                    completedCount: plans.filter((item) => item.status === 'COMPLETED')
                        .length,
                    targetMinutes: plans.reduce((sum, item) => sum + item.targetMinutes, 0),
                },
                notifications: notifications.map((receipt) => ({
                    id: receipt.notification.id,
                    title: receipt.notification.title,
                    body: receipt.notification.body,
                    readAt: receipt.readAt,
                })),
                student: {
                    id: student.id,
                    name: student.user.name,
                    studentNo: student.studentNo,
                    className: student.class?.name ?? null,
                },
            },
            meta: {},
        };
    }
    async getProfile(studentId) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
            include: {
                user: true,
                class: true,
                group: true,
                grade: true,
                assignedSeat: true,
            },
        });
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        return { success: true, data: student, meta: {} };
    }
    async getBadges(studentId) {
        const badges = await this.prisma.studentBadge.findMany({
            where: { studentId },
            include: { badge: true },
            orderBy: { awardedAt: 'desc' },
        });
        return { success: true, data: badges, meta: {} };
    }
};
exports.StudentsService = StudentsService;
exports.StudentsService = StudentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StudentsService);
//# sourceMappingURL=students.service.js.map