CREATE TYPE "GuardianRelation" AS ENUM ('MOTHER', 'FATHER', 'GRANDPARENT', 'GUARDIAN', 'OTHER');
CREATE TYPE "ConsultationContactType" AS ENUM ('CALL', 'SMS', 'KAKAO', 'IN_PERSON', 'LINK', 'OTHER');
CREATE TYPE "ConsultationDirection" AS ENUM ('OUTBOUND', 'INBOUND');
CREATE TYPE "ParentFollowUpStatus" AS ENUM ('OPEN', 'DONE', 'DISMISSED');

CREATE TABLE "guardians" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "name" VARCHAR(100) NOT NULL,
  "relation" "GuardianRelation" NOT NULL DEFAULT 'GUARDIAN',
  "phone" VARCHAR(30),
  "email" VARCHAR(255),
  "isPrimary" BOOLEAN NOT NULL DEFAULT false,
  "memo" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "guardians_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "parent_consultations" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "guardianId" UUID,
  "createdById" UUID,
  "contactType" "ConsultationContactType" NOT NULL DEFAULT 'CALL',
  "direction" "ConsultationDirection" NOT NULL DEFAULT 'OUTBOUND',
  "occurredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "summary" VARCHAR(255) NOT NULL,
  "detail" TEXT,
  "promisedAction" VARCHAR(500),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "parent_consultations_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "parent_follow_up_tasks" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "guardianId" UUID,
  "consultationId" UUID,
  "sourceOpsTaskId" UUID,
  "assignedToId" UUID,
  "title" VARCHAR(255) NOT NULL,
  "dueAt" TIMESTAMP(3) NOT NULL,
  "status" "ParentFollowUpStatus" NOT NULL DEFAULT 'OPEN',
  "completedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "parent_follow_up_tasks_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "parent_consultation_reports" (
  "id" UUID NOT NULL,
  "consultationId" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "guardianId" UUID,
  "tokenId" VARCHAR(64) NOT NULL,
  "message" VARCHAR(500) NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "viewedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "parent_consultation_reports_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "guardians_studentId_idx" ON "guardians"("studentId");
CREATE INDEX "guardians_phone_idx" ON "guardians"("phone");
CREATE INDEX "parent_consultations_studentId_occurredAt_idx" ON "parent_consultations"("studentId", "occurredAt");
CREATE INDEX "parent_consultations_guardianId_idx" ON "parent_consultations"("guardianId");
CREATE INDEX "parent_consultations_createdById_idx" ON "parent_consultations"("createdById");
CREATE INDEX "parent_follow_up_tasks_dueAt_status_idx" ON "parent_follow_up_tasks"("dueAt", "status");
CREATE INDEX "parent_follow_up_tasks_studentId_status_idx" ON "parent_follow_up_tasks"("studentId", "status");
CREATE INDEX "parent_follow_up_tasks_guardianId_idx" ON "parent_follow_up_tasks"("guardianId");
CREATE INDEX "parent_follow_up_tasks_consultationId_idx" ON "parent_follow_up_tasks"("consultationId");
CREATE INDEX "parent_follow_up_tasks_sourceOpsTaskId_idx" ON "parent_follow_up_tasks"("sourceOpsTaskId");
CREATE UNIQUE INDEX "parent_consultation_reports_tokenId_key" ON "parent_consultation_reports"("tokenId");
CREATE INDEX "parent_consultation_reports_studentId_createdAt_idx" ON "parent_consultation_reports"("studentId", "createdAt");
CREATE INDEX "parent_consultation_reports_consultationId_idx" ON "parent_consultation_reports"("consultationId");
CREATE INDEX "parent_consultation_reports_expiresAt_idx" ON "parent_consultation_reports"("expiresAt");

ALTER TABLE "guardians" ADD CONSTRAINT "guardians_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "parent_consultations" ADD CONSTRAINT "parent_consultations_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "parent_consultations" ADD CONSTRAINT "parent_consultations_guardianId_fkey"
  FOREIGN KEY ("guardianId") REFERENCES "guardians"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "parent_consultations" ADD CONSTRAINT "parent_consultations_createdById_fkey"
  FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "parent_follow_up_tasks" ADD CONSTRAINT "parent_follow_up_tasks_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "parent_follow_up_tasks" ADD CONSTRAINT "parent_follow_up_tasks_guardianId_fkey"
  FOREIGN KEY ("guardianId") REFERENCES "guardians"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "parent_follow_up_tasks" ADD CONSTRAINT "parent_follow_up_tasks_consultationId_fkey"
  FOREIGN KEY ("consultationId") REFERENCES "parent_consultations"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "parent_follow_up_tasks" ADD CONSTRAINT "parent_follow_up_tasks_sourceOpsTaskId_fkey"
  FOREIGN KEY ("sourceOpsTaskId") REFERENCES "ops_tasks"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "parent_follow_up_tasks" ADD CONSTRAINT "parent_follow_up_tasks_assignedToId_fkey"
  FOREIGN KEY ("assignedToId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "parent_consultation_reports" ADD CONSTRAINT "parent_consultation_reports_consultationId_fkey"
  FOREIGN KEY ("consultationId") REFERENCES "parent_consultations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "parent_consultation_reports" ADD CONSTRAINT "parent_consultation_reports_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "parent_consultation_reports" ADD CONSTRAINT "parent_consultation_reports_guardianId_fkey"
  FOREIGN KEY ("guardianId") REFERENCES "guardians"("id") ON DELETE SET NULL ON UPDATE CASCADE;
