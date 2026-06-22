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
const events_service_1 = require("../events/events.service");
const media_service_1 = require("../media/media.service");
let StudentsService = class StudentsService {
    prisma;
    events;
    mediaService;
    constructor(prisma, events, mediaService) {
        this.prisma = prisma;
        this.events = events;
        this.mediaService = mediaService;
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
    async getFocusPolicy() {
        const policy = await this.prisma.focusPolicy.findFirst({
            orderBy: { createdAt: 'asc' },
        });
        return {
            success: true,
            data: policy ?? {
                id: null,
                policyName: '기본 집중모드 정책',
                mode: 'SOFT_LOCK',
                isEnabled: false,
                blockedPackages: [],
                allowedPackages: [],
                graceSeconds: 15,
                opsQueueThreshold: 2,
                parentReportThreshold: 3,
            },
            meta: {},
        };
    }
    async updatePreferences(studentId, input) {
        const current = await this.getStudentPreferences(studentId);
        const next = {
            notificationEnabled: input.notificationEnabled ?? current.notificationEnabled,
            targetUniversityName: input.targetUniversityName === undefined
                ? current.targetUniversityName
                : input.targetUniversityName,
            targetUniversityMediaId: input.targetUniversityMediaId === undefined
                ? current.targetUniversityMediaId
                : input.targetUniversityMediaId,
            homeBackgroundMediaId: input.homeBackgroundMediaId === undefined
                ? current.homeBackgroundMediaId
                : input.homeBackgroundMediaId,
            checkInBackgroundMediaId: input.checkInBackgroundMediaId === undefined
                ? current.checkInBackgroundMediaId
                : input.checkInBackgroundMediaId,
            themePreset: input.themePreset === undefined
                ? current.themePreset
                : input.themePreset,
            focusModeEnabled: input.focusModeEnabled ?? current.focusModeEnabled,
            tvGoalConsent: input.tvGoalConsent ?? current.tvGoalConsent,
            tvGoalApprovalStatus: input.tvGoalConsent === false
                ? 'NOT_REQUESTED'
                : input.targetUniversityName !== undefined ||
                    input.targetUniversityMediaId !== undefined
                    ? 'PENDING'
                    : current.tvGoalApprovalStatus,
            tvGoalReviewedAt: input.tvGoalConsent === false ? null : current.tvGoalReviewedAt,
            tvGoalReviewedBy: input.tvGoalConsent === false ? null : current.tvGoalReviewedBy,
            tvGoalReviewMemo: input.tvGoalConsent === false ? null : current.tvGoalReviewMemo,
        };
        await this.assertOwnedMedia(studentId, [
            [next.targetUniversityMediaId, client_1.MediaAssetKind.TARGET_UNIVERSITY],
            [next.homeBackgroundMediaId, client_1.MediaAssetKind.HOME_BACKGROUND],
            [next.checkInBackgroundMediaId, client_1.MediaAssetKind.CHECKIN_BACKGROUND],
        ]);
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
        await this.deleteReplacedMedia(studentId, current, next);
        return { success: true, data: next, meta: {} };
    }
    async getMotivationDashboard(studentId) {
        const today = (0, date_util_1.dateOnly)();
        const preferences = await this.getStudentPreferences(studentId);
        const [dailyMetric, weeklyMetric, monthlyMetric, badges, plans] = await Promise.all([
            this.prisma.dailyStudentMetric.findUnique({
                where: { studentId_metricDate: { studentId, metricDate: today } },
            }),
            this.prisma.weeklyStudentMetric.findFirst({
                where: { studentId },
                orderBy: { weekStartDate: 'desc' },
            }),
            this.prisma.monthlyStudentMetric.findFirst({
                where: { studentId },
                orderBy: { monthKey: 'desc' },
            }),
            this.prisma.studentBadge.findMany({
                where: { studentId },
                include: { badge: true },
                orderBy: { awardedAt: 'desc' },
                take: 8,
            }),
            this.prisma.studyPlan.findMany({
                where: { studentId, planDate: today },
                orderBy: [{ priority: 'desc' }, { createdAt: 'asc' }],
            }),
        ]);
        return {
            success: true,
            data: {
                preferences,
                today: {
                    studyMinutes: dailyMetric?.studyMinutes ?? 0,
                    targetMinutes: dailyMetric?.targetMinutes ?? 0,
                    achievedRate: Number(dailyMetric?.achievedRate ?? 0),
                    pagesCompleted: dailyMetric?.pagesCompleted ?? 0,
                    problemsSolved: dailyMetric?.problemsSolved ?? 0,
                    streakDays: dailyMetric?.streakDays ?? 0,
                },
                week: {
                    studyMinutes: weeklyMetric?.studyMinutes ?? 0,
                    targetMinutes: weeklyMetric?.targetMinutes ?? 0,
                    achievedRate: Number(weeklyMetric?.achievedRate ?? 0),
                },
                month: {
                    studyMinutes: monthlyMetric?.studyMinutes ?? 0,
                    targetMinutes: monthlyMetric?.targetMinutes ?? 0,
                    achievedRate: Number(monthlyMetric?.achievedRate ?? 0),
                },
                badges,
                plans,
            },
            meta: {},
        };
    }
    async getGoalRoadmap(studentId) {
        const roadmap = await this.activeRoadmap(studentId);
        if (!roadmap) {
            return {
                success: true,
                data: {
                    roadmap: null,
                    milestones: [],
                    currentMission: null,
                    daysLeft: null,
                    progressPercent: 0,
                },
                meta: {},
            };
        }
        await this.syncMissionStatus(studentId, roadmap.id);
        const refreshed = await this.activeRoadmap(studentId);
        return { success: true, data: this.serializeRoadmap(refreshed), meta: {} };
    }
    async saveGoalRoadmap(studentId, input) {
        const targetName = input.targetName?.trim();
        if (!targetName) {
            throw new common_1.BadRequestException('목표 이름이 필요합니다.');
        }
        const targetDate = (0, date_util_1.dateOnly)(input.targetDate);
        if (Number.isNaN(targetDate.getTime())) {
            throw new common_1.BadRequestException('목표 날짜가 올바르지 않습니다.');
        }
        const today = (0, date_util_1.dateOnly)();
        if (targetDate <= today) {
            throw new common_1.BadRequestException('목표 날짜는 오늘 이후여야 합니다.');
        }
        const reminderTime = this.normalizeReminderTime(input.reminderTime);
        await this.prisma.$transaction(async (tx) => {
            await tx.studentGoalRoadmap.updateMany({
                where: { studentId, status: 'ACTIVE' },
                data: { status: 'ARCHIVED' },
            });
            await tx.studentGoalRoadmap.create({
                data: {
                    studentId,
                    targetName,
                    targetDate,
                    reminderEnabled: input.reminderEnabled ?? true,
                    reminderTime,
                },
            });
        });
        return this.generateGoalRoadmap(studentId);
    }
    async generateGoalRoadmap(studentId) {
        const roadmap = await this.ensureActiveRoadmap(studentId);
        const recommendation = await this.roadmapRecommendation(studentId);
        const now = (0, date_util_1.dateOnly)();
        const milestones = this.buildMilestones(roadmap.id, now, roadmap.targetDate, recommendation.targetMinutes, recommendation.focusSubjects);
        const currentWeek = (0, date_util_1.weekStart)(now);
        const mission = {
            roadmapId: roadmap.id,
            studentId,
            weekStartDate: currentWeek,
            title: `${recommendation.focusSubjects.slice(0, 2).join('·')} 주간 루틴`,
            description: '이번 주 추천 공부 계획을 수락하면 오늘 계획에 반영됩니다.',
            focusSubjects: recommendation.focusSubjects,
            targetMinutes: recommendation.targetMinutes,
        };
        await this.prisma.$transaction(async (tx) => {
            await tx.roadmapMilestone.deleteMany({
                where: { roadmapId: roadmap.id },
            });
            await tx.roadmapMilestone.createMany({ data: milestones });
            await tx.roadmapMission.upsert({
                where: {
                    studentId_weekStartDate: { studentId, weekStartDate: currentWeek },
                },
                create: mission,
                update: {
                    title: mission.title,
                    description: mission.description,
                    focusSubjects: mission.focusSubjects,
                    targetMinutes: mission.targetMinutes,
                },
            });
        });
        const refreshed = await this.activeRoadmap(studentId);
        return { success: true, data: this.serializeRoadmap(refreshed), meta: {} };
    }
    async acceptRoadmapMission(studentId, missionId) {
        const mission = await this.prisma.roadmapMission.findFirst({
            where: { id: missionId, studentId },
        });
        if (!mission) {
            throw new common_1.NotFoundException('로드맵 미션을 찾을 수 없습니다.');
        }
        if (mission.status === 'EXPIRED') {
            throw new common_1.BadRequestException('만료된 미션입니다.');
        }
        const subjects = this.stringArray(mission.focusSubjects);
        const planDate = (0, date_util_1.dateOnly)();
        const perPlanMinutes = Math.max(30, Math.floor(mission.targetMinutes / Math.max(subjects.length, 1)));
        await this.prisma.$transaction(async (tx) => {
            await tx.roadmapMission.update({
                where: { id: mission.id },
                data: { status: 'ACCEPTED', acceptedAt: new Date() },
            });
            await tx.studyPlan.createMany({
                data: subjects.slice(0, 3).map((subject, index) => ({
                    studentId,
                    planDate,
                    subjectName: subject,
                    title: `${mission.title} ${index + 1}`,
                    targetMinutes: perPlanMinutes,
                    priority: index === 0 ? 'HIGH' : 'MEDIUM',
                })),
                skipDuplicates: true,
            });
        });
        const refreshed = await this.activeRoadmap(studentId);
        return { success: true, data: this.serializeRoadmap(refreshed), meta: {} };
    }
    async getTodayDailyMission(studentId) {
        const mission = await this.ensureTodayDailyMission(studentId);
        const synced = await this.syncDailyMissionCompletion(mission.id, studentId);
        const preferences = await this.getStudentPreferences(studentId);
        await this.recordAppEvent(studentId, {
            eventType: client_1.AppEventType.DAILY_MISSION_VIEW,
            payload: { missionId: synced.id },
        });
        return {
            success: true,
            data: this.serializeDailyMission(synced, preferences),
            meta: {},
        };
    }
    async generateTodayDailyMission(studentId) {
        const mission = await this.createOrRefreshTodayDailyMission(studentId);
        const preferences = await this.getStudentPreferences(studentId);
        return {
            success: true,
            data: this.serializeDailyMission(mission, preferences),
            meta: {},
        };
    }
    async completeDailyMission(studentId, missionId, completionMethod = 'MANUAL') {
        const mission = await this.prisma.studentDailyMission.findFirst({
            where: { id: missionId, studentId },
            include: { template: true },
        });
        if (!mission) {
            throw new common_1.NotFoundException('오늘 미션을 찾을 수 없습니다.');
        }
        const updated = await this.prisma.studentDailyMission.update({
            where: { id: mission.id },
            data: {
                status: 'COMPLETED',
                completedAt: mission.completedAt ?? new Date(),
                completionMethod: completionMethod.slice(0, 40),
            },
            include: { template: true },
        });
        await this.recordAppEvent(studentId, {
            eventType: client_1.AppEventType.DAILY_MISSION_COMPLETE,
            payload: { missionId: updated.id, completionMethod },
        });
        const preferences = await this.getStudentPreferences(studentId);
        return {
            success: true,
            data: this.serializeDailyMission(updated, preferences),
            meta: {},
        };
    }
    async updateDailyMissionReminder(studentId, input) {
        const current = await this.getStudentPreferences(studentId);
        const next = {
            ...current,
            dailyMissionReminderEnabled: input.reminderEnabled ?? current.dailyMissionReminderEnabled,
            dailyMissionReminderTime: this.normalizeReminderTime(input.reminderTime ?? current.dailyMissionReminderTime),
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
    async recordAppEvent(studentId, input) {
        const eventType = input.eventType ?? client_1.AppEventType.APP_OPEN;
        if (!Object.values(client_1.AppEventType).includes(eventType)) {
            throw new common_1.BadRequestException('지원하지 않는 앱 이벤트입니다.');
        }
        const occurredAt = input.occurredAt
            ? new Date(input.occurredAt)
            : new Date();
        const eventAt = Number.isNaN(occurredAt.getTime())
            ? new Date()
            : occurredAt;
        const data = await this.prisma.studentAppEvent.create({
            data: {
                studentId,
                eventType,
                occurredAt: eventAt,
                eventDate: (0, date_util_1.dateOnly)(eventAt),
                payload: (input.payload ?? {}),
            },
        });
        return { success: true, data, meta: {} };
    }
    async getStudentPreferences(studentId) {
        const setting = await this.prisma.appSetting.findUnique({
            where: { settingKey: this.preferenceKey(studentId) },
        });
        const value = setting?.settingValue ?? {};
        const targetUniversityMediaId = typeof value.targetUniversityMediaId === 'string'
            ? value.targetUniversityMediaId
            : null;
        const homeBackgroundMediaId = typeof value.homeBackgroundMediaId === 'string'
            ? value.homeBackgroundMediaId
            : null;
        const checkInBackgroundMediaId = typeof value.checkInBackgroundMediaId === 'string'
            ? value.checkInBackgroundMediaId
            : null;
        const mediaIds = [
            targetUniversityMediaId,
            homeBackgroundMediaId,
            checkInBackgroundMediaId,
        ].filter((id) => Boolean(id));
        const media = mediaIds.length
            ? await this.prisma.mediaAsset.findMany({
                where: { studentId, id: { in: mediaIds } },
            })
            : [];
        const mediaById = new Map(media.map((item) => [item.id, item]));
        return {
            notificationEnabled: value.notificationEnabled !== false,
            targetUniversityName: typeof value.targetUniversityName === 'string'
                ? value.targetUniversityName
                : '',
            targetUniversityMediaId,
            targetUniversityMedia: targetUniversityMediaId
                ? (mediaById.get(targetUniversityMediaId) ?? null)
                : null,
            homeBackgroundMediaId,
            homeBackgroundMedia: homeBackgroundMediaId
                ? (mediaById.get(homeBackgroundMediaId) ?? null)
                : null,
            checkInBackgroundMediaId,
            checkInBackgroundMedia: checkInBackgroundMediaId
                ? (mediaById.get(checkInBackgroundMediaId) ?? null)
                : null,
            themePreset: typeof value.themePreset === 'string' ? value.themePreset : 'default',
            focusModeEnabled: value.focusModeEnabled === true,
            tvGoalConsent: value.tvGoalConsent === true,
            tvGoalApprovalStatus: typeof value.tvGoalApprovalStatus === 'string'
                ? value.tvGoalApprovalStatus
                : 'NOT_REQUESTED',
            tvGoalReviewedAt: typeof value.tvGoalReviewedAt === 'string'
                ? value.tvGoalReviewedAt
                : null,
            tvGoalReviewedBy: typeof value.tvGoalReviewedBy === 'string'
                ? value.tvGoalReviewedBy
                : null,
            tvGoalReviewMemo: typeof value.tvGoalReviewMemo === 'string'
                ? value.tvGoalReviewMemo
                : null,
            dailyMissionReminderEnabled: value.dailyMissionReminderEnabled !== false,
            dailyMissionReminderTime: typeof value.dailyMissionReminderTime === 'string'
                ? value.dailyMissionReminderTime
                : '20:00',
        };
    }
    async ensureTodayDailyMission(studentId) {
        const today = (0, date_util_1.dateOnly)();
        const existing = await this.prisma.studentDailyMission.findUnique({
            where: { studentId_missionDate: { studentId, missionDate: today } },
            include: { template: true },
        });
        if (existing)
            return existing;
        return this.createOrRefreshTodayDailyMission(studentId);
    }
    async createOrRefreshTodayDailyMission(studentId) {
        const today = (0, date_util_1.dateOnly)();
        const student = await this.prisma.student.findUnique({
            where: { id: studentId },
            include: { grade: true, class: true },
        });
        if (!student) {
            throw new common_1.NotFoundException('학생을 찾을 수 없습니다.');
        }
        const [roadmap, template] = await Promise.all([
            this.activeRoadmap(studentId),
            this.findDailyMissionTemplate(student.gradeId, student.classId),
        ]);
        const currentRoadmapMission = roadmap?.missions.find((mission) => mission.weekStartDate.getTime() === (0, date_util_1.weekStart)(today).getTime()) ??
            roadmap?.missions[0] ??
            null;
        const roadmapSubjects = this.stringArray(currentRoadmapMission?.focusSubjects);
        const subjectName = roadmapSubjects[0] ?? template?.subjectName ?? '공부';
        const targetMinutes = Math.max(30, Math.min(240, Math.round((currentRoadmapMission?.targetMinutes ??
            template?.targetMinutes ??
            60) / (roadmapSubjects.length > 1 ? roadmapSubjects.length : 1))));
        const source = currentRoadmapMission && template
            ? client_1.DailyMissionSource.MIXED
            : currentRoadmapMission
                ? client_1.DailyMissionSource.ROADMAP
                : client_1.DailyMissionSource.TEMPLATE;
        const title = template?.title ??
            (currentRoadmapMission
                ? `${subjectName} ${targetMinutes}분 집중`
                : '오늘 공부 루틴 완료');
        return this.prisma.studentDailyMission.upsert({
            where: { studentId_missionDate: { studentId, missionDate: today } },
            create: {
                studentId,
                missionDate: today,
                title,
                subjectName,
                targetMinutes,
                source,
                templateId: template?.id ?? null,
                roadmapMissionId: currentRoadmapMission?.id ?? null,
            },
            update: {
                title,
                subjectName,
                targetMinutes,
                source,
                templateId: template?.id ?? null,
                roadmapMissionId: currentRoadmapMission?.id ?? null,
            },
            include: { template: true },
        });
    }
    async findDailyMissionTemplate(gradeId, classId) {
        const scope = [
            { gradeId: null, classId: null },
        ];
        if (gradeId)
            scope.unshift({ gradeId, classId: null });
        if (classId)
            scope.unshift({ classId });
        return this.prisma.dailyMissionTemplate.findFirst({
            where: {
                isActive: true,
                OR: scope,
            },
            orderBy: [
                { classId: 'desc' },
                { gradeId: 'desc' },
                { sortOrder: 'asc' },
                { createdAt: 'asc' },
            ],
        });
    }
    async syncDailyMissionCompletion(missionId, studentId) {
        const mission = await this.prisma.studentDailyMission.findFirst({
            where: { id: missionId, studentId },
            include: { template: true },
        });
        if (!mission || mission.status === 'COMPLETED') {
            return mission;
        }
        if (mission.missionDate < (0, date_util_1.dateOnly)()) {
            return this.prisma.studentDailyMission.update({
                where: { id: mission.id },
                data: { status: 'EXPIRED' },
                include: { template: true },
            });
        }
        const [metric, completedPlan] = await Promise.all([
            this.prisma.dailyStudentMetric.findUnique({
                where: {
                    studentId_metricDate: {
                        studentId,
                        metricDate: mission.missionDate,
                    },
                },
            }),
            this.prisma.studyPlan.findFirst({
                where: {
                    studentId,
                    planDate: mission.missionDate,
                    subjectName: mission.subjectName,
                    status: 'COMPLETED',
                },
            }),
        ]);
        if ((metric?.studyMinutes ?? 0) >= mission.targetMinutes || completedPlan) {
            return this.prisma.studentDailyMission.update({
                where: { id: mission.id },
                data: {
                    status: 'COMPLETED',
                    completedAt: new Date(),
                    completionMethod: completedPlan ? 'PLAN_AUTO' : 'STUDY_TIME_AUTO',
                },
                include: { template: true },
            });
        }
        return mission;
    }
    serializeDailyMission(mission, preferences) {
        return {
            id: mission.id,
            missionDate: mission.missionDate.toISOString(),
            title: mission.title,
            subjectName: mission.subjectName,
            targetMinutes: mission.targetMinutes,
            status: mission.status,
            source: mission.source,
            completedAt: mission.completedAt?.toISOString() ?? null,
            completionMethod: mission.completionMethod,
            template: mission.template
                ? {
                    id: mission.template.id,
                    title: mission.template.title,
                    subjectName: mission.template.subjectName,
                }
                : null,
            reminder: {
                enabled: preferences.dailyMissionReminderEnabled,
                time: preferences.dailyMissionReminderTime,
            },
        };
    }
    async activeRoadmap(studentId) {
        return this.prisma.studentGoalRoadmap.findFirst({
            where: { studentId, status: 'ACTIVE' },
            include: {
                milestones: { orderBy: { sortOrder: 'asc' } },
                missions: { orderBy: { weekStartDate: 'desc' }, take: 8 },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async ensureActiveRoadmap(studentId) {
        const existing = await this.activeRoadmap(studentId);
        if (existing)
            return existing;
        const preferences = await this.getStudentPreferences(studentId);
        return this.prisma.studentGoalRoadmap.create({
            data: {
                studentId,
                targetName: preferences.targetUniversityName || '목표',
                targetDate: (0, date_util_1.dateOnly)(new Date(Date.now() + 100 * 24 * 60 * 60 * 1000)),
            },
            include: {
                milestones: { orderBy: { sortOrder: 'asc' } },
                missions: { orderBy: { weekStartDate: 'desc' }, take: 8 },
            },
        });
    }
    serializeRoadmap(roadmap) {
        if (!roadmap) {
            return {
                roadmap: null,
                milestones: [],
                currentMission: null,
                daysLeft: null,
                progressPercent: 0,
            };
        }
        const today = (0, date_util_1.dateOnly)();
        const totalMs = roadmap.targetDate.getTime() - roadmap.createdAt.getTime();
        const leftMs = roadmap.targetDate.getTime() - today.getTime();
        const progressPercent = totalMs <= 0
            ? 0
            : Math.max(0, Math.min(100, Number((((totalMs - leftMs) / totalMs) * 100).toFixed(1))));
        const currentWeek = (0, date_util_1.weekStart)(today);
        const currentMission = roadmap.missions.find((mission) => mission.weekStartDate.getTime() === currentWeek.getTime()) ??
            roadmap.missions[0] ??
            null;
        return {
            roadmap: {
                id: roadmap.id,
                targetName: roadmap.targetName,
                targetDate: roadmap.targetDate.toISOString(),
                status: roadmap.status,
                reminderEnabled: roadmap.reminderEnabled,
                reminderTime: roadmap.reminderTime,
            },
            milestones: roadmap.milestones.map((item) => ({
                id: item.id,
                title: item.title,
                periodStart: item.periodStart.toISOString(),
                periodEnd: item.periodEnd.toISOString(),
                targetMinutes: item.targetMinutes,
                focusSubjects: this.stringArray(item.focusSubjects),
            })),
            currentMission: currentMission
                ? {
                    id: currentMission.id,
                    title: currentMission.title,
                    description: currentMission.description,
                    weekStartDate: currentMission.weekStartDate.toISOString(),
                    targetMinutes: currentMission.targetMinutes,
                    status: currentMission.status,
                    focusSubjects: this.stringArray(currentMission.focusSubjects),
                }
                : null,
            daysLeft: Math.ceil(Math.max(0, leftMs) / (24 * 60 * 60 * 1000)),
            progressPercent,
        };
    }
    async syncMissionStatus(studentId, roadmapId) {
        const currentWeek = (0, date_util_1.weekStart)();
        const weeklyMetric = await this.prisma.weeklyStudentMetric.findFirst({
            where: { studentId, weekStartDate: currentWeek },
        });
        const missions = await this.prisma.roadmapMission.findMany({
            where: {
                studentId,
                roadmapId,
                status: { in: ['ACCEPTED', 'RECOMMENDED'] },
            },
        });
        await Promise.all(missions.map((mission) => {
            if (mission.status === 'ACCEPTED' &&
                weeklyMetric &&
                weeklyMetric.studyMinutes >= mission.targetMinutes) {
                return this.prisma.roadmapMission.update({
                    where: { id: mission.id },
                    data: { status: 'COMPLETED', completedAt: new Date() },
                });
            }
            if (mission.weekStartDate < currentWeek) {
                return this.prisma.roadmapMission.update({
                    where: { id: mission.id },
                    data: { status: 'EXPIRED' },
                });
            }
            return Promise.resolve(null);
        }));
    }
    async roadmapRecommendation(studentId) {
        const [logs, dailyMetrics] = await Promise.all([
            this.prisma.studyLog.groupBy({
                by: ['subjectName'],
                where: { studentId },
                _sum: { studyMinutes: true },
                orderBy: { _sum: { studyMinutes: 'asc' } },
                take: 3,
            }),
            this.prisma.dailyStudentMetric.findMany({
                where: { studentId },
                orderBy: { metricDate: 'desc' },
                take: 7,
            }),
        ]);
        const focusSubjects = logs
            .map((item) => item.subjectName)
            .filter(Boolean)
            .slice(0, 3);
        while (focusSubjects.length < 3) {
            focusSubjects.push(['국어', '수학', '영어'][focusSubjects.length]);
        }
        const avgMinutes = dailyMetrics.length === 0
            ? 180
            : Math.round(dailyMetrics.reduce((sum, item) => sum + item.studyMinutes, 0) /
                dailyMetrics.length);
        return {
            focusSubjects,
            targetMinutes: Math.min(480, Math.max(180, Math.round(avgMinutes * 1.15))),
        };
    }
    buildMilestones(roadmapId, start, target, targetMinutes, focusSubjects) {
        const items = [];
        const cursor = new Date(start);
        cursor.setUTCDate(1);
        let order = 0;
        while (cursor <= target && order < 12) {
            const periodStart = order === 0 ? start : (0, date_util_1.dateOnly)(cursor);
            const periodEnd = (0, date_util_1.dateOnly)(new Date(Date.UTC(cursor.getUTCFullYear(), cursor.getUTCMonth() + 1, 0)));
            items.push({
                roadmapId,
                title: `${cursor.getUTCMonth() + 1}월 집중 구간`,
                periodStart,
                periodEnd: periodEnd > target ? target : periodEnd,
                targetMinutes: targetMinutes * 6,
                focusSubjects: focusSubjects,
                sortOrder: order,
            });
            cursor.setUTCMonth(cursor.getUTCMonth() + 1);
            order += 1;
        }
        return items;
    }
    normalizeReminderTime(value) {
        if (!value)
            return '20:00';
        return /^([01]\d|2[0-3]):[0-5]\d$/.test(value) ? value : '20:00';
    }
    stringArray(value) {
        return Array.isArray(value)
            ? value.filter((item) => typeof item === 'string')
            : [];
    }
    async recordFocusEvent(studentId, input) {
        const occurredAt = input.occurredAt
            ? new Date(input.occurredAt)
            : new Date();
        const eventAt = Number.isNaN(occurredAt.getTime())
            ? new Date()
            : occurredAt;
        const metricDate = (0, date_util_1.dateOnly)(eventAt);
        const eventType = this.normalizeFocusEventType(input.eventType);
        const studySessionId = input.studySessionId ?? input.sessionId ?? null;
        const durationSeconds = this.normalizeDurationSeconds(input.durationSeconds);
        const data = await this.prisma.studentFocusEvent.create({
            data: {
                studentId,
                studySessionId,
                eventType,
                eventDate: metricDate,
                occurredAt: eventAt,
                durationSeconds,
            },
        });
        const isExit = eventType === client_1.FocusEventType.APP_EXIT;
        const isReturn = eventType === client_1.FocusEventType.APP_RETURN;
        const awaySeconds = isReturn ? (durationSeconds ?? 0) : 0;
        const metric = await this.prisma.studentFocusMetric.upsert({
            where: { studentId_metricDate: { studentId, metricDate } },
            create: {
                studentId,
                metricDate,
                eventCount: isExit ? 1 : 0,
                returnCount: isReturn ? 1 : 0,
                totalAwaySeconds: awaySeconds,
                longestAwaySeconds: awaySeconds,
                lastEventAt: eventAt,
                lastSessionId: studySessionId,
            },
            update: {
                eventCount: isExit ? { increment: 1 } : undefined,
                returnCount: isReturn ? { increment: 1 } : undefined,
                totalAwaySeconds: isReturn ? { increment: awaySeconds } : undefined,
                longestAwaySeconds: isReturn ? { increment: 0 } : undefined,
                lastEventAt: eventAt,
                lastSessionId: studySessionId,
            },
        });
        if (isReturn && awaySeconds > metric.longestAwaySeconds) {
            await this.prisma.studentFocusMetric.update({
                where: { id: metric.id },
                data: { longestAwaySeconds: awaySeconds },
            });
        }
        this.events.emit({
            channel: 'focus',
            event: 'focus.changed',
            payload: {
                studentId,
                eventType,
                metricDate: metricDate.toISOString(),
                eventCount: metric.eventCount,
            },
        });
        return { success: true, data, meta: {} };
    }
    normalizeFocusEventType(value) {
        return value &&
            Object.values(client_1.FocusEventType).includes(value)
            ? value
            : client_1.FocusEventType.APP_EXIT;
    }
    normalizeDurationSeconds(value) {
        if (!Number.isFinite(value))
            return null;
        return Math.max(0, Math.min(86_400, Math.floor(value)));
    }
    async assertOwnedMedia(studentId, refs) {
        const ids = refs
            .map(([id]) => id)
            .filter((id) => Boolean(id));
        if (ids.length === 0)
            return;
        const assets = await this.prisma.mediaAsset.findMany({
            where: { studentId, id: { in: ids } },
        });
        const byId = new Map(assets.map((asset) => [asset.id, asset.kind]));
        for (const [id, kind] of refs) {
            if (!id)
                continue;
            if (byId.get(id) !== kind) {
                throw new common_1.NotFoundException('선택한 미디어를 찾을 수 없습니다.');
            }
        }
    }
    preferenceKey(studentId) {
        return `student:${studentId}:preferences`;
    }
    async deleteReplacedMedia(studentId, current, next) {
        const currentIds = [
            current.targetUniversityMediaId,
            current.homeBackgroundMediaId,
            current.checkInBackgroundMediaId,
        ].filter((id) => Boolean(id));
        const nextIds = new Set([
            next.targetUniversityMediaId,
            next.homeBackgroundMediaId,
            next.checkInBackgroundMediaId,
        ].filter((id) => Boolean(id)));
        await Promise.all(currentIds
            .filter((id) => !nextIds.has(id))
            .map((id) => this.mediaService.deleteStudentMediaQuiet(studentId, id)));
    }
};
exports.StudentsService = StudentsService;
exports.StudentsService = StudentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        events_service_1.EventsService,
        media_service_1.MediaService])
], StudentsService);
//# sourceMappingURL=students.service.js.map