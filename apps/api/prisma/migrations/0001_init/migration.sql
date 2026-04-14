-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('STUDENT', 'ADMIN', 'DIRECTOR', 'DISPLAY');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'DELETED');

-- CreateEnum
CREATE TYPE "EnrollmentStatus" AS ENUM ('ACTIVE', 'LEAVE', 'GRADUATED');

-- CreateEnum
CREATE TYPE "SeatStatus" AS ENUM ('AVAILABLE', 'OCCUPIED', 'RESERVED', 'LOCKED');

-- CreateEnum
CREATE TYPE "DeviceType" AS ENUM ('TABLET', 'MOBILE', 'WEB', 'TV');

-- CreateEnum
CREATE TYPE "DeviceStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "SessionStatus" AS ENUM ('ACTIVE', 'EXPIRED', 'LOGGED_OUT', 'REVOKED');

-- CreateEnum
CREATE TYPE "LoginMethod" AS ENUM ('STUDENT_NO_NAME', 'QR', 'AUTO', 'ADMIN_PASSWORD');

-- CreateEnum
CREATE TYPE "QrTokenType" AS ENUM ('STUDENT_LOGIN', 'SEAT_LOGIN');

-- CreateEnum
CREATE TYPE "AttendanceFlag" AS ENUM ('NONE', 'LATE', 'EARLY_LEAVE');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('NOT_CHECKED_IN', 'CHECKED_IN', 'CHECKED_OUT', 'ABSENT');

-- CreateEnum
CREATE TYPE "SeatAssignmentType" AS ENUM ('FIXED', 'TEMPORARY', 'DAILY');

-- CreateEnum
CREATE TYPE "SeatChangeRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "StudyPlanPriority" AS ENUM ('HIGH', 'MEDIUM', 'LOW');

-- CreateEnum
CREATE TYPE "StudyPlanStatus" AS ENUM ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "StudySessionStatus" AS ENUM ('READY', 'ACTIVE', 'PAUSED', 'COMPLETED', 'AUTO_CLOSED');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('NOTICE', 'ABSENCE', 'LEAVE_TIME', 'BREAK_OVER', 'GOAL_SHORTFALL');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'PUSH', 'TV');

-- CreateEnum
CREATE TYPE "NotificationTargetScope" AS ENUM ('STUDENT', 'CLASS', 'GROUP', 'ALL', 'ADMIN');

-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('DRAFT', 'SCHEDULED', 'SENT', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DeliveryStatus" AS ENUM ('PENDING', 'SENT', 'FAILED', 'READ');

-- CreateEnum
CREATE TYPE "RankingType" AS ENUM ('STUDY_TIME', 'STUDY_VOLUME', 'ATTENDANCE_STREAK');

-- CreateEnum
CREATE TYPE "RankingPeriodType" AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "BadgeType" AS ENUM ('ATTENDANCE', 'STUDY_TIME', 'ACHIEVEMENT', 'EVENT');

-- CreateEnum
CREATE TYPE "DisplayScreen" AS ENUM ('RANKING', 'STATUS', 'MOTIVATION');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "role" "UserRole" NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "name" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(30),
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "students" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "studentNo" VARCHAR(50) NOT NULL,
    "gradeId" UUID,
    "classId" UUID,
    "groupId" UUID,
    "assignedSeatId" UUID,
    "enrollmentStatus" "EnrollmentStatus" NOT NULL DEFAULT 'ACTIVE',
    "joinedAt" TIMESTAMP(3),
    "memo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admin_users" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "adminType" "UserRole" NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "passwordHash" VARCHAR(255) NOT NULL,
    "lastPasswordChangedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "admin_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "grades" (
    "id" UUID NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "sortOrder" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "grades_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "classes" (
    "id" UUID NOT NULL,
    "gradeId" UUID,
    "name" VARCHAR(100) NOT NULL,
    "sortOrder" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "classes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "groups" (
    "id" UUID NOT NULL,
    "classId" UUID,
    "name" VARCHAR(100) NOT NULL,
    "sortOrder" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "seats" (
    "id" UUID NOT NULL,
    "seatNo" VARCHAR(30) NOT NULL,
    "zone" VARCHAR(50),
    "status" "SeatStatus" NOT NULL DEFAULT 'AVAILABLE',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "currentStudentId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "seats_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" UUID NOT NULL,
    "deviceCode" VARCHAR(100) NOT NULL,
    "deviceType" "DeviceType" NOT NULL,
    "seatId" UUID,
    "status" "DeviceStatus" NOT NULL DEFAULT 'ACTIVE',
    "lastSeenAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_sessions" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "studentId" UUID,
    "deviceId" UUID,
    "loginMethod" "LoginMethod" NOT NULL,
    "sessionStatus" "SessionStatus" NOT NULL DEFAULT 'ACTIVE',
    "duplicateReplaced" BOOLEAN NOT NULL DEFAULT false,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastActivityAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qr_login_tokens" (
    "id" UUID NOT NULL,
    "studentId" UUID,
    "deviceId" UUID,
    "token" VARCHAR(255) NOT NULL,
    "tokenType" "QrTokenType" NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "qr_login_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendances" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "attendanceDate" DATE NOT NULL,
    "checkInAt" TIMESTAMP(3),
    "checkOutAt" TIMESTAMP(3),
    "stayMinutes" INTEGER NOT NULL DEFAULT 0,
    "lateStatus" "AttendanceFlag" NOT NULL DEFAULT 'NONE',
    "earlyLeaveStatus" "AttendanceFlag" NOT NULL DEFAULT 'NONE',
    "attendanceStatus" "AttendanceStatus" NOT NULL DEFAULT 'NOT_CHECKED_IN',
    "seatId" UUID,
    "createdById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "attendances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "seat_assignments" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "seatId" UUID NOT NULL,
    "assignmentType" "SeatAssignmentType" NOT NULL,
    "assignedById" UUID,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" TIMESTAMP(3),
    "isCurrent" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "seat_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "seat_change_requests" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "fromSeatId" UUID,
    "toSeatId" UUID NOT NULL,
    "requestStatus" "SeatChangeRequestStatus" NOT NULL DEFAULT 'PENDING',
    "requestedReason" TEXT,
    "reviewedById" UUID,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "seat_change_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "study_plans" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "planDate" DATE NOT NULL,
    "subjectName" VARCHAR(100) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "targetMinutes" INTEGER NOT NULL DEFAULT 0,
    "priority" "StudyPlanPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "StudyPlanStatus" NOT NULL DEFAULT 'PLANNED',
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "study_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "study_sessions" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "attendanceId" UUID,
    "linkedPlanId" UUID,
    "sessionDate" DATE NOT NULL,
    "status" "StudySessionStatus" NOT NULL DEFAULT 'READY',
    "startedAt" TIMESTAMP(3),
    "endedAt" TIMESTAMP(3),
    "studyMinutes" INTEGER NOT NULL DEFAULT 0,
    "breakMinutes" INTEGER NOT NULL DEFAULT 0,
    "autoClosedReason" VARCHAR(50),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "study_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "study_breaks" (
    "id" UUID NOT NULL,
    "studySessionId" UUID NOT NULL,
    "startedAt" TIMESTAMP(3) NOT NULL,
    "endedAt" TIMESTAMP(3),
    "breakMinutes" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "study_breaks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "study_logs" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "planId" UUID,
    "studySessionId" UUID,
    "logDate" DATE NOT NULL,
    "subjectName" VARCHAR(100) NOT NULL,
    "pagesCompleted" INTEGER NOT NULL DEFAULT 0,
    "problemsSolved" INTEGER NOT NULL DEFAULT 0,
    "progressPercent" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "isCompleted" BOOLEAN NOT NULL DEFAULT false,
    "memo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "study_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "daily_student_metrics" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "metricDate" DATE NOT NULL,
    "attendanceMinutes" INTEGER NOT NULL DEFAULT 0,
    "studyMinutes" INTEGER NOT NULL DEFAULT 0,
    "breakMinutes" INTEGER NOT NULL DEFAULT 0,
    "targetMinutes" INTEGER NOT NULL DEFAULT 0,
    "achievedRate" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "pagesCompleted" INTEGER NOT NULL DEFAULT 0,
    "problemsSolved" INTEGER NOT NULL DEFAULT 0,
    "studySessionCount" INTEGER NOT NULL DEFAULT 0,
    "attendanceStatus" "AttendanceStatus" NOT NULL DEFAULT 'ABSENT',
    "streakDays" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "daily_student_metrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weekly_student_metrics" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "weekStartDate" DATE NOT NULL,
    "studyMinutes" INTEGER NOT NULL DEFAULT 0,
    "attendanceDays" INTEGER NOT NULL DEFAULT 0,
    "targetMinutes" INTEGER NOT NULL DEFAULT 0,
    "achievedRate" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "pagesCompleted" INTEGER NOT NULL DEFAULT 0,
    "problemsSolved" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "weekly_student_metrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "monthly_student_metrics" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "monthKey" VARCHAR(7) NOT NULL,
    "studyMinutes" INTEGER NOT NULL DEFAULT 0,
    "attendanceDays" INTEGER NOT NULL DEFAULT 0,
    "targetMinutes" INTEGER NOT NULL DEFAULT 0,
    "achievedRate" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "pagesCompleted" INTEGER NOT NULL DEFAULT 0,
    "problemsSolved" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "monthly_student_metrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_snapshots" (
    "id" UUID NOT NULL,
    "rankingType" "RankingType" NOT NULL,
    "periodType" "RankingPeriodType" NOT NULL,
    "periodKey" VARCHAR(20) NOT NULL,
    "generatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ranking_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_snapshot_items" (
    "id" UUID NOT NULL,
    "rankingSnapshotId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "rankNo" INTEGER NOT NULL,
    "score" DECIMAL(12,2) NOT NULL,
    "subScore1" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "subScore2" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ranking_snapshot_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "badges" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "badgeType" "BadgeType" NOT NULL,
    "iconUrl" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "badges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_badges" (
    "id" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "badgeId" UUID NOT NULL,
    "awardedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_badges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "notificationType" "NotificationType" NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "body" TEXT NOT NULL,
    "targetScope" "NotificationTargetScope" NOT NULL,
    "createdById" UUID,
    "scheduledAt" TIMESTAMP(3),
    "sentAt" TIMESTAMP(3),
    "status" "NotificationStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_receipts" (
    "id" UUID NOT NULL,
    "notificationId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deliveryStatus" "DeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "deliveredAt" TIMESTAMP(3),
    "readAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admin_audit_logs" (
    "id" UUID NOT NULL,
    "actorUserId" UUID NOT NULL,
    "actionType" VARCHAR(50) NOT NULL,
    "targetType" VARCHAR(50) NOT NULL,
    "targetId" UUID,
    "beforeData" JSONB,
    "afterData" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "admin_audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "app_settings" (
    "id" UUID NOT NULL,
    "settingKey" VARCHAR(100) NOT NULL,
    "settingValue" JSONB NOT NULL,
    "updatedById" UUID,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "app_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_policies" (
    "id" UUID NOT NULL,
    "policyName" VARCHAR(100) NOT NULL,
    "lateCutoffTime" VARCHAR(10) NOT NULL,
    "earlyLeaveCutoffTime" VARCHAR(10) NOT NULL,
    "autoCheckoutEnabled" BOOLEAN NOT NULL DEFAULT false,
    "autoCheckoutAfterMinutes" INTEGER,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_policies" (
    "id" UUID NOT NULL,
    "policyName" VARCHAR(100) NOT NULL,
    "studyTimeWeight" DECIMAL(8,2) NOT NULL,
    "studyVolumeWeight" DECIMAL(8,2) NOT NULL,
    "attendanceWeight" DECIMAL(8,2) NOT NULL,
    "tieBreakerRule" JSONB NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ranking_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tv_display_settings" (
    "id" UUID NOT NULL,
    "activeScreen" "DisplayScreen" NOT NULL DEFAULT 'RANKING',
    "rotationEnabled" BOOLEAN NOT NULL DEFAULT true,
    "rotationIntervalSeconds" INTEGER NOT NULL DEFAULT 30,
    "displayOptions" JSONB NOT NULL,
    "updatedById" UUID,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tv_display_settings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "students_userId_key" ON "students"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "students_studentNo_key" ON "students"("studentNo");

-- CreateIndex
CREATE INDEX "students_classId_idx" ON "students"("classId");

-- CreateIndex
CREATE INDEX "students_groupId_idx" ON "students"("groupId");

-- CreateIndex
CREATE INDEX "students_assignedSeatId_idx" ON "students"("assignedSeatId");

-- CreateIndex
CREATE UNIQUE INDEX "admin_users_userId_key" ON "admin_users"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "admin_users_email_key" ON "admin_users"("email");

-- CreateIndex
CREATE INDEX "classes_gradeId_idx" ON "classes"("gradeId");

-- CreateIndex
CREATE INDEX "groups_classId_idx" ON "groups"("classId");

-- CreateIndex
CREATE UNIQUE INDEX "seats_seatNo_key" ON "seats"("seatNo");

-- CreateIndex
CREATE INDEX "seats_status_idx" ON "seats"("status");

-- CreateIndex
CREATE INDEX "seats_currentStudentId_idx" ON "seats"("currentStudentId");

-- CreateIndex
CREATE UNIQUE INDEX "devices_deviceCode_key" ON "devices"("deviceCode");

-- CreateIndex
CREATE INDEX "auth_sessions_userId_idx" ON "auth_sessions"("userId");

-- CreateIndex
CREATE INDEX "auth_sessions_studentId_idx" ON "auth_sessions"("studentId");

-- CreateIndex
CREATE INDEX "auth_sessions_sessionStatus_idx" ON "auth_sessions"("sessionStatus");

-- CreateIndex
CREATE INDEX "auth_sessions_lastActivityAt_idx" ON "auth_sessions"("lastActivityAt");

-- CreateIndex
CREATE UNIQUE INDEX "qr_login_tokens_token_key" ON "qr_login_tokens"("token");

-- CreateIndex
CREATE INDEX "attendances_attendanceDate_idx" ON "attendances"("attendanceDate");

-- CreateIndex
CREATE INDEX "attendances_seatId_idx" ON "attendances"("seatId");

-- CreateIndex
CREATE INDEX "attendances_studentId_attendanceStatus_idx" ON "attendances"("studentId", "attendanceStatus");

-- CreateIndex
CREATE UNIQUE INDEX "attendances_studentId_attendanceDate_key" ON "attendances"("studentId", "attendanceDate");

-- CreateIndex
CREATE INDEX "seat_assignments_studentId_idx" ON "seat_assignments"("studentId");

-- CreateIndex
CREATE INDEX "seat_assignments_seatId_idx" ON "seat_assignments"("seatId");

-- CreateIndex
CREATE INDEX "seat_assignments_isCurrent_idx" ON "seat_assignments"("isCurrent");

-- CreateIndex
CREATE INDEX "study_plans_studentId_planDate_idx" ON "study_plans"("studentId", "planDate");

-- CreateIndex
CREATE INDEX "study_plans_planDate_idx" ON "study_plans"("planDate");

-- CreateIndex
CREATE INDEX "study_plans_status_idx" ON "study_plans"("status");

-- CreateIndex
CREATE INDEX "study_sessions_studentId_sessionDate_idx" ON "study_sessions"("studentId", "sessionDate");

-- CreateIndex
CREATE INDEX "study_sessions_attendanceId_idx" ON "study_sessions"("attendanceId");

-- CreateIndex
CREATE INDEX "study_sessions_status_idx" ON "study_sessions"("status");

-- CreateIndex
CREATE INDEX "study_sessions_linkedPlanId_idx" ON "study_sessions"("linkedPlanId");

-- CreateIndex
CREATE INDEX "study_breaks_studySessionId_idx" ON "study_breaks"("studySessionId");

-- CreateIndex
CREATE INDEX "study_logs_studentId_logDate_idx" ON "study_logs"("studentId", "logDate");

-- CreateIndex
CREATE INDEX "study_logs_planId_idx" ON "study_logs"("planId");

-- CreateIndex
CREATE INDEX "study_logs_studySessionId_idx" ON "study_logs"("studySessionId");

-- CreateIndex
CREATE INDEX "daily_student_metrics_metricDate_idx" ON "daily_student_metrics"("metricDate");

-- CreateIndex
CREATE INDEX "daily_student_metrics_studentId_idx" ON "daily_student_metrics"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "daily_student_metrics_studentId_metricDate_key" ON "daily_student_metrics"("studentId", "metricDate");

-- CreateIndex
CREATE UNIQUE INDEX "weekly_student_metrics_studentId_weekStartDate_key" ON "weekly_student_metrics"("studentId", "weekStartDate");

-- CreateIndex
CREATE UNIQUE INDEX "monthly_student_metrics_studentId_monthKey_key" ON "monthly_student_metrics"("studentId", "monthKey");

-- CreateIndex
CREATE INDEX "ranking_snapshots_rankingType_periodType_periodKey_idx" ON "ranking_snapshots"("rankingType", "periodType", "periodKey");

-- CreateIndex
CREATE INDEX "ranking_snapshot_items_studentId_idx" ON "ranking_snapshot_items"("studentId");

-- CreateIndex
CREATE INDEX "ranking_snapshot_items_rankNo_idx" ON "ranking_snapshot_items"("rankNo");

-- CreateIndex
CREATE UNIQUE INDEX "ranking_snapshot_items_rankingSnapshotId_studentId_key" ON "ranking_snapshot_items"("rankingSnapshotId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "ranking_snapshot_items_rankingSnapshotId_rankNo_key" ON "ranking_snapshot_items"("rankingSnapshotId", "rankNo");

-- CreateIndex
CREATE UNIQUE INDEX "badges_code_key" ON "badges"("code");

-- CreateIndex
CREATE INDEX "student_badges_studentId_idx" ON "student_badges"("studentId");

-- CreateIndex
CREATE INDEX "student_badges_badgeId_idx" ON "student_badges"("badgeId");

-- CreateIndex
CREATE INDEX "notifications_notificationType_idx" ON "notifications"("notificationType");

-- CreateIndex
CREATE INDEX "notifications_status_idx" ON "notifications"("status");

-- CreateIndex
CREATE INDEX "notifications_scheduledAt_idx" ON "notifications"("scheduledAt");

-- CreateIndex
CREATE INDEX "notification_receipts_notificationId_idx" ON "notification_receipts"("notificationId");

-- CreateIndex
CREATE INDEX "notification_receipts_userId_idx" ON "notification_receipts"("userId");

-- CreateIndex
CREATE INDEX "notification_receipts_deliveryStatus_idx" ON "notification_receipts"("deliveryStatus");

-- CreateIndex
CREATE INDEX "admin_audit_logs_actorUserId_idx" ON "admin_audit_logs"("actorUserId");

-- CreateIndex
CREATE INDEX "admin_audit_logs_actionType_idx" ON "admin_audit_logs"("actionType");

-- CreateIndex
CREATE INDEX "admin_audit_logs_targetType_targetId_idx" ON "admin_audit_logs"("targetType", "targetId");

-- CreateIndex
CREATE UNIQUE INDEX "app_settings_settingKey_key" ON "app_settings"("settingKey");

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_gradeId_fkey" FOREIGN KEY ("gradeId") REFERENCES "grades"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_classId_fkey" FOREIGN KEY ("classId") REFERENCES "classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_assignedSeatId_fkey" FOREIGN KEY ("assignedSeatId") REFERENCES "seats"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admin_users" ADD CONSTRAINT "admin_users_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "classes" ADD CONSTRAINT "classes_gradeId_fkey" FOREIGN KEY ("gradeId") REFERENCES "grades"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_classId_fkey" FOREIGN KEY ("classId") REFERENCES "classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seats" ADD CONSTRAINT "seats_currentStudentId_fkey" FOREIGN KEY ("currentStudentId") REFERENCES "students"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "seats"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_sessions" ADD CONSTRAINT "auth_sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_sessions" ADD CONSTRAINT "auth_sessions_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_sessions" ADD CONSTRAINT "auth_sessions_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qr_login_tokens" ADD CONSTRAINT "qr_login_tokens_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qr_login_tokens" ADD CONSTRAINT "qr_login_tokens_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "seats"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seat_assignments" ADD CONSTRAINT "seat_assignments_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seat_assignments" ADD CONSTRAINT "seat_assignments_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "seats"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seat_change_requests" ADD CONSTRAINT "seat_change_requests_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seat_change_requests" ADD CONSTRAINT "seat_change_requests_fromSeatId_fkey" FOREIGN KEY ("fromSeatId") REFERENCES "seats"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seat_change_requests" ADD CONSTRAINT "seat_change_requests_toSeatId_fkey" FOREIGN KEY ("toSeatId") REFERENCES "seats"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_plans" ADD CONSTRAINT "study_plans_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_sessions" ADD CONSTRAINT "study_sessions_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_sessions" ADD CONSTRAINT "study_sessions_attendanceId_fkey" FOREIGN KEY ("attendanceId") REFERENCES "attendances"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_sessions" ADD CONSTRAINT "study_sessions_linkedPlanId_fkey" FOREIGN KEY ("linkedPlanId") REFERENCES "study_plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_breaks" ADD CONSTRAINT "study_breaks_studySessionId_fkey" FOREIGN KEY ("studySessionId") REFERENCES "study_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_logs" ADD CONSTRAINT "study_logs_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_logs" ADD CONSTRAINT "study_logs_planId_fkey" FOREIGN KEY ("planId") REFERENCES "study_plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "study_logs" ADD CONSTRAINT "study_logs_studySessionId_fkey" FOREIGN KEY ("studySessionId") REFERENCES "study_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_student_metrics" ADD CONSTRAINT "daily_student_metrics_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weekly_student_metrics" ADD CONSTRAINT "weekly_student_metrics_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monthly_student_metrics" ADD CONSTRAINT "monthly_student_metrics_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_snapshot_items" ADD CONSTRAINT "ranking_snapshot_items_rankingSnapshotId_fkey" FOREIGN KEY ("rankingSnapshotId") REFERENCES "ranking_snapshots"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_snapshot_items" ADD CONSTRAINT "ranking_snapshot_items_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_badges" ADD CONSTRAINT "student_badges_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_badges" ADD CONSTRAINT "student_badges_badgeId_fkey" FOREIGN KEY ("badgeId") REFERENCES "badges"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_receipts" ADD CONSTRAINT "notification_receipts_notificationId_fkey" FOREIGN KEY ("notificationId") REFERENCES "notifications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_receipts" ADD CONSTRAINT "notification_receipts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admin_audit_logs" ADD CONSTRAINT "admin_audit_logs_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "app_settings" ADD CONSTRAINT "app_settings_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_policies" ADD CONSTRAINT "attendance_policies_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_policies" ADD CONSTRAINT "ranking_policies_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tv_display_settings" ADD CONSTRAINT "tv_display_settings_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

