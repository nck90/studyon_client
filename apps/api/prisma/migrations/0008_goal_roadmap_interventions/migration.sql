CREATE TYPE "GoalRoadmapStatus" AS ENUM ('ACTIVE', 'ARCHIVED');
CREATE TYPE "RoadmapMissionStatus" AS ENUM ('RECOMMENDED', 'ACCEPTED', 'COMPLETED', 'EXPIRED');
CREATE TYPE "InterventionReasonType" AS ENUM ('STREAK_BROKEN', 'TARGET_SHORTFALL', 'FOCUS_INTERRUPTION', 'MISSION_NOT_ACCEPTED');
CREATE TYPE "InterventionSeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH');
CREATE TYPE "InterventionQueueStatus" AS ENUM ('OPEN', 'RESOLVED', 'EXPIRED');
CREATE TYPE "InterventionActionType" AS ENUM ('MESSAGE_SENT', 'PLAN_RECOMMENDED');

CREATE TABLE "student_goal_roadmaps" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "targetName" VARCHAR(120) NOT NULL,
  "targetDate" DATE NOT NULL,
  "targetType" VARCHAR(40) NOT NULL DEFAULT 'CUSTOM',
  "status" "GoalRoadmapStatus" NOT NULL DEFAULT 'ACTIVE',
  "reminderEnabled" BOOLEAN NOT NULL DEFAULT true,
  "reminderTime" VARCHAR(5) NOT NULL DEFAULT '20:00',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "student_goal_roadmaps_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "roadmap_milestones" (
  "id" UUID NOT NULL,
  "roadmapId" UUID NOT NULL,
  "title" VARCHAR(160) NOT NULL,
  "periodStart" DATE NOT NULL,
  "periodEnd" DATE NOT NULL,
  "targetMinutes" INTEGER NOT NULL DEFAULT 0,
  "focusSubjects" JSONB NOT NULL DEFAULT '[]',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "roadmap_milestones_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "roadmap_missions" (
  "id" UUID NOT NULL,
  "roadmapId" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "weekStartDate" DATE NOT NULL,
  "title" VARCHAR(180) NOT NULL,
  "description" TEXT,
  "focusSubjects" JSONB NOT NULL DEFAULT '[]',
  "targetMinutes" INTEGER NOT NULL DEFAULT 0,
  "status" "RoadmapMissionStatus" NOT NULL DEFAULT 'RECOMMENDED',
  "acceptedAt" TIMESTAMP(3),
  "completedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "roadmap_missions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "intervention_queue_items" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "reasonType" "InterventionReasonType" NOT NULL,
  "reasonDate" DATE NOT NULL,
  "severity" "InterventionSeverity" NOT NULL DEFAULT 'MEDIUM',
  "status" "InterventionQueueStatus" NOT NULL DEFAULT 'OPEN',
  "message" VARCHAR(255) NOT NULL,
  "actionType" "InterventionActionType",
  "resolvedById" UUID,
  "resolvedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "intervention_queue_items_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "student_goal_roadmaps_studentId_status_idx" ON "student_goal_roadmaps"("studentId", "status");
CREATE INDEX "student_goal_roadmaps_targetDate_idx" ON "student_goal_roadmaps"("targetDate");
CREATE INDEX "roadmap_milestones_roadmapId_sortOrder_idx" ON "roadmap_milestones"("roadmapId", "sortOrder");
CREATE UNIQUE INDEX "roadmap_missions_studentId_weekStartDate_key" ON "roadmap_missions"("studentId", "weekStartDate");
CREATE INDEX "roadmap_missions_roadmapId_idx" ON "roadmap_missions"("roadmapId");
CREATE INDEX "roadmap_missions_status_idx" ON "roadmap_missions"("status");
CREATE UNIQUE INDEX "intervention_queue_items_studentId_reasonType_reasonDate_key" ON "intervention_queue_items"("studentId", "reasonType", "reasonDate");
CREATE INDEX "intervention_queue_items_status_reasonDate_idx" ON "intervention_queue_items"("status", "reasonDate");
CREATE INDEX "intervention_queue_items_studentId_idx" ON "intervention_queue_items"("studentId");

ALTER TABLE "student_goal_roadmaps"
  ADD CONSTRAINT "student_goal_roadmaps_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "roadmap_milestones"
  ADD CONSTRAINT "roadmap_milestones_roadmapId_fkey"
  FOREIGN KEY ("roadmapId") REFERENCES "student_goal_roadmaps"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "roadmap_missions"
  ADD CONSTRAINT "roadmap_missions_roadmapId_fkey"
  FOREIGN KEY ("roadmapId") REFERENCES "student_goal_roadmaps"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "roadmap_missions"
  ADD CONSTRAINT "roadmap_missions_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "intervention_queue_items"
  ADD CONSTRAINT "intervention_queue_items_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "intervention_queue_items"
  ADD CONSTRAINT "intervention_queue_items_resolvedById_fkey"
  FOREIGN KEY ("resolvedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
