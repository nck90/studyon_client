ALTER TYPE "DisplayScreen" ADD VALUE IF NOT EXISTS 'GOAL_WALL';

CREATE TABLE IF NOT EXISTS "student_focus_metrics" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "metricDate" DATE NOT NULL,
  "eventCount" INTEGER NOT NULL DEFAULT 0,
  "lastEventAt" TIMESTAMP(3),
  "lastSessionId" UUID,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "student_focus_metrics_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "student_focus_metrics_studentId_metricDate_key"
  ON "student_focus_metrics"("studentId", "metricDate");

CREATE INDEX IF NOT EXISTS "student_focus_metrics_metricDate_idx"
  ON "student_focus_metrics"("metricDate");

CREATE INDEX IF NOT EXISTS "student_focus_metrics_studentId_idx"
  ON "student_focus_metrics"("studentId");

ALTER TABLE "student_focus_metrics"
  ADD CONSTRAINT "student_focus_metrics_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
