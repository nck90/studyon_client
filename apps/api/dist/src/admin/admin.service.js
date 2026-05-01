"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const audit_service_1 = require("../audit/audit.service");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
function optionalString(value) {
    return typeof value === 'string' && value.length > 0 ? value : undefined;
}
let AdminService = class AdminService {
    prisma;
    audit;
    constructor(prisma, audit) {
        this.prisma = prisma;
        this.audit = audit;
    }
    async dashboard(date, classId, groupId) {
        const targetDate = (0, date_util_1.dateOnly)(date);
        const [checkedInCount, totalSeats, occupiedSeatCount, notCheckedInStudents, notStartedStudyStudents, inactiveStudents,] = await Promise.all([
            this.prisma.attendance.count({
                where: {
                    attendanceDate: targetDate,
                    attendanceStatus: client_1.AttendanceStatus.CHECKED_IN,
                },
            }),
            this.prisma.seat.count({ where: { isActive: true } }),
            this.prisma.seat.count({ where: { status: 'OCCUPIED' } }),
            this.prisma.student.count({
                where: {
                    classId: classId ?? undefined,
                    groupId: groupId ?? undefined,
                    attendances: {
                        none: {
                            attendanceDate: targetDate,
                            attendanceStatus: { in: ['CHECKED_IN', 'CHECKED_OUT'] },
                        },
                    },
                },
            }),
            this.prisma.attendance.count({
                where: {
                    attendanceDate: targetDate,
                    student: {
                        classId: classId ?? undefined,
                        groupId: groupId ?? undefined,
                    },
                    attendanceStatus: { in: ['CHECKED_IN', 'CHECKED_OUT'] },
                    studySessions: { none: {} },
                },
            }),
            this.prisma.studySession.count({
                where: { status: 'PAUSED' },
            }),
        ]);
        return {
            success: true,
            data: {
                checkedInCount,
                seatOccupancyRate: totalSeats === 0
                    ? 0
                    : Number(((occupiedSeatCount / totalSeats) * 100).toFixed(2)),
                availableSeatCount: totalSeats - occupiedSeatCount,
                notCheckedInStudents,
                notStartedStudyStudents,
                inactiveStudents,
            },
            meta: {},
        };
    }
    listStudents(filters) {
        return this.prisma.student
            .findMany({
            where: {
                gradeId: filters.gradeId,
                classId: filters.classId,
                groupId: filters.groupId,
                enrollmentStatus: filters.status,
                OR: filters.keyword
                    ? [
                        {
                            studentNo: { contains: filters.keyword, mode: 'insensitive' },
                        },
                        {
                            user: {
                                name: { contains: filters.keyword, mode: 'insensitive' },
                            },
                        },
                    ]
                    : undefined,
            },
            include: {
                user: true,
                grade: true,
                class: true,
                group: true,
                assignedSeat: true,
            },
            orderBy: { createdAt: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    getStudent(studentId) {
        return this.prisma.student
            .findUnique({
            where: { id: studentId },
            include: {
                user: true,
                grade: true,
                class: true,
                group: true,
                assignedSeat: true,
                attendances: { take: 30, orderBy: { attendanceDate: 'desc' } },
                studyPlans: { take: 20, orderBy: { createdAt: 'desc' } },
                studyLogs: { take: 20, orderBy: { createdAt: 'desc' } },
            },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async createStudent(input) {
        const data = await this.prisma.$transaction(async (tx) => {
            const passwordHash = await bcrypt.hash(input.studentNo, 10);
            const user = await tx.user.create({
                data: { name: input.name, role: client_1.UserRole.STUDENT, status: 'ACTIVE' },
            });
            return tx.student.create({
                data: {
                    userId: user.id,
                    studentNo: input.studentNo,
                    loginId: input.studentNo,
                    passwordHash,
                    gradeId: input.gradeId,
                    classId: input.classId,
                    groupId: input.groupId,
                    assignedSeatId: input.assignedSeatId,
                },
                include: { user: true },
            });
        });
        await this.audit.log({
            actorUserId: input.actorUserId,
            actionType: 'STUDENT_CREATED',
            targetType: 'student',
            targetId: data.id,
            afterData: data,
        });
        return { success: true, data, meta: {} };
    }
    async updateStudent(studentId, body, actorUserId) {
        const before = await this.prisma.student.findUnique({
            where: { id: studentId },
            include: { user: true },
        });
        const data = await this.prisma.student.update({
            where: { id: studentId },
            data: {
                studentNo: optionalString(body.studentNo),
                gradeId: optionalString(body.gradeId),
                classId: optionalString(body.classId),
                groupId: optionalString(body.groupId),
                assignedSeatId: optionalString(body.assignedSeatId),
                memo: optionalString(body.memo),
            },
            include: { user: true },
        });
        if (optionalString(body.name)) {
            await this.prisma.user.update({
                where: { id: data.userId },
                data: { name: optionalString(body.name) },
            });
        }
        await this.audit.log({
            actorUserId,
            actionType: 'STUDENT_UPDATED',
            targetType: 'student',
            targetId: studentId,
            beforeData: before,
            afterData: data,
        });
        return { success: true, data, meta: {} };
    }
    async deleteStudent(studentId, actorUserId) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
        });
        if (!student) {
            return { success: true, data: { deleted: false }, meta: {} };
        }
        await this.prisma.student.update({
            where: { id: studentId },
            data: { enrollmentStatus: 'LEAVE' },
        });
        await this.prisma.user.update({
            where: { id: student.userId },
            data: { status: 'INACTIVE' },
        });
        await this.audit.log({
            actorUserId,
            actionType: 'STUDENT_DELETED',
            targetType: 'student',
            targetId: studentId,
            beforeData: student,
            afterData: { enrollmentStatus: 'LEAVE', userStatus: 'INACTIVE' },
        });
        return { success: true, data: { deleted: true }, meta: {} };
    }
    getStudyOverview(startDate, endDate, classId, groupId) {
        return this.prisma.dailyStudentMetric
            .findMany({
            where: {
                metricDate: {
                    gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                    lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                },
                student: {
                    classId: classId ?? undefined,
                    groupId: groupId ?? undefined,
                },
            },
            include: { student: { include: { user: true, class: true } } },
            orderBy: { metricDate: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    getStudyOverviewSubjects(startDate, endDate, classId, groupId) {
        return this.prisma.studyLog
            .findMany({
            where: {
                logDate: {
                    gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                    lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                },
                student: {
                    classId: classId ?? undefined,
                    groupId: groupId ?? undefined,
                },
            },
            select: {
                subjectName: true,
                studyMinutes: true,
                studySeconds: true,
            },
        })
            .then((items) => {
            const grouped = new Map();
            for (const item of items) {
                const current = grouped.get(item.subjectName) ?? {
                    subjectName: item.subjectName,
                    studyMinutes: 0,
                };
                current.studyMinutes +=
                    item.studyMinutes ?? Math.floor((item.studySeconds ?? 0) / 60);
                grouped.set(item.subjectName, current);
            }
            const data = [...grouped.values()].sort((a, b) => b.studyMinutes - a.studyMinutes);
            return { success: true, data, meta: {} };
        });
    }
    studentStudySummary(studentId) {
        return this.prisma.dailyStudentMetric
            .findMany({
            where: { studentId },
            orderBy: { metricDate: 'desc' },
            take: 30,
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    classStudySummary(classId) {
        return this.prisma.dailyStudentMetric
            .findMany({
            where: { student: { classId } },
            include: { student: { include: { user: true } } },
            orderBy: { metricDate: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    grades() {
        return this.prisma.grade
            .findMany({ orderBy: { sortOrder: 'asc' } })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    createGrade(name, actorUserId) {
        return this.prisma.grade
            .create({
            data: { name, sortOrder: 0 },
        })
            .then(async (data) => {
            await this.audit.log({
                actorUserId,
                actionType: 'GRADE_CREATED',
                targetType: 'grade',
                targetId: data.id,
                afterData: data,
            });
            return { success: true, data, meta: {} };
        });
    }
    classes() {
        return this.prisma.class
            .findMany({ include: { grade: true }, orderBy: { sortOrder: 'asc' } })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    createClass(name, gradeId, actorUserId) {
        return this.prisma.class
            .create({
            data: { name, gradeId, sortOrder: 0 },
        })
            .then(async (data) => {
            await this.audit.log({
                actorUserId,
                actionType: 'CLASS_CREATED',
                targetType: 'class',
                targetId: data.id,
                afterData: data,
            });
            return { success: true, data, meta: {} };
        });
    }
    groups() {
        return this.prisma.group
            .findMany({ include: { class: true }, orderBy: { sortOrder: 'asc' } })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    createGroup(name, classId, actorUserId) {
        return this.prisma.group
            .create({
            data: { name, classId, sortOrder: 0 },
        })
            .then(async (data) => {
            await this.audit.log({
                actorUserId,
                actionType: 'GROUP_CREATED',
                targetType: 'group',
                targetId: data.id,
                afterData: data,
            });
            return { success: true, data, meta: {} };
        });
    }
    auditLogs(actionType, targetType) {
        return this.prisma.adminAuditLog
            .findMany({
            where: {
                actionType: actionType ?? undefined,
                targetType: targetType ?? undefined,
            },
            include: { actor: true },
            orderBy: { createdAt: 'desc' },
            take: 200,
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async directorOverview(startDate, endDate) {
        const [attendances, metrics, activeStudentCount, seats] = await Promise.all([
            this.prisma.attendance.findMany({
                where: {
                    attendanceDate: {
                        gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                        lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                    },
                },
            }),
            this.prisma.dailyStudentMetric.findMany({
                where: {
                    metricDate: {
                        gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                        lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                    },
                },
            }),
            this.prisma.student.count({ where: { enrollmentStatus: 'ACTIVE' } }),
            this.prisma.seat.count({ where: { isActive: true } }),
        ]);
        const checked = attendances.filter((item) => item.attendanceStatus !== client_1.AttendanceStatus.ABSENT).length;
        return {
            success: true,
            data: {
                attendanceRate: attendances.length === 0
                    ? 0
                    : Number(((checked / attendances.length) * 100).toFixed(2)),
                seatUtilizationRate: seats === 0
                    ? 0
                    : Number(((attendances.filter((item) => item.seatId).length / seats) *
                        100).toFixed(2)),
                totalStudyMinutes: metrics.reduce((sum, item) => sum + item.studyMinutes, 0),
                activeStudentCount,
            },
            meta: {},
        };
    }
    operationsReport(periodType, periodKey) {
        return this.getOperationsReport(periodType, periodKey);
    }
    performanceAnalytics(startDate, endDate, classId) {
        return this.prisma.dailyStudentMetric
            .findMany({
            where: {
                metricDate: {
                    gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                    lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                },
                student: { classId: classId ?? undefined },
            },
            include: { student: { include: { user: true, class: true } } },
            orderBy: { studyMinutes: 'desc' },
        })
            .then((data) => ({ success: true, data, meta: {} }));
    }
    async getOperationsReport(periodType, periodKey) {
        const normalizedPeriodType = ['daily', 'weekly', 'monthly'].includes(periodType)
            ? periodType
            : 'monthly';
        const range = this.resolvePeriodRange(normalizedPeriodType, periodKey);
        const [attendances, metrics, seats, classes] = await Promise.all([
            this.prisma.attendance.findMany({
                where: {
                    attendanceDate: { gte: range.start, lte: range.end },
                },
                include: { student: { include: { class: true } } },
            }),
            this.prisma.dailyStudentMetric.findMany({
                where: { metricDate: { gte: range.start, lte: range.end } },
                include: { student: { include: { class: true } } },
            }),
            this.prisma.seat.count({ where: { isActive: true } }),
            this.prisma.class.findMany(),
        ]);
        const attendedCount = attendances.filter((item) => item.attendanceStatus === client_1.AttendanceStatus.CHECKED_IN ||
            item.attendanceStatus === client_1.AttendanceStatus.CHECKED_OUT).length;
        const attendanceRate = attendances.length === 0
            ? 0
            : Number(((attendedCount / attendances.length) * 100).toFixed(2));
        const totalStudyMinutes = metrics.reduce((sum, item) => sum + item.studyMinutes, 0);
        const avgDailyStudyMinutes = metrics.length === 0
            ? 0
            : Number((totalStudyMinutes / metrics.length).toFixed(2));
        const seatUsageCount = attendances.filter((item) => item.seatId).length;
        const seatUtilizationRate = seats === 0 ? 0 : Number(((seatUsageCount / seats) * 100).toFixed(2));
        const classStats = classes.map((klass) => {
            const classMetrics = metrics.filter((metric) => metric.student.classId === klass.id);
            return {
                classId: klass.id,
                className: klass.name,
                totalStudyMinutes: classMetrics.reduce((sum, metric) => sum + metric.studyMinutes, 0),
                achievedRate: classMetrics.length === 0
                    ? 0
                    : Number((classMetrics.reduce((sum, metric) => sum + Number(metric.achievedRate), 0) / classMetrics.length).toFixed(2)),
            };
        });
        classStats.sort((a, b) => b.totalStudyMinutes - a.totalStudyMinutes);
        return {
            success: true,
            data: {
                periodType: normalizedPeriodType,
                periodKey: range.label,
                generatedAt: new Date().toISOString(),
                attendanceRate,
                seatUtilizationRate,
                totalStudyMinutes,
                avgDailyStudyMinutes,
                topClasses: classStats.slice(0, 5),
            },
            meta: {},
        };
    }
    resolvePeriodRange(periodType, periodKey) {
        if (periodType === 'daily') {
            const base = (0, date_util_1.startOfDay)(periodKey ?? new Date());
            return {
                start: base,
                end: (0, date_util_1.endOfDay)(base),
                label: base.toISOString().slice(0, 10),
            };
        }
        if (periodType === 'weekly') {
            const base = (0, date_util_1.weekStart)(periodKey ?? new Date());
            return {
                start: base,
                end: (0, date_util_1.endOfDay)(new Date(base.getFullYear(), base.getMonth(), base.getDate() + 6)),
                label: base.toISOString().slice(0, 10),
            };
        }
        const key = periodKey ?? (0, date_util_1.monthKey)();
        const [year, monthNumber] = key.split('-').map(Number);
        const start = (0, date_util_1.startOfDay)(new Date(year, monthNumber - 1, 1));
        return {
            start,
            end: (0, date_util_1.endOfDay)(new Date(year, monthNumber, 0)),
            label: key,
        };
    }
};
exports.AdminService = AdminService;
exports.AdminService = AdminService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        audit_service_1.AuditService])
], AdminService);
//# sourceMappingURL=admin.service.js.map