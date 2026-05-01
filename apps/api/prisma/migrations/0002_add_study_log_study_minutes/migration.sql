ALTER TABLE "study_logs"
ADD COLUMN "studyMinutes" INTEGER NOT NULL DEFAULT 0;

UPDATE "study_logs" AS log
SET "studyMinutes" = COALESCE(session."studyMinutes", 0)
FROM "study_sessions" AS session
WHERE log."studySessionId" = session."id"
  AND log."studyMinutes" = 0;
