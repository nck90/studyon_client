CREATE TYPE "DailyMissionStatus" AS ENUM ('ASSIGNED', 'COMPLETED', 'EXPIRED');
CREATE TYPE "DailyMissionSource" AS ENUM ('ROADMAP', 'TEMPLATE', 'MIXED');
CREATE TYPE "AppEventType" AS ENUM ('APP_OPEN', 'NOTIFICATION_OPEN', 'DAILY_MISSION_VIEW', 'DAILY_MISSION_COMPLETE');

CREATE TABLE "daily_mission_templates" (
  "id" UUID NOT NULL,
  "gradeId" UUID,
  "classId" UUID,
  "title" VARCHAR(160) NOT NULL,
  "subjectName" VARCHAR(80) NOT NULL,
  "targetMinutes" INTEGER NOT NULL DEFAULT 60,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "createdById" UUID,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "daily_mission_templates_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "student_daily_missions" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "missionDate" DATE NOT NULL,
  "title" VARCHAR(180) NOT NULL,
  "subjectName" VARCHAR(80) NOT NULL,
  "targetMinutes" INTEGER NOT NULL DEFAULT 60,
  "status" "DailyMissionStatus" NOT NULL DEFAULT 'ASSIGNED',
  "source" "DailyMissionSource" NOT NULL DEFAULT 'MIXED',
  "templateId" UUID,
  "roadmapMissionId" UUID,
  "completedAt" TIMESTAMP(3),
  "completionMethod" VARCHAR(40),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "student_daily_missions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "student_app_events" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "eventType" "AppEventType" NOT NULL,
  "eventDate" DATE NOT NULL,
  "occurredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "payload" JSONB,
  CONSTRAINT "student_app_events_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "daily_mission_templates_gradeId_classId_isActive_idx" ON "daily_mission_templates"("gradeId", "classId", "isActive");
CREATE INDEX "daily_mission_templates_isActive_sortOrder_idx" ON "daily_mission_templates"("isActive", "sortOrder");
CREATE UNIQUE INDEX "student_daily_missions_studentId_missionDate_key" ON "student_daily_missions"("studentId", "missionDate");
CREATE INDEX "student_daily_missions_missionDate_status_idx" ON "student_daily_missions"("missionDate", "status");
CREATE INDEX "student_daily_missions_templateId_idx" ON "student_daily_missions"("templateId");
CREATE INDEX "student_app_events_eventDate_eventType_idx" ON "student_app_events"("eventDate", "eventType");
CREATE INDEX "student_app_events_studentId_occurredAt_idx" ON "student_app_events"("studentId", "occurredAt");

ALTER TABLE "daily_mission_templates"
  ADD CONSTRAINT "daily_mission_templates_gradeId_fkey"
  FOREIGN KEY ("gradeId") REFERENCES "grades"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "daily_mission_templates"
  ADD CONSTRAINT "daily_mission_templates_classId_fkey"
  FOREIGN KEY ("classId") REFERENCES "classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "daily_mission_templates"
  ADD CONSTRAINT "daily_mission_templates_createdById_fkey"
  FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "student_daily_missions"
  ADD CONSTRAINT "student_daily_missions_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "student_daily_missions"
  ADD CONSTRAINT "student_daily_missions_templateId_fkey"
  FOREIGN KEY ("templateId") REFERENCES "daily_mission_templates"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "student_app_events"
  ADD CONSTRAINT "student_app_events_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
