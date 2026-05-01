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
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../database/prisma.service");
const date_util_1 = require("../common/utils/date.util");
let StudentsService = class StudentsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getStudentHome(studentId) {
        const today = (0, date_util_1.dateOnly)();
        const [student, attendance, activeSession, plans, notifications, dailyMetric, checkedInStudentCount, totalActiveStudents,] = await Promise.all([
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
            this.prisma.dailyStudentMetric.findUnique({
                where: {
                    studentId_metricDate: { studentId, metricDate: today },
                },
            }),
            this.prisma.attendance.count({
                where: {
                    attendanceDate: today,
                    attendanceStatus: client_1.AttendanceStatus.CHECKED_IN,
                    student: {
                        enrollmentStatus: 'ACTIVE',
                        user: { status: 'ACTIVE' },
                    },
                },
            }),
            this.prisma.student.count({
                where: {
                    enrollmentStatus: 'ACTIVE',
                    user: { status: 'ACTIVE' },
                },
            }),
        ]);
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        return {
            success: true,
            data: {
                todayAttendance: attendance
                    ? {
                        status: attendance.attendanceStatus,
                        checkInAt: attendance.checkInAt?.toISOString() ?? null,
                        checkOutAt: attendance.checkOutAt?.toISOString() ?? null,
                        stayMinutes: attendance.stayMinutes,
                    }
                    : {
                        status: client_1.AttendanceStatus.NOT_CHECKED_IN,
                        checkInAt: null,
                        checkOutAt: null,
                        stayMinutes: 0,
                    },
                seat: student.assignedSeat
                    ? {
                        seatId: student.assignedSeat.id,
                        seatNo: student.assignedSeat.seatNo,
                        status: student.assignedSeat.status,
                    }
                    : null,
                study: activeSession
                    ? {
                        sessionStatus: activeSession.status,
                        studyMinutes: activeSession.studyMinutes,
                        breakMinutes: activeSession.breakMinutes,
                    }
                    : {
                        sessionStatus: client_1.StudySessionStatus.READY,
                        studyMinutes: 0,
                        breakMinutes: 0,
                    },
                plans: {
                    totalCount: plans.length,
                    completedCount: plans.filter((item) => item.status === 'COMPLETED')
                        .length,
                    targetMinutes: plans.reduce((sum, item) => sum + item.targetMinutes, 0),
                },
                notifications: notifications.map((receipt) => ({
                    id: receipt.notification.id,
                    title: receipt.notification.title,
                })),
                streakDays: dailyMetric?.streakDays ?? 0,
                community: {
                    checkedInStudentCount,
                    totalActiveStudents,
                },
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
        const [student, sessionAggregate, completedPlansCount, badgeCount, latestMetric,] = await Promise.all([
            this.prisma.student.findUnique({
                where: { id: studentId },
                include: {
                    user: true,
                    class: true,
                    group: true,
                    grade: true,
                    assignedSeat: true,
                },
            }),
            this.prisma.studySession.aggregate({
                where: { studentId },
                _sum: { studySeconds: true },
            }),
            this.prisma.studyPlan.count({
                where: { studentId, status: 'COMPLETED' },
            }),
            this.prisma.studentBadge.count({
                where: { studentId },
            }),
            this.prisma.dailyStudentMetric.findFirst({
                where: { studentId },
                orderBy: { metricDate: 'desc' },
                select: { streakDays: true },
            }),
        ]);
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        const preferences = await this.getStudentPreferences(studentId);
        const totalStudySeconds = sessionAggregate._sum.studySeconds ?? 0;
        const totalStudyMinutes = Math.floor(totalStudySeconds / 60);
        const streakDays = latestMetric?.streakDays ?? 0;
        const totalPoints = totalStudyMinutes +
            completedPlansCount * 50 +
            badgeCount * 100 +
            streakDays * 10;
        const level = totalPoints >= 6000
            ? 4
            : totalPoints >= 3000
                ? 3
                : totalPoints >= 1000
                    ? 2
                    : 1;
        return {
            success: true,
            data: {
                ...student,
                preferences,
                profileStats: {
                    totalStudySeconds,
                    totalStudyMinutes,
                    totalPoints,
                    level,
                    completedPlansCount,
                    badgeCount,
                    streakDays,
                },
            },
            meta: {},
        };
    }
    async getBadges(studentId) {
        const badges = await this.prisma.studentBadge.findMany({
            where: { studentId },
            include: { badge: true },
            orderBy: { awardedAt: 'desc' },
        });
        return { success: true, data: badges, meta: {} };
    }
    async getPreferences(studentId) {
        const data = await this.getStudentPreferences(studentId);
        return { success: true, data, meta: {} };
    }
    async updatePreferences(studentId, input) {
        const current = await this.getStudentPreferences(studentId);
        const next = {
            notificationEnabled: input.notificationEnabled ?? current.notificationEnabled,
        };
        const key = this.preferenceKey(studentId);
        const existing = await this.prisma.appSetting.findUnique({
            where: { settingKey: key },
        });
        await (existing
            ? this.prisma.appSetting.update({
                where: { settingKey: key },
                data: { settingValue: next },
            })
            : this.prisma.appSetting.create({
                data: { settingKey: key, settingValue: next },
            }));
        return { success: true, data: next, meta: {} };
    }
    async getStudentPreferences(studentId) {
        const setting = await this.prisma.appSetting.findUnique({
            where: { settingKey: this.preferenceKey(studentId) },
        });
        const value = setting?.settingValue ?? {};
        return {
            notificationEnabled: value.notificationEnabled !== false,
        };
    }
    preferenceKey(studentId) {
        return `student:${studentId}:preferences`;
    }
};
exports.StudentsService = StudentsService;
exports.StudentsService = StudentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StudentsService);
//# sourceMappingURL=students.service.js.map