ALTER TABLE "study_sessions"
ADD COLUMN "studySeconds" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN "breakSeconds" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "study_breaks"
ADD COLUMN "breakSeconds" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "study_logs"
ADD COLUMN "studySeconds" INTEGER NOT NULL DEFAULT 0;

UPDATE "study_sessions"
SET
  "studySeconds" = GREATEST("studyMinutes", 0) * 60,
  "breakSeconds" = GREATEST("breakMinutes", 0) * 60;

UPDATE "study_breaks"
SET "breakSeconds" = GREATEST("breakMinutes", 0) * 60;

UPDATE "study_logs"
SET "studySeconds" = GREATEST("studyMinutes", 0) * 60;
