CREATE TYPE "FocusEventType" AS ENUM (
  'FOCUS_STARTED',
  'APP_EXIT',
  'APP_RETURN',
  'FOCUS_PAUSED',
  'FOCUS_RESUMED',
  'FOCUS_ENDED'
);

ALTER TABLE "student_focus_metrics"
  ADD COLUMN IF NOT EXISTS "returnCount" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "totalAwaySeconds" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "longestAwaySeconds" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "focus_policies"
  ADD COLUMN IF NOT EXISTS "graceSeconds" INTEGER NOT NULL DEFAULT 15,
  ADD COLUMN IF NOT EXISTS "opsQueueThreshold" INTEGER NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS "parentReportThreshold" INTEGER NOT NULL DEFAULT 3;

CREATE TABLE "student_focus_events" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "studySessionId" UUID,
  "eventType" "FocusEventType" NOT NULL,
  "eventDate" DATE NOT NULL,
  "occurredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "durationSeconds" INTEGER,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "student_focus_events_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "student_focus_events_eventDate_eventType_idx"
  ON "student_focus_events"("eventDate", "eventType");
CREATE INDEX "student_focus_events_studentId_occurredAt_idx"
  ON "student_focus_events"("studentId", "occurredAt");
CREATE INDEX "student_focus_events_studySessionId_idx"
  ON "student_focus_events"("studySessionId");

ALTER TABLE "student_focus_events"
  ADD CONSTRAINT "student_focus_events_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "student_focus_events"
  ADD CONSTRAINT "student_focus_events_studySessionId_fkey"
  FOREIGN KEY ("studySessionId") REFERENCES "study_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
