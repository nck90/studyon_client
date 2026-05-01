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
exports.AttendancesService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const audit_service_1 = require("../audit/audit.service");
const prisma_service_1 = require("../database/prisma.service");
const date_util_1 = require("../common/utils/date.util");
const events_service_1 = require("../events/events.service");
const notifications_service_1 = require("../notifications/notifications.service");
const points_service_1 = require("../points/points.service");
let AttendancesService = class AttendancesService {
    prisma;
    audit;
    events;
    notificationsService;
    pointsService;
    constructor(prisma, audit, events, notificationsService, pointsService) {
        this.prisma = prisma;
        this.audit = audit;
        this.events = events;
        this.notificationsService = notificationsService;
        this.pointsService = pointsService;
    }
    serializeAttendance(attendance) {
        if (!attendance)
            return null;
        return {
            id: attendance.id,
            studentId: attendance.studentId,
            attendanceDate: attendance.attendanceDate.toISOString().slice(0, 10),
            status: attendance.attendanceStatus,
            checkInAt: attendance.checkInAt?.toISOString() ?? null,
            checkOutAt: attendance.checkOutAt?.toISOString() ?? null,
            stayMinutes: attendance.stayMinutes,
            isLate: attendance.lateStatus === client_1.AttendanceFlag.LATE,
            isEarlyLeave: attendance.earlyLeaveStatus === client_1.AttendanceFlag.EARLY_LEAVE,
        };
    }
    async getToday(studentId) {
        const attendance = await this.prisma.attendance.findUnique({
            where: {
                studentId_attendanceDate: {
                    studentId,
                    attendanceDate: (0, date_util_1.dateOnly)(),
                },
            },
        });
        const studentUser = await this.prisma.student.findUnique({
            where: { id: studentId },
            select: { userId: true },
        });
        this.events.emit({
            channel: 'attendance',
            event: 'student.checked_in',
            payload: attendance,
            userId: studentUser?.userId,
        });
        this.events.emit({
            channel: 'display',
            event: 'display.refresh',
            payload: { type: 'status' },
        });
        return {
            success: true,
            data: this.serializeAttendance(attendance),
            meta: {},
        };
    }
    async listStudentAttendances(studentId, startDate, endDate) {
        const items = await this.prisma.attendance.findMany({
            where: {
                studentId,
                attendanceDate: {
                    gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                    lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                },
            },
            orderBy: { attendanceDate: 'desc' },
        });
        return {
            success: true,
            data: items.map((item) => this.serializeAttendance(item)),
            meta: {},
        };
    }
    async checkIn(studentId, seatId) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
        });
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        const today = (0, date_util_1.dateOnly)();
        const now = new Date();
        const existing = await this.prisma.attendance.findUnique({
            where: { studentId_attendanceDate: { studentId, attendanceDate: today } },
        });
        if (existing?.attendanceStatus === client_1.AttendanceStatus.CHECKED_IN) {
            throw new common_1.BadRequestException('이미 입실 처리되었습니다.');
        }
        if (seatId) {
            const seat = await this.prisma.seat.findUnique({ where: { id: seatId } });
            if (!seat || seat.status === client_1.SeatStatus.LOCKED) {
                throw new common_1.BadRequestException('좌석 상태가 유효하지 않습니다.');
            }
        }
        const lateStatus = now.getHours() >= 9 && now.getMinutes() > 0
            ? client_1.AttendanceFlag.LATE
            : client_1.AttendanceFlag.NONE;
        const attendance = await this.prisma.$transaction(async (tx) => {
            const saved = existing
                ? await tx.attendance.update({
                    where: { id: existing.id },
                    data: {
                        checkInAt: now,
                        attendanceStatus: client_1.AttendanceStatus.CHECKED_IN,
                        seatId,
                        lateStatus,
                    },
                })
                : await tx.attendance.create({
                    data: {
                        studentId,
                        attendanceDate: today,
                        checkInAt: now,
                        attendanceStatus: client_1.AttendanceStatus.CHECKED_IN,
                        seatId,
                        lateStatus,
                    },
                });
            if (seatId) {
                await tx.seat.update({
                    where: { id: seatId },
                    data: { currentStudentId: studentId, status: client_1.SeatStatus.OCCUPIED },
                });
            }
            return saved;
        });
        await this.notifyStudent(studentId, '입실 완료', seatId
            ? '좌석 배정과 함께 입실 처리되었습니다.'
            : '오늘 입실이 기록되었습니다.');
        await this.pointsService
            .earn(studentId, 50, 'ATTENDANCE', '출석 보너스')
            .catch(() => { });
        return {
            success: true,
            data: this.serializeAttendance(attendance),
            meta: {},
        };
    }
    async checkOut(studentId, forceCloseStudySession = true) {
        const today = (0, date_util_1.dateOnly)();
        const attendance = await this.prisma.attendance.findUnique({
            where: { studentId_attendanceDate: { studentId, attendanceDate: today } },
        });
        if (!attendance || !attendance.checkInAt) {
            throw new common_1.BadRequestException('입실 기록이 없습니다.');
        }
        const now = new Date();
        const stayMinutes = (0, date_util_1.diffMinutes)(attendance.checkInAt, now);
        const earlyLeaveStatus = now.getHours() < 22 ? client_1.AttendanceFlag.EARLY_LEAVE : client_1.AttendanceFlag.NONE;
        const autoClosedSessions = [];
        const result = await this.prisma.$transaction(async (tx) => {
            if (forceCloseStudySession) {
                const activeSessions = await tx.studySession.findMany({
                    where: {
                        studentId,
                        status: {
                            in: [client_1.StudySessionStatus.ACTIVE, client_1.StudySessionStatus.PAUSED],
                        },
                    },
                    include: { studyBreaks: true },
                });
                for (const session of activeSessions) {
                    const openBreak = session.studyBreaks.find((item) => !item.endedAt);
                    if (openBreak) {
                        const breakSeconds = (0, date_util_1.diffSeconds)(openBreak.startedAt, now);
                        await tx.studyBreak.update({
                            where: { id: openBreak.id },
                            data: {
                                endedAt: now,
                                breakMinutes: Math.floor(breakSeconds / 60),
                                breakSeconds,
                            },
                        });
                    }
                    const refreshedBreaks = await tx.studyBreak.findMany({
                        where: { studySessionId: session.id },
                    });
                    const totalBreakSeconds = refreshedBreaks.reduce((sum, item) => sum + item.breakSeconds, 0);
                    const totalSeconds = (0, date_util_1.diffSeconds)(session.startedAt, now);
                    const studySeconds = Math.max(0, totalSeconds - totalBreakSeconds);
                    const closedSession = await tx.studySession.update({
                        where: { id: session.id },
                        data: {
                            status: client_1.StudySessionStatus.AUTO_CLOSED,
                            endedAt: now,
                            breakMinutes: Math.floor(totalBreakSeconds / 60),
                            breakSeconds: totalBreakSeconds,
                            studyMinutes: Math.floor(studySeconds / 60),
                            studySeconds,
                            autoClosedReason: 'CHECK_OUT',
                        },
                    });
                    autoClosedSessions.push({
                        id: closedSession.id,
                        studySeconds: closedSession.studySeconds,
                    });
                }
            }
            const updated = await tx.attendance.update({
                where: { id: attendance.id },
                data: {
                    checkOutAt: now,
                    stayMinutes,
                    attendanceStatus: client_1.AttendanceStatus.CHECKED_OUT,
                    earlyLeaveStatus,
                },
            });
            if (attendance.seatId) {
                const reserved = await tx.student.findUnique({
                    where: { id: studentId },
                    select: { assignedSeatId: true },
                });
                await tx.seat.update({
                    where: { id: attendance.seatId },
                    data: {
                        currentStudentId: null,
                        status: reserved?.assignedSeatId === attendance.seatId
                            ? client_1.SeatStatus.RESERVED
                            : client_1.SeatStatus.AVAILABLE,
                    },
                });
            }
            return updated;
        });
        await Promise.all(autoClosedSessions.map((session) => this.pointsService.awardStudySessionTime(studentId, session.id, session.studySeconds)));
        const studentUser = await this.prisma.student.findUnique({
            where: { id: studentId },
            select: { userId: true },
        });
        this.events.emit({
            channel: 'attendance',
            event: 'student.checked_out',
            payload: result,
            userId: studentUser?.userId,
        });
        this.events.emit({
            channel: 'display',
            event: 'display.refresh',
            payload: { type: 'status' },
        });
        await this.notifyStudent(studentId, '퇴실 완료', '오늘 출결이 체크아웃 상태로 저장되었습니다.', client_1.NotificationType.LEAVE_TIME);
        return { success: true, data: this.serializeAttendance(result), meta: {} };
    }
    async listAdmin(date, startDate, endDate, classId, groupId, attendanceStatus) {
        const items = await this.prisma.attendance.findMany({
            where: {
                attendanceDate: date
                    ? (0, date_util_1.dateOnly)(date)
                    : {
                        gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                        lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                    },
                attendanceStatus,
                student: {
                    classId: classId ?? undefined,
                    groupId: groupId ?? undefined,
                },
            },
            include: {
                student: { include: { user: true, class: true, group: true } },
                seat: true,
            },
            orderBy: [{ attendanceDate: 'desc' }, { createdAt: 'desc' }],
        });
        return { success: true, data: items, meta: {} };
    }
    async getAdmin(attendanceId) {
        const item = await this.prisma.attendance.findUnique({
            where: { id: attendanceId },
            include: { student: { include: { user: true } }, seat: true },
        });
        if (!item) {
            throw new common_1.NotFoundException('출결 데이터를 찾을 수 없습니다.');
        }
        return { success: true, data: item, meta: {} };
    }
    async updateAdmin(attendanceId, dto, actorUserId) {
        const attendance = await this.prisma.attendance.findUnique({
            where: { id: attendanceId },
            include: { student: true },
        });
        if (!attendance) {
            throw new common_1.NotFoundException('출결 데이터를 찾을 수 없습니다.');
        }
        const nextCheckInAt = dto.checkInAt
            ? new Date(dto.checkInAt)
            : attendance.checkInAt;
        let nextCheckOutAt = dto.checkOutAt
            ? new Date(dto.checkOutAt)
            : attendance.checkOutAt;
        const nextStatus = dto.attendanceStatus ?? attendance.attendanceStatus;
        if (nextCheckInAt &&
            nextCheckOutAt &&
            nextCheckOutAt.getTime() < nextCheckInAt.getTime()) {
            throw new common_1.BadRequestException('퇴실 시간은 입실 시간보다 빠를 수 없습니다.');
        }
        if (nextStatus === client_1.AttendanceStatus.CHECKED_OUT &&
            nextCheckInAt &&
            !nextCheckOutAt) {
            nextCheckOutAt = new Date();
        }
        const stayMinutes = nextCheckInAt && nextCheckOutAt
            ? (0, date_util_1.diffMinutes)(nextCheckInAt, nextCheckOutAt)
            : 0;
        const nextSeatId = dto.seatId !== undefined ? dto.seatId || null : attendance.seatId;
        const updated = await this.prisma.$transaction(async (tx) => {
            if (attendance.seatId && attendance.seatId !== nextSeatId) {
                await tx.seat.update({
                    where: { id: attendance.seatId },
                    data: {
                        currentStudentId: null,
                        status: attendance.student.assignedSeatId === attendance.seatId
                            ? client_1.SeatStatus.RESERVED
                            : client_1.SeatStatus.AVAILABLE,
                    },
                });
            }
            if (nextSeatId) {
                const targetSeat = await tx.seat.findUnique({
                    where: { id: nextSeatId },
                });
                if (!targetSeat || targetSeat.status === client_1.SeatStatus.LOCKED) {
                    throw new common_1.BadRequestException('유효하지 않은 좌석입니다.');
                }
                await tx.seat.update({
                    where: { id: nextSeatId },
                    data: {
                        currentStudentId: nextStatus === client_1.AttendanceStatus.CHECKED_IN
                            ? attendance.studentId
                            : null,
                        status: nextStatus === client_1.AttendanceStatus.CHECKED_IN
                            ? client_1.SeatStatus.OCCUPIED
                            : attendance.student.assignedSeatId === nextSeatId
                                ? client_1.SeatStatus.RESERVED
                                : client_1.SeatStatus.AVAILABLE,
                    },
                });
            }
            return tx.attendance.update({
                where: { id: attendanceId },
                data: {
                    attendanceStatus: nextStatus,
                    checkInAt: nextCheckInAt,
                    checkOutAt: nextCheckOutAt,
                    stayMinutes,
                    seatId: nextSeatId,
                    lateStatus: dto.lateStatus ?? attendance.lateStatus,
                    earlyLeaveStatus: dto.earlyLeaveStatus ?? attendance.earlyLeaveStatus,
                },
                include: { student: { include: { user: true } }, seat: true },
            });
        });
        await this.audit.log({
            actorUserId,
            actionType: 'ATTENDANCE_UPDATED',
            targetType: 'attendance',
            targetId: attendanceId,
            beforeData: attendance,
            afterData: updated,
        });
        this.events.emit({
            channel: 'attendance',
            event: 'attendance.updated',
            payload: updated,
        });
        this.events.emit({
            channel: 'display',
            event: 'display.refresh',
            payload: { type: 'status' },
        });
        return { success: true, data: updated, meta: {} };
    }
    async stats(startDate, endDate, classId) {
        const items = await this.prisma.attendance.findMany({
            where: {
                attendanceDate: {
                    gte: startDate ? (0, date_util_1.dateOnly)(startDate) : undefined,
                    lte: endDate ? (0, date_util_1.dateOnly)(endDate) : undefined,
                },
                student: { classId: classId ?? undefined },
            },
        });
        const total = items.length;
        const checkedIn = items.filter((item) => item.attendanceStatus !== client_1.AttendanceStatus.ABSENT).length;
        const late = items.filter((item) => item.lateStatus === client_1.AttendanceFlag.LATE).length;
        const earlyLeave = items.filter((item) => item.earlyLeaveStatus === client_1.AttendanceFlag.EARLY_LEAVE).length;
        return {
            success: true,
            data: {
                total,
                checkedIn,
                attendanceRate: total === 0 ? 0 : Number(((checkedIn / total) * 100).toFixed(2)),
                late,
                earlyLeave,
            },
            meta: {},
        };
    }
    async notifyStudent(studentId, title, body, notificationType = client_1.NotificationType.NOTICE) {
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
            select: { userId: true },
        });
        if (!student?.userId) {
            return;
        }
        await this.notificationsService.sendDirectToUsers({
            userIds: [student.userId],
            notificationType,
            channel: client_1.NotificationChannel.IN_APP,
            title,
            body,
        });
    }
};
exports.AttendancesService = AttendancesService;
exports.AttendancesService = AttendancesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        audit_service_1.AuditService,
        events_service_1.EventsService,
        notifications_service_1.NotificationsService,
        points_service_1.PointsService])
], AttendancesService);
//# sourceMappingURL=attendances.service.js.map