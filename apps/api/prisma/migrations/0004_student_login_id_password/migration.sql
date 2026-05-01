ALTER TYPE "LoginMethod" RENAME VALUE 'STUDENT_NO_NAME' TO 'STUDENT_ID_PASSWORD';

ALTER TABLE "students"
ADD COLUMN "loginId" VARCHAR(50),
ADD COLUMN "passwordHash" VARCHAR(255);

UPDATE "students"
SET
  "loginId" = "studentNo",
  "passwordHash" = '$2b$10$5uEGPQAUPOIvcNlYbtm3I.9FdwyGKeF1uPphCH8R.YxLIF/x4i2kS'
WHERE "loginId" IS NULL OR "passwordHash" IS NULL;

ALTER TABLE "students"
ALTER COLUMN "loginId" SET NOT NULL,
ALTER COLUMN "passwordHash" SET NOT NULL;

CREATE UNIQUE INDEX "students_loginId_key" ON "students"("loginId");
