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
const crypto_1 = require("crypto");
const audit_service_1 = require("../audit/audit.service");
const date_util_1 = require("../common/utils/date.util");
const prisma_service_1 = require("../database/prisma.service");
const notifications_service_1 = require("../notifications/notifications.service");
function optionalString(value) {
    return typeof value === 'string' && value.length > 0 ? value : undefined;
}
function stringList(value, fallback) {
    const source = Array.isArray(value) ? value : fallback;
    if (!Array.isArray(source))
        return [];
    return source
        .filter((item) => typeof item === 'string')
        .map((item) => item.trim())
        .filter(Boolean);
}
let AdminService = class AdminService {
    prisma;
    audit;
    notifications;
    constructor(prisma, audit, notifications) {
        this.prisma = prisma;
        this.audit = audit;
        this.notifications = notifications;
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
    async getBadgeRules() {
        const rules = await this.prisma.badgeRule.findMany({
            include: { badge: true },
            orderBy: [{ isActive: 'desc' }, { createdAt: 'asc' }],
        });
        return { success: true, data: rules, meta: {} };
    }
    async updateBadgeRules(rules) {
        if (!Array.isArray(rules)) {
            throw new common_1.BadRequestException('배지 규칙 목록이 필요합니다.');
        }
        const saved = [];
        for (const rule of rules) {
            if (!Object.values(client_1.BadgeRuleMetric).includes(rule.metric)) {
                throw new common_1.BadRequestException('지원하지 않는 배지 지표입니다.');
            }
            if (!Number.isInteger(rule.threshold) || rule.threshold < 1) {
                throw new common_1.BadRequestException('배지 기준값은 1 이상이어야 합니다.');
            }
            const data = {
                badgeId: rule.badgeId,
                metric: rule.metric,
                threshold: rule.threshold,
                windowDays: rule.windowDays ?? null,
                isActive: rule.isActive ?? true,
            };
            saved.push(rule.id
                ? await this.prisma.badgeRule.update({
                    where: { id: rule.id },
                    data,
                    include: { badge: true },
                })
                : await this.prisma.badgeRule.create({
                    data,
                    include: { badge: true },
                }));
        }
        return { success: true, data: saved, meta: {} };
    }
    async getFocusPolicy() {
        const policy = await this.ensureFocusPolicy();
        return { success: true, data: policy, meta: {} };
    }
    async updateFocusPolicy(input) {
        const current = await this.ensureFocusPolicy();
        if (input.mode && !Object.values(client_1.FocusPolicyMode).includes(input.mode)) {
            throw new common_1.BadRequestException('지원하지 않는 집중모드입니다.');
        }
        if (input.policyName !== undefined &&
            input.policyName.trim().length === 0) {
            throw new common_1.BadRequestException('정책 이름이 필요합니다.');
        }
        const policy = await this.prisma.focusPolicy.update({
            where: { id: current.id },
            data: {
                policyName: input.policyName?.trim() ?? current.policyName,
                mode: input.mode ?? current.mode,
                isEnabled: input.isEnabled ?? current.isEnabled,
                blockedPackages: stringList(input.blockedPackages, current.blockedPackages),
                allowedPackages: stringList(input.allowedPackages, current.allowedPackages),
                graceSeconds: this.policyInt(input.graceSeconds, current.graceSeconds),
                opsQueueThreshold: this.policyInt(input.opsQueueThreshold, current.opsQueueThreshold),
                parentReportThreshold: this.policyInt(input.parentReportThreshold, current.parentReportThreshold),
            },
        });
        return { success: true, data: policy, meta: {} };
    }
    async focusOverview(date) {
        const targetDate = (0, date_util_1.dateOnly)(date);
        const policy = await this.ensureFocusPolicy();
        const [totalStudying, metrics, highRiskCount, eventCount] = await Promise.all([
            this.prisma.studySession.count({
                where: { sessionDate: targetDate, status: 'ACTIVE' },
            }),
            this.prisma.studentFocusMetric.findMany({
                where: { metricDate: targetDate },
            }),
            this.prisma.studentFocusMetric.count({
                where: {
                    metricDate: targetDate,
                    eventCount: { gte: policy.parentReportThreshold },
                },
            }),
            this.prisma.studentFocusEvent.count({
                where: { eventDate: targetDate },
            }),
        ]);
        const exitStudents = metrics.filter((item) => item.eventCount > 0);
        const totalReturns = metrics.reduce((sum, item) => sum + item.returnCount, 0);
        const totalAway = metrics.reduce((sum, item) => sum + item.totalAwaySeconds, 0);
        return {
            success: true,
            data: {
                metricDate: targetDate.toISOString(),
                totalStudyingCount: totalStudying,
                exitStudentCount: exitStudents.length,
                highRiskStudentCount: highRiskCount,
                eventCount,
                protectionRate: metrics.length === 0
                    ? 100
                    : Number((((metrics.length - exitStudents.length) / metrics.length) *
                        100).toFixed(1)),
                averageReturnSeconds: totalReturns === 0 ? 0 : Math.round(totalAway / totalReturns),
                policy,
            },
            meta: {},
        };
    }
    async focusStudents(filters) {
        const targetDate = (0, date_util_1.dateOnly)(filters.date);
        const policy = await this.ensureFocusPolicy();
        const students = await this.prisma.student.findMany({
            where: {
                classId: filters.classId,
                enrollmentStatus: 'ACTIVE',
                user: { status: 'ACTIVE' },
            },
            include: {
                user: true,
                class: true,
                grade: true,
                focusMetrics: { where: { metricDate: targetDate }, take: 1 },
                studySessions: {
                    where: {
                        sessionDate: targetDate,
                        status: { in: ['ACTIVE', 'PAUSED'] },
                    },
                    orderBy: { updatedAt: 'desc' },
                    take: 1,
                },
            },
            orderBy: [{ class: { name: 'asc' } }, { user: { name: 'asc' } }],
        });
        const rows = students.map((student) => {
            const metric = student.focusMetrics[0] ?? null;
            const session = student.studySessions[0] ?? null;
            const status = (metric?.eventCount ?? 0) >= policy.parentReportThreshold
                ? 'HIGH_RISK'
                : (metric?.eventCount ?? 0) >= policy.opsQueueThreshold
                    ? 'NEEDS_ATTENTION'
                    : session?.status === 'ACTIVE'
                        ? 'FOCUSING'
                        : session?.status === 'PAUSED'
                            ? 'BREAK'
                            : 'IDLE';
            const avgReturnSeconds = metric && metric.returnCount > 0
                ? Math.round(metric.totalAwaySeconds / metric.returnCount)
                : 0;
            return {
                studentId: student.id,
                studentName: student.user.name,
                studentNo: student.studentNo,
                className: student.class?.name ?? null,
                gradeName: student.grade?.name ?? null,
                status,
                activeSessionId: session?.id ?? null,
                eventCount: metric?.eventCount ?? 0,
                returnCount: metric?.returnCount ?? 0,
                totalAwaySeconds: metric?.totalAwaySeconds ?? 0,
                longestAwaySeconds: metric?.longestAwaySeconds ?? 0,
                averageReturnSeconds: avgReturnSeconds,
                lastEventAt: metric?.lastEventAt?.toISOString() ?? null,
            };
        });
        const filtered = filters.status && filters.status !== 'ALL'
            ? rows.filter((row) => row.status === filters.status)
            : rows;
        return { success: true, data: filtered, meta: {} };
    }
    async focusEvents(filters) {
        const targetDate = (0, date_util_1.dateOnly)(filters.date);
        const data = await this.prisma.studentFocusEvent.findMany({
            where: {
                eventDate: targetDate,
                studentId: filters.studentId,
            },
            include: { student: { include: { user: true, class: true } } },
            orderBy: { occurredAt: 'desc' },
            take: 100,
        });
        return {
            success: true,
            data: data.map((event) => ({
                id: event.id,
                studentId: event.studentId,
                studentName: event.student.user.name,
                className: event.student.class?.name ?? null,
                eventType: event.eventType,
                occurredAt: event.occurredAt.toISOString(),
                durationSeconds: event.durationSeconds ?? null,
                studySessionId: event.studySessionId ?? null,
            })),
            meta: {},
        };
    }
    async retentionOverview() {
        const today = (0, date_util_1.startOfDay)();
        const week = (0, date_util_1.weekStart)(today);
        const activeGroups = await this.prisma.studySession.groupBy({
            by: ['studentId'],
            where: { sessionDate: { gte: week, lte: today } },
            _count: { id: true },
        });
        const weeklyActiveStudents = activeGroups.filter((item) => item._count.id >= 3).length;
        const [plansTotal, plansCompleted, focusMetrics, pendingGoals, openInterventions,] = await Promise.all([
            this.prisma.studyPlan.count({
                where: { planDate: { gte: week, lte: today } },
            }),
            this.prisma.studyPlan.count({
                where: {
                    planDate: { gte: week, lte: today },
                    status: 'COMPLETED',
                },
            }),
            this.prisma.studentFocusMetric.findMany({
                where: { metricDate: { gte: week, lte: today } },
                include: { student: { include: { user: true, class: true } } },
                orderBy: [{ eventCount: 'desc' }],
                take: 10,
            }),
            this.goalPreferenceRows('PENDING'),
            this.prisma.interventionQueueItem.count({ where: { status: 'OPEN' } }),
        ]);
        return {
            success: true,
            data: {
                weeklyActiveStudents,
                planAchievedRate: plansTotal === 0
                    ? 0
                    : Number(((plansCompleted / plansTotal) * 100).toFixed(1)),
                focusEventCount: focusMetrics.reduce((sum, item) => sum + item.eventCount, 0),
                pendingGoalApprovalCount: pendingGoals.length,
                openInterventionCount: openInterventions,
                focusRiskStudents: focusMetrics.map((metric) => ({
                    studentId: metric.studentId,
                    studentName: metric.student.user.name,
                    className: metric.student.class?.name ?? null,
                    eventCount: metric.eventCount,
                    lastEventAt: metric.lastEventAt?.toISOString() ?? null,
                })),
            },
            meta: {},
        };
    }
    async opsOverview(date) {
        const taskDate = (0, date_util_1.dateOnly)(date);
        const [total, open, resolved, dismissed, high, parentReports] = await Promise.all([
            this.prisma.opsTask.count({ where: { taskDate } }),
            this.prisma.opsTask.count({ where: { taskDate, status: 'OPEN' } }),
            this.prisma.opsTask.count({ where: { taskDate, status: 'RESOLVED' } }),
            this.prisma.opsTask.count({ where: { taskDate, status: 'DISMISSED' } }),
            this.prisma.opsTask.count({
                where: { taskDate, status: 'OPEN', severity: 'HIGH' },
            }),
            this.prisma.parentActionReport.count({
                where: { task: { taskDate } },
            }),
        ]);
        const completed = resolved + dismissed;
        return {
            success: true,
            data: {
                taskDate: taskDate.toISOString(),
                totalCount: total,
                openCount: open,
                resolvedCount: resolved,
                dismissedCount: dismissed,
                highSeverityOpenCount: high,
                parentReportCount: parentReports,
                completionRate: total === 0 ? 0 : Number(((completed / total) * 100).toFixed(1)),
            },
            meta: {},
        };
    }
    async generateOpsTasks() {
        const today = (0, date_util_1.dateOnly)();
        const policy = await this.ensureFocusPolicy();
        const students = await this.prisma.student.findMany({
            where: { enrollmentStatus: 'ACTIVE', user: { status: 'ACTIVE' } },
            include: {
                user: true,
                class: true,
                attendances: { where: { attendanceDate: today }, take: 1 },
                dailyMetrics: { where: { metricDate: today }, take: 1 },
                focusMetrics: { where: { metricDate: today }, take: 1 },
                dailyMissions: { where: { missionDate: today }, take: 1 },
            },
            take: 1000,
        });
        const data = [];
        for (const student of students) {
            const attendance = student.attendances[0] ?? null;
            const metric = student.dailyMetrics[0] ?? null;
            const focus = student.focusMetrics[0] ?? null;
            const mission = student.dailyMissions[0] ?? null;
            const name = student.user.name;
            if (!attendance ||
                attendance.attendanceStatus === 'NOT_CHECKED_IN' ||
                attendance.attendanceStatus === 'ABSENT') {
                data.push(this.opsTaskRow(student.id, today, 'NOT_CHECKED_IN', 'MEDIUM', `${name} 학생이 아직 입실하지 않았습니다.`, { attendanceStatus: attendance?.attendanceStatus ?? null }));
            }
            if (attendance?.earlyLeaveStatus === 'EARLY_LEAVE' ||
                (attendance?.attendanceStatus === 'CHECKED_OUT' &&
                    attendance.stayMinutes > 0 &&
                    attendance.stayMinutes < 180)) {
                data.push(this.opsTaskRow(student.id, today, 'EARLY_LEAVE', 'MEDIUM', `${name} 학생이 조기 퇴실했습니다.`, {
                    stayMinutes: attendance.stayMinutes,
                    earlyLeaveStatus: attendance.earlyLeaveStatus,
                }));
            }
            if (mission && mission.status !== 'COMPLETED') {
                data.push(this.opsTaskRow(student.id, today, 'DAILY_MISSION_INCOMPLETE', 'LOW', `${name} 학생의 오늘 데일리 미션이 아직 완료되지 않았습니다.`, {
                    missionId: mission.id,
                    missionTitle: mission.title,
                    missionStatus: mission.status,
                }));
            }
            if (metric && Number(metric.achievedRate) < 70) {
                data.push(this.opsTaskRow(student.id, today, 'TARGET_SHORTFALL', 'HIGH', `${name} 학생의 오늘 목표 달성률이 70% 미만입니다.`, {
                    achievedRate: Number(metric.achievedRate),
                    studyMinutes: metric.studyMinutes,
                    targetMinutes: metric.targetMinutes,
                }));
            }
            if (focus && focus.eventCount >= policy.opsQueueThreshold) {
                data.push(this.opsTaskRow(student.id, today, 'FOCUS_INTERRUPTION', focus.eventCount >= policy.parentReportThreshold
                    ? 'HIGH'
                    : 'MEDIUM', `${name} 학생의 집중 이탈이 오늘 ${focus.eventCount}회 기록됐습니다.`, {
                    eventCount: focus.eventCount,
                    averageReturnSeconds: focus.returnCount > 0
                        ? Math.round(focus.totalAwaySeconds / focus.returnCount)
                        : 0,
                    totalAwaySeconds: focus.totalAwaySeconds,
                    lastEventAt: focus.lastEventAt?.toISOString() ?? null,
                }));
            }
        }
        if (data.length > 0) {
            await this.prisma.opsTask.createMany({ data, skipDuplicates: true });
        }
        return this.opsTasks({ date: today.toISOString(), status: 'OPEN' });
    }
    async opsTasks(filters) {
        const taskDate = (0, date_util_1.dateOnly)(filters.date);
        const rows = await this.prisma.opsTask.findMany({
            where: {
                taskDate,
                status: this.opsTaskStatus(filters.status),
                reasonType: this.opsTaskReasonType(filters.reasonType),
                severity: this.opsTaskSeverity(filters.severity),
            },
            include: this.opsTaskInclude(),
            orderBy: [{ status: 'asc' }, { severity: 'desc' }, { createdAt: 'desc' }],
            take: 200,
        });
        return {
            success: true,
            data: rows.map((row) => this.serializeOpsTask(row)),
            meta: {},
        };
    }
    async sendOpsStudentMessage(taskId, actorUserId, message) {
        const task = await this.findOpenOpsTask(taskId);
        const body = message?.trim() || task.message;
        await this.notifications.sendDirectToUsers({
            userIds: [task.student.userId],
            notificationType: client_1.NotificationType.NOTICE,
            channel: client_1.NotificationChannel.IN_APP,
            title: '오늘 학습 점검',
            body,
        });
        await this.prisma.opsTaskAction.create({
            data: {
                taskId,
                actorUserId,
                actionType: 'STUDENT_MESSAGE_SENT',
                payload: { message: body },
            },
        });
        return this.opsTaskResponse(taskId);
    }
    async createOpsParentReport(taskId, actorUserId, message) {
        const task = await this.findOpenOpsTask(taskId);
        const body = message?.trim() || task.message;
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 30);
        const report = await this.prisma.parentActionReport.create({
            data: {
                taskId,
                studentId: task.studentId,
                tokenId: (0, crypto_1.randomBytes)(24).toString('hex'),
                message: body,
                expiresAt,
            },
        });
        await this.prisma.opsTaskAction.create({
            data: {
                taskId,
                actorUserId,
                actionType: 'PARENT_REPORT_CREATED',
                payload: { reportId: report.id, tokenId: report.tokenId },
            },
        });
        return {
            success: true,
            data: {
                report: {
                    id: report.id,
                    tokenId: report.tokenId,
                    message: report.message,
                    expiresAt: report.expiresAt.toISOString(),
                    createdAt: report.createdAt.toISOString(),
                },
                urlPath: `/parent/action-report?token=${report.tokenId}`,
            },
            meta: {},
        };
    }
    async resolveOpsTask(taskId, actorUserId) {
        await this.findOpenOpsTask(taskId);
        await this.prisma.opsTask.update({
            where: { id: taskId },
            data: {
                status: 'RESOLVED',
                resolvedById: actorUserId,
                resolvedAt: new Date(),
            },
        });
        await this.prisma.opsTaskAction.create({
            data: { taskId, actorUserId, actionType: 'RESOLVED', payload: {} },
        });
        return this.opsTaskResponse(taskId);
    }
    async dismissOpsTask(taskId, actorUserId) {
        await this.findOpenOpsTask(taskId);
        await this.prisma.opsTask.update({
            where: { id: taskId },
            data: { status: 'DISMISSED' },
        });
        await this.prisma.opsTaskAction.create({
            data: { taskId, actorUserId, actionType: 'DISMISSED', payload: {} },
        });
        return this.opsTaskResponse(taskId);
    }
    async parentCrmOverview() {
        const today = (0, date_util_1.startOfDay)();
        const [openFollowUps, overdueFollowUps, todayFollowUps, guardians, recent] = await Promise.all([
            this.prisma.parentFollowUpTask.count({ where: { status: 'OPEN' } }),
            this.prisma.parentFollowUpTask.count({
                where: { status: 'OPEN', dueAt: { lt: today } },
            }),
            this.prisma.parentFollowUpTask.count({
                where: {
                    status: 'OPEN',
                    dueAt: { gte: today, lte: (0, date_util_1.endOfDay)(today) },
                },
            }),
            this.prisma.guardian.count(),
            this.prisma.parentConsultation.findMany({
                include: {
                    student: { include: { user: true, class: true, grade: true } },
                    guardian: true,
                    createdBy: true,
                    followUps: { orderBy: { dueAt: 'asc' }, take: 3 },
                    reports: { orderBy: { createdAt: 'desc' }, take: 1 },
                },
                orderBy: { occurredAt: 'desc' },
                take: 10,
            }),
        ]);
        return {
            success: true,
            data: {
                openFollowUpCount: openFollowUps,
                overdueFollowUpCount: overdueFollowUps,
                todayFollowUpCount: todayFollowUps,
                guardianCount: guardians,
                recentConsultations: recent.map((item) => this.serializeParentConsultation(item)),
            },
            meta: {},
        };
    }
    async parentGuardians(filters) {
        const data = await this.prisma.guardian.findMany({
            where: {
                studentId: filters.studentId,
                OR: filters.keyword
                    ? [
                        { name: { contains: filters.keyword, mode: 'insensitive' } },
                        { phone: { contains: filters.keyword, mode: 'insensitive' } },
                        {
                            student: {
                                user: {
                                    name: { contains: filters.keyword, mode: 'insensitive' },
                                },
                            },
                        },
                    ]
                    : undefined,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
            },
            orderBy: [{ isPrimary: 'desc' }, { createdAt: 'desc' }],
            take: 100,
        });
        return {
            success: true,
            data: data.map((item) => this.serializeGuardian(item)),
            meta: {},
        };
    }
    async createParentGuardian(input) {
        if (!input.studentId || !input.name?.trim()) {
            throw new common_1.BadRequestException('학생과 보호자 이름이 필요합니다.');
        }
        if (input.isPrimary) {
            await this.prisma.guardian.updateMany({
                where: { studentId: input.studentId },
                data: { isPrimary: false },
            });
        }
        const data = await this.prisma.guardian.create({
            data: {
                studentId: input.studentId,
                name: input.name.trim(),
                relation: this.guardianRelation(input.relation),
                phone: input.phone?.trim() || null,
                email: input.email?.trim() || null,
                isPrimary: input.isPrimary ?? false,
                memo: input.memo?.trim() || null,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
            },
        });
        return { success: true, data: this.serializeGuardian(data), meta: {} };
    }
    async updateParentGuardian(guardianId, input) {
        const current = await this.prisma.guardian.findUnique({
            where: { id: guardianId },
        });
        if (!current) {
            throw new common_1.BadRequestException('보호자를 찾을 수 없습니다.');
        }
        if (input.isPrimary) {
            await this.prisma.guardian.updateMany({
                where: { studentId: current.studentId, id: { not: guardianId } },
                data: { isPrimary: false },
            });
        }
        const data = await this.prisma.guardian.update({
            where: { id: guardianId },
            data: {
                name: input.name?.trim(),
                relation: input.relation
                    ? this.guardianRelation(input.relation)
                    : undefined,
                phone: input.phone === undefined ? undefined : input.phone?.trim() || null,
                email: input.email === undefined ? undefined : input.email?.trim() || null,
                isPrimary: input.isPrimary,
                memo: input.memo === undefined ? undefined : input.memo?.trim() || null,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
            },
        });
        return { success: true, data: this.serializeGuardian(data), meta: {} };
    }
    async parentConsultations(filters) {
        const data = await this.prisma.parentConsultation.findMany({
            where: {
                studentId: filters.studentId,
                guardianId: filters.guardianId,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
                guardian: true,
                createdBy: true,
                followUps: { orderBy: { dueAt: 'asc' }, take: 3 },
                reports: { orderBy: { createdAt: 'desc' }, take: 1 },
            },
            orderBy: { occurredAt: 'desc' },
            take: 100,
        });
        return {
            success: true,
            data: data.map((item) => this.serializeParentConsultation(item)),
            meta: {},
        };
    }
    async createParentConsultation(actorUserId, input) {
        if (!input.studentId || !input.summary?.trim()) {
            throw new common_1.BadRequestException('학생과 상담 요약이 필요합니다.');
        }
        const occurredAt = this.validDate(input.occurredAt) ?? new Date();
        const consultation = await this.prisma.parentConsultation.create({
            data: {
                studentId: input.studentId,
                guardianId: input.guardianId || null,
                createdById: actorUserId,
                contactType: this.contactType(input.contactType),
                direction: this.consultationDirection(input.direction),
                occurredAt,
                summary: input.summary.trim(),
                detail: input.detail?.trim() || null,
                promisedAction: input.promisedAction?.trim() || null,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
                guardian: true,
                createdBy: true,
                followUps: true,
                reports: true,
            },
        });
        if (input.nextFollowUpAt) {
            await this.createParentFollowUp({
                studentId: input.studentId,
                guardianId: input.guardianId,
                consultationId: consultation.id,
                title: input.promisedAction?.trim() || `${consultation.summary} 후속 연락`,
                dueAt: input.nextFollowUpAt,
                assignedToId: actorUserId,
            });
        }
        return {
            success: true,
            data: this.serializeParentConsultation(consultation),
            meta: {},
        };
    }
    async parentFollowUps(filters) {
        const data = await this.prisma.parentFollowUpTask.findMany({
            where: {
                status: filters.status,
                studentId: filters.studentId,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
                guardian: true,
                assignedTo: true,
                consultation: true,
                sourceOpsTask: true,
            },
            orderBy: [{ status: 'asc' }, { dueAt: 'asc' }],
            take: 100,
        });
        return {
            success: true,
            data: data.map((item) => this.serializeFollowUp(item)),
            meta: {},
        };
    }
    async createParentFollowUp(input) {
        if (!input.studentId || !input.title?.trim() || !input.dueAt) {
            throw new common_1.BadRequestException('학생, 제목, 예정일이 필요합니다.');
        }
        const dueAt = this.validDate(input.dueAt);
        if (!dueAt) {
            throw new common_1.BadRequestException('유효한 예정일이 필요합니다.');
        }
        const data = await this.prisma.parentFollowUpTask.create({
            data: {
                studentId: input.studentId,
                guardianId: input.guardianId || null,
                consultationId: input.consultationId || null,
                sourceOpsTaskId: input.sourceOpsTaskId || null,
                assignedToId: input.assignedToId || null,
                title: input.title.trim(),
                dueAt,
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
                guardian: true,
                assignedTo: true,
                consultation: true,
                sourceOpsTask: true,
            },
        });
        return { success: true, data: this.serializeFollowUp(data), meta: {} };
    }
    async updateParentFollowUp(followUpId, input) {
        const data = await this.prisma.parentFollowUpTask.update({
            where: { id: followUpId },
            data: {
                status: input.status,
                completedAt: input.status === 'DONE' ? new Date() : undefined,
                dueAt: input.dueAt
                    ? (this.validDate(input.dueAt) ?? undefined)
                    : undefined,
                title: input.title?.trim(),
            },
            include: {
                student: { include: { user: true, class: true, grade: true } },
                guardian: true,
                assignedTo: true,
                consultation: true,
                sourceOpsTask: true,
            },
        });
        return { success: true, data: this.serializeFollowUp(data), meta: {} };
    }
    async createParentConsultationReport(consultationId, message, expiresInDays = 30) {
        const consultation = await this.prisma.parentConsultation.findUnique({
            where: { id: consultationId },
            include: { student: { include: { user: true } }, guardian: true },
        });
        if (!consultation) {
            throw new common_1.BadRequestException('상담 기록을 찾을 수 없습니다.');
        }
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + Math.max(1, expiresInDays));
        const report = await this.prisma.parentConsultationReport.create({
            data: {
                consultationId,
                studentId: consultation.studentId,
                guardianId: consultation.guardianId,
                tokenId: (0, crypto_1.randomBytes)(24).toString('hex'),
                message: message?.trim() ||
                    `${consultation.student.user.name} 학생 상담 요약을 공유드립니다.`,
                expiresAt,
            },
        });
        return {
            success: true,
            data: {
                report: {
                    id: report.id,
                    tokenId: report.tokenId,
                    message: report.message,
                    expiresAt: report.expiresAt.toISOString(),
                    createdAt: report.createdAt.toISOString(),
                },
                urlPath: `/parent/consultation-report?token=${report.tokenId}`,
            },
            meta: {},
        };
    }
    async createOpsParentFollowUp(taskId, input) {
        const task = await this.prisma.opsTask.findUnique({
            where: { id: taskId },
            include: { student: { include: { user: true } } },
        });
        if (!task) {
            throw new common_1.BadRequestException('운영 항목을 찾을 수 없습니다.');
        }
        const dueAt = this.validDate(input.dueAt) ?? new Date();
        return this.createParentFollowUp({
            studentId: task.studentId,
            guardianId: input.guardianId,
            sourceOpsTaskId: task.id,
            title: input.title?.trim() ||
                `${task.student.user.name} 학생 ${task.message} 상담`,
            dueAt: dueAt.toISOString(),
        });
    }
    async retentionGoals() {
        const rows = await this.goalPreferenceRows();
        return { success: true, data: rows, meta: {} };
    }
    async retentionInterventions() {
        const rows = await this.prisma.interventionQueueItem.findMany({
            where: { status: 'OPEN' },
            include: {
                student: {
                    include: {
                        user: true,
                        class: true,
                        goalRoadmaps: {
                            where: { status: 'ACTIVE' },
                            include: {
                                missions: { orderBy: { weekStartDate: 'desc' }, take: 1 },
                            },
                            take: 1,
                            orderBy: { createdAt: 'desc' },
                        },
                    },
                },
            },
            orderBy: [{ severity: 'desc' }, { createdAt: 'desc' }],
            take: 100,
        });
        return {
            success: true,
            data: rows.map((item) => {
                const roadmap = item.student.goalRoadmaps[0] ?? null;
                const mission = roadmap?.missions[0] ?? null;
                return {
                    id: item.id,
                    studentId: item.studentId,
                    studentName: item.student.user.name,
                    className: item.student.class?.name ?? null,
                    reasonType: item.reasonType,
                    reasonDate: item.reasonDate.toISOString(),
                    severity: item.severity,
                    message: item.message,
                    createdAt: item.createdAt.toISOString(),
                    roadmap: roadmap
                        ? {
                            targetName: roadmap.targetName,
                            targetDate: roadmap.targetDate.toISOString(),
                            reminderEnabled: roadmap.reminderEnabled,
                            reminderTime: roadmap.reminderTime,
                        }
                        : null,
                    currentMission: mission
                        ? {
                            id: mission.id,
                            title: mission.title,
                            status: mission.status,
                            targetMinutes: mission.targetMinutes,
                        }
                        : null,
                };
            }),
            meta: {},
        };
    }
    async generateRetentionInterventions() {
        const today = (0, date_util_1.dateOnly)();
        const week = (0, date_util_1.weekStart)(today);
        const students = await this.prisma.student.findMany({
            where: { enrollmentStatus: 'ACTIVE', user: { status: 'ACTIVE' } },
            include: {
                user: true,
                dailyMetrics: { orderBy: { metricDate: 'desc' }, take: 1 },
                focusMetrics: { where: { metricDate: { gte: week, lte: today } } },
                roadmapMissions: {
                    where: { weekStartDate: week, status: 'RECOMMENDED' },
                    take: 1,
                },
            },
            take: 500,
        });
        const data = [];
        for (const student of students) {
            const latest = student.dailyMetrics[0];
            const focusCount = student.focusMetrics.reduce((sum, item) => sum + item.eventCount, 0);
            if (latest && latest.streakDays === 0) {
                data.push(this.interventionRow(student.id, today, 'STREAK_BROKEN', 'MEDIUM', '출석/공부 연속 기록이 끊겼습니다.'));
            }
            if (latest && Number(latest.achievedRate) < 70) {
                data.push(this.interventionRow(student.id, today, 'TARGET_SHORTFALL', 'HIGH', '오늘 목표 달성률이 70% 미만입니다.'));
            }
            if (focusCount > 0) {
                data.push(this.interventionRow(student.id, today, 'FOCUS_INTERRUPTION', focusCount >= 3 ? 'HIGH' : 'MEDIUM', `이번 주 앱 이탈이 ${focusCount}회 기록됐습니다.`));
            }
            if (student.roadmapMissions.length > 0) {
                data.push(this.interventionRow(student.id, today, 'MISSION_NOT_ACCEPTED', 'LOW', '이번 주 로드맵 미션을 아직 수락하지 않았습니다.'));
            }
        }
        if (data.length > 0) {
            await this.prisma.interventionQueueItem.createMany({
                data,
                skipDuplicates: true,
            });
        }
        return this.retentionInterventions();
    }
    async messageRetentionIntervention(interventionId, actorUserId, message) {
        const item = await this.findOpenIntervention(interventionId);
        const body = message?.trim() || item.message;
        await this.notifications.sendDirectToUsers({
            userIds: [item.student.userId],
            notificationType: client_1.NotificationType.NOTICE,
            channel: client_1.NotificationChannel.IN_APP,
            title: '학습 점검',
            body,
        });
        const updated = await this.resolveIntervention(interventionId, actorUserId, 'MESSAGE_SENT');
        return { success: true, data: updated, meta: {} };
    }
    async recommendRetentionPlan(interventionId, actorUserId) {
        const item = await this.findOpenIntervention(interventionId);
        const today = (0, date_util_1.dateOnly)();
        const subjects = ['수학', '영어', '국어'];
        await this.prisma.studyPlan.createMany({
            data: subjects.map((subject, index) => ({
                studentId: item.studentId,
                planDate: today,
                subjectName: subject,
                title: index === 0 ? '추천 핵심 루틴' : '추천 보완 루틴',
                targetMinutes: index === 0 ? 60 : 40,
                priority: index === 0 ? 'HIGH' : 'MEDIUM',
            })),
            skipDuplicates: true,
        });
        await this.notifications.sendDirectToUsers({
            userIds: [item.student.userId],
            notificationType: client_1.NotificationType.NOTICE,
            channel: client_1.NotificationChannel.IN_APP,
            title: '오늘 추천 계획',
            body: '오늘 공부 계획을 추천했습니다. 홈에서 바로 확인해 주세요.',
        });
        const updated = await this.resolveIntervention(interventionId, actorUserId, 'PLAN_RECOMMENDED');
        return { success: true, data: updated, meta: {} };
    }
    async retentionMissionTemplates() {
        const templates = await this.prisma.dailyMissionTemplate.findMany({
            include: { grade: true, class: true },
            orderBy: [
                { isActive: 'desc' },
                { sortOrder: 'asc' },
                { createdAt: 'desc' },
            ],
            take: 100,
        });
        return {
            success: true,
            data: templates.map((template) => ({
                id: template.id,
                gradeId: template.gradeId,
                classId: template.classId,
                gradeName: template.grade?.name ?? null,
                className: template.class?.name ?? null,
                title: template.title,
                subjectName: template.subjectName,
                targetMinutes: template.targetMinutes,
                isActive: template.isActive,
                sortOrder: template.sortOrder,
            })),
            meta: {},
        };
    }
    async createRetentionMissionTemplate(actorUserId, input) {
        const data = this.dailyMissionTemplateData(input);
        const template = await this.prisma.dailyMissionTemplate.create({
            data: { ...data, createdById: actorUserId },
        });
        await this.audit.log({
            actorUserId,
            actionType: 'DAILY_MISSION_TEMPLATE_CREATED',
            targetType: 'daily_mission_template',
            targetId: template.id,
            afterData: template,
        });
        return { success: true, data: template, meta: {} };
    }
    async updateRetentionMissionTemplate(templateId, input) {
        const template = await this.prisma.dailyMissionTemplate.update({
            where: { id: templateId },
            data: this.dailyMissionTemplateData(input, true),
        });
        return { success: true, data: template, meta: {} };
    }
    async retentionDailyMissionOverview() {
        const today = (0, date_util_1.dateOnly)();
        const [total, completed, assigned, notificationOpens, reminderStudents] = await Promise.all([
            this.prisma.studentDailyMission.count({
                where: { missionDate: today },
            }),
            this.prisma.studentDailyMission.count({
                where: { missionDate: today, status: 'COMPLETED' },
            }),
            this.prisma.studentDailyMission.findMany({
                where: { missionDate: today },
                include: { student: { include: { user: true, class: true } } },
                orderBy: [{ status: 'asc' }, { updatedAt: 'desc' }],
                take: 50,
            }),
            this.prisma.studentAppEvent.count({
                where: { eventDate: today, eventType: 'NOTIFICATION_OPEN' },
            }),
            this.countDailyMissionReminderEnabledStudents(),
        ]);
        return {
            success: true,
            data: {
                missionDate: today.toISOString(),
                totalAssignedCount: total,
                completedCount: completed,
                incompleteCount: Math.max(0, total - completed),
                completionRate: total === 0 ? 0 : Number(((completed / total) * 100).toFixed(1)),
                notificationOpenCount: notificationOpens,
                reminderEnabledStudentCount: reminderStudents,
                missions: assigned.map((mission) => ({
                    id: mission.id,
                    studentId: mission.studentId,
                    studentName: mission.student.user.name,
                    className: mission.student.class?.name ?? null,
                    title: mission.title,
                    subjectName: mission.subjectName,
                    targetMinutes: mission.targetMinutes,
                    status: mission.status,
                    source: mission.source,
                    completedAt: mission.completedAt?.toISOString() ?? null,
                })),
            },
            meta: {},
        };
    }
    async reviewRetentionGoal(studentId, status, reviewerUserId, memo) {
        if (!['APPROVED', 'REJECTED', 'PENDING'].includes(status)) {
            throw new common_1.BadRequestException('지원하지 않는 승인 상태입니다.');
        }
        const key = this.preferenceKey(studentId);
        const setting = await this.prisma.appSetting.findUnique({
            where: { settingKey: key },
        });
        const current = setting?.settingValue ?? {};
        const next = {
            ...current,
            tvGoalApprovalStatus: status,
            tvGoalReviewedAt: new Date().toISOString(),
            tvGoalReviewedBy: reviewerUserId,
            tvGoalReviewMemo: memo ?? null,
        };
        const saved = setting
            ? await this.prisma.appSetting.update({
                where: { settingKey: key },
                data: { settingValue: next },
            })
            : await this.prisma.appSetting.create({
                data: { settingKey: key, settingValue: next },
            });
        await this.audit.log({
            actorUserId: reviewerUserId,
            actionType: 'RETENTION_GOAL_REVIEWED',
            targetType: 'student',
            targetId: studentId,
            afterData: { status, memo },
        });
        return { success: true, data: saved.settingValue, meta: {} };
    }
    opsTaskRow(studentId, taskDate, reasonType, severity, message, sourceSnapshot) {
        return {
            studentId,
            taskDate,
            reasonType,
            severity,
            message,
            sourceSnapshot: sourceSnapshot,
        };
    }
    opsTaskStatus(value) {
        return value && ['OPEN', 'RESOLVED', 'DISMISSED'].includes(value)
            ? value
            : undefined;
    }
    opsTaskReasonType(value) {
        return value &&
            [
                'NOT_CHECKED_IN',
                'EARLY_LEAVE',
                'DAILY_MISSION_INCOMPLETE',
                'TARGET_SHORTFALL',
                'FOCUS_INTERRUPTION',
            ].includes(value)
            ? value
            : undefined;
    }
    opsTaskSeverity(value) {
        return value && ['LOW', 'MEDIUM', 'HIGH'].includes(value)
            ? value
            : undefined;
    }
    opsTaskInclude() {
        return {
            student: { include: { user: true, class: true, grade: true } },
            actions: {
                include: { actor: true },
                orderBy: { createdAt: 'desc' },
                take: 20,
            },
            parentReports: { orderBy: { createdAt: 'desc' }, take: 5 },
        };
    }
    async findOpenOpsTask(taskId) {
        const task = await this.prisma.opsTask.findFirst({
            where: { id: taskId, status: 'OPEN' },
            include: { student: true },
        });
        if (!task) {
            throw new common_1.BadRequestException('처리할 운영 항목을 찾을 수 없습니다.');
        }
        return task;
    }
    async opsTaskResponse(taskId) {
        const task = await this.prisma.opsTask.findUnique({
            where: { id: taskId },
            include: this.opsTaskInclude(),
        });
        return {
            success: true,
            data: task ? this.serializeOpsTask(task) : null,
            meta: {},
        };
    }
    serializeOpsTask(task) {
        return {
            id: task.id,
            studentId: task.studentId,
            studentName: task.student.user.name,
            studentNo: task.student.studentNo,
            className: task.student.class?.name ?? null,
            gradeName: task.student.grade?.name ?? null,
            taskDate: task.taskDate.toISOString(),
            reasonType: task.reasonType,
            severity: task.severity,
            status: task.status,
            message: task.message,
            sourceSnapshot: task.sourceSnapshot,
            resolvedAt: task.resolvedAt?.toISOString() ?? null,
            createdAt: task.createdAt.toISOString(),
            updatedAt: task.updatedAt.toISOString(),
            actions: task.actions.map((action) => ({
                id: action.id,
                actionType: action.actionType,
                actorName: action.actor?.name ?? null,
                payload: action.payload,
                createdAt: action.createdAt.toISOString(),
            })),
            parentReports: task.parentReports.map((report) => ({
                id: report.id,
                tokenId: report.tokenId,
                message: report.message,
                expiresAt: report.expiresAt.toISOString(),
                viewedAt: report.viewedAt?.toISOString() ?? null,
                createdAt: report.createdAt.toISOString(),
            })),
        };
    }
    interventionRow(studentId, reasonDate, reasonType, severity, message) {
        return { studentId, reasonDate, reasonType, severity, message };
    }
    async findOpenIntervention(interventionId) {
        const item = await this.prisma.interventionQueueItem.findFirst({
            where: { id: interventionId, status: 'OPEN' },
            include: { student: true },
        });
        if (!item) {
            throw new common_1.BadRequestException('처리할 개입 항목을 찾을 수 없습니다.');
        }
        return item;
    }
    resolveIntervention(interventionId, actorUserId, actionType) {
        return this.prisma.interventionQueueItem.update({
            where: { id: interventionId },
            data: {
                status: 'RESOLVED',
                actionType,
                resolvedById: actorUserId,
                resolvedAt: new Date(),
            },
        });
    }
    dailyMissionTemplateData(input, partial = false) {
        const title = input.title?.trim();
        const subjectName = input.subjectName?.trim();
        if (!partial && !title) {
            throw new common_1.BadRequestException('미션 제목이 필요합니다.');
        }
        if (!partial && !subjectName) {
            throw new common_1.BadRequestException('과목명이 필요합니다.');
        }
        if (input.targetMinutes !== undefined &&
            (input.targetMinutes < 10 || input.targetMinutes > 480)) {
            throw new common_1.BadRequestException('목표 시간은 10~480분 사이여야 합니다.');
        }
        return {
            ...(input.gradeId !== undefined ? { gradeId: input.gradeId } : {}),
            ...(input.classId !== undefined ? { classId: input.classId } : {}),
            ...(title ? { title } : {}),
            ...(subjectName ? { subjectName } : {}),
            ...(input.targetMinutes !== undefined
                ? { targetMinutes: Math.round(input.targetMinutes) }
                : partial
                    ? {}
                    : { targetMinutes: 60 }),
            ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
            ...(input.sortOrder !== undefined
                ? { sortOrder: Math.round(input.sortOrder) }
                : {}),
        };
    }
    async countDailyMissionReminderEnabledStudents() {
        const settings = await this.prisma.appSetting.findMany({
            where: {
                settingKey: { startsWith: 'student:', endsWith: ':preferences' },
            },
            take: 1000,
        });
        return settings.filter((setting) => {
            const value = (setting.settingValue ?? {});
            return value.dailyMissionReminderEnabled !== false;
        }).length;
    }
    async goalPreferenceRows(status) {
        const settings = await this.prisma.appSetting.findMany({
            where: {
                settingKey: { startsWith: 'student:', endsWith: ':preferences' },
            },
            take: 500,
        });
        const rows = settings
            .map((setting) => ({
            studentId: this.studentIdFromPreferenceKey(setting.settingKey),
            value: (setting.settingValue ?? {}),
        }))
            .filter((item) => Boolean(item.studentId) &&
            item.value.tvGoalConsent === true &&
            typeof item.value.targetUniversityName === 'string' &&
            item.value.targetUniversityName.trim().length > 0 &&
            (!status || item.value.tvGoalApprovalStatus === status));
        const students = rows.length
            ? await this.prisma.student.findMany({
                where: { id: { in: rows.map((row) => row.studentId) } },
                include: { user: true, class: true, grade: true },
            })
            : [];
        const mediaIds = rows
            .map((row) => row.value.targetUniversityMediaId)
            .filter((id) => typeof id === 'string');
        const media = mediaIds.length
            ? await this.prisma.mediaAsset.findMany({
                where: { id: { in: mediaIds } },
            })
            : [];
        const studentById = new Map(students.map((student) => [student.id, student]));
        const mediaById = new Map(media.map((item) => [item.id, item]));
        return rows.map((row) => {
            const student = studentById.get(row.studentId);
            const mediaId = row.value.targetUniversityMediaId;
            return {
                studentId: row.studentId,
                studentName: student?.user.name ?? '학생',
                className: student?.class?.name ?? null,
                gradeName: student?.grade?.name ?? null,
                targetUniversityName: row.value.targetUniversityName,
                tvGoalConsent: row.value.tvGoalConsent === true,
                tvGoalApprovalStatus: typeof row.value.tvGoalApprovalStatus === 'string'
                    ? row.value.tvGoalApprovalStatus
                    : 'NOT_REQUESTED',
                tvGoalReviewedAt: typeof row.value.tvGoalReviewedAt === 'string'
                    ? row.value.tvGoalReviewedAt
                    : null,
                tvGoalReviewMemo: typeof row.value.tvGoalReviewMemo === 'string'
                    ? row.value.tvGoalReviewMemo
                    : null,
                targetUniversityMedia: typeof mediaId === 'string' ? (mediaById.get(mediaId) ?? null) : null,
            };
        });
    }
    studentIdFromPreferenceKey(key) {
        const match = /^student:([^:]+):preferences$/.exec(key);
        return match?.[1] ?? null;
    }
    preferenceKey(studentId) {
        return `student:${studentId}:preferences`;
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
    async ensureFocusPolicy() {
        const existing = await this.prisma.focusPolicy.findFirst({
            orderBy: { createdAt: 'asc' },
        });
        if (existing)
            return existing;
        return this.prisma.focusPolicy.create({
            data: {
                policyName: '기본 집중모드 정책',
                mode: client_1.FocusPolicyMode.SOFT_LOCK,
                isEnabled: false,
                blockedPackages: [],
                allowedPackages: [],
                graceSeconds: 15,
                opsQueueThreshold: 2,
                parentReportThreshold: 3,
            },
        });
    }
    policyInt(value, fallback) {
        return Number.isInteger(value) && value >= 0
            ? value
            : fallback;
    }
    guardianRelation(value) {
        return value && Object.values(client_1.GuardianRelation).includes(value)
            ? value
            : client_1.GuardianRelation.GUARDIAN;
    }
    contactType(value) {
        return value && Object.values(client_1.ConsultationContactType).includes(value)
            ? value
            : client_1.ConsultationContactType.CALL;
    }
    consultationDirection(value) {
        return value && Object.values(client_1.ConsultationDirection).includes(value)
            ? value
            : client_1.ConsultationDirection.OUTBOUND;
    }
    validDate(value) {
        if (!value)
            return null;
        const date = new Date(value);
        return Number.isNaN(date.getTime()) ? null : date;
    }
    serializeGuardian(item) {
        return {
            id: item.id,
            studentId: item.studentId,
            studentName: item.student.user.name,
            studentNo: item.student.studentNo,
            className: item.student.class?.name ?? null,
            gradeName: item.student.grade?.name ?? null,
            name: item.name,
            relation: item.relation,
            phone: item.phone,
            email: item.email,
            isPrimary: item.isPrimary,
            memo: item.memo,
            createdAt: item.createdAt.toISOString(),
            updatedAt: item.updatedAt.toISOString(),
        };
    }
    serializeParentConsultation(item) {
        return {
            id: item.id,
            studentId: item.studentId,
            studentName: item.student.user.name,
            studentNo: item.student.studentNo,
            className: item.student.class?.name ?? null,
            gradeName: item.student.grade?.name ?? null,
            guardianId: item.guardianId,
            guardianName: item.guardian?.name ?? null,
            guardianRelation: item.guardian?.relation ?? null,
            createdByName: item.createdBy?.name ?? null,
            contactType: item.contactType,
            direction: item.direction,
            occurredAt: item.occurredAt.toISOString(),
            summary: item.summary,
            detail: item.detail,
            promisedAction: item.promisedAction,
            createdAt: item.createdAt.toISOString(),
            followUps: item.followUps?.map((task) => ({
                id: task.id,
                title: task.title,
                dueAt: task.dueAt.toISOString(),
                status: task.status,
            })) ?? [],
            latestReport: item.reports?.[0]
                ? {
                    id: item.reports[0].id,
                    expiresAt: item.reports[0].expiresAt.toISOString(),
                    viewedAt: item.reports[0].viewedAt?.toISOString() ?? null,
                }
                : null,
        };
    }
    serializeFollowUp(item) {
        return {
            id: item.id,
            studentId: item.studentId,
            studentName: item.student.user.name,
            studentNo: item.student.studentNo,
            className: item.student.class?.name ?? null,
            gradeName: item.student.grade?.name ?? null,
            guardianId: item.guardianId,
            guardianName: item.guardian?.name ?? null,
            consultationId: item.consultationId,
            sourceOpsTaskId: item.sourceOpsTaskId,
            assignedToName: item.assignedTo?.name ?? null,
            title: item.title,
            dueAt: item.dueAt.toISOString(),
            status: item.status,
            completedAt: item.completedAt?.toISOString() ?? null,
            createdAt: item.createdAt.toISOString(),
        };
    }
};
exports.AdminService = AdminService;
exports.AdminService = AdminService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        audit_service_1.AuditService,
        notifications_service_1.NotificationsService])
], AdminService);
//# sourceMappingURL=admin.service.js.map