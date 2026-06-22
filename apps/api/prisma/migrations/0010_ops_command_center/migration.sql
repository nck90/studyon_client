CREATE TYPE "OpsTaskReasonType" AS ENUM ('NOT_CHECKED_IN', 'EARLY_LEAVE', 'DAILY_MISSION_INCOMPLETE', 'TARGET_SHORTFALL', 'FOCUS_INTERRUPTION');
CREATE TYPE "OpsTaskSeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH');
CREATE TYPE "OpsTaskStatus" AS ENUM ('OPEN', 'RESOLVED', 'DISMISSED');
CREATE TYPE "OpsTaskActionType" AS ENUM ('STUDENT_MESSAGE_SENT', 'PARENT_REPORT_CREATED', 'RESOLVED', 'DISMISSED');

CREATE TABLE "ops_tasks" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "taskDate" DATE NOT NULL,
  "reasonType" "OpsTaskReasonType" NOT NULL,
  "severity" "OpsTaskSeverity" NOT NULL DEFAULT 'MEDIUM',
  "status" "OpsTaskStatus" NOT NULL DEFAULT 'OPEN',
  "message" VARCHAR(255) NOT NULL,
  "sourceSnapshot" JSONB NOT NULL DEFAULT '{}',
  "resolvedById" UUID,
  "resolvedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ops_tasks_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ops_task_actions" (
  "id" UUID NOT NULL,
  "taskId" UUID NOT NULL,
  "actorUserId" UUID,
  "actionType" "OpsTaskActionType" NOT NULL,
  "payload" JSONB NOT NULL DEFAULT '{}',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ops_task_actions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "parent_action_reports" (
  "id" UUID NOT NULL,
  "taskId" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "tokenId" VARCHAR(64) NOT NULL,
  "message" VARCHAR(500) NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "viewedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "parent_action_reports_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ops_tasks_studentId_taskDate_reasonType_key" ON "ops_tasks"("studentId", "taskDate", "reasonType");
CREATE INDEX "ops_tasks_taskDate_status_idx" ON "ops_tasks"("taskDate", "status");
CREATE INDEX "ops_tasks_reasonType_severity_idx" ON "ops_tasks"("reasonType", "severity");
CREATE INDEX "ops_task_actions_taskId_createdAt_idx" ON "ops_task_actions"("taskId", "createdAt");
CREATE INDEX "ops_task_actions_actionType_idx" ON "ops_task_actions"("actionType");
CREATE UNIQUE INDEX "parent_action_reports_tokenId_key" ON "parent_action_reports"("tokenId");
CREATE INDEX "parent_action_reports_studentId_createdAt_idx" ON "parent_action_reports"("studentId", "createdAt");
CREATE INDEX "parent_action_reports_expiresAt_idx" ON "parent_action_reports"("expiresAt");

ALTER TABLE "ops_tasks"
  ADD CONSTRAINT "ops_tasks_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ops_tasks"
  ADD CONSTRAINT "ops_tasks_resolvedById_fkey"
  FOREIGN KEY ("resolvedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "ops_task_actions"
  ADD CONSTRAINT "ops_task_actions_taskId_fkey"
  FOREIGN KEY ("taskId") REFERENCES "ops_tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ops_task_actions"
  ADD CONSTRAINT "ops_task_actions_actorUserId_fkey"
  FOREIGN KEY ("actorUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "parent_action_reports"
  ADD CONSTRAINT "parent_action_reports_taskId_fkey"
  FOREIGN KEY ("taskId") REFERENCES "ops_tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "parent_action_reports"
  ADD CONSTRAINT "parent_action_reports_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
