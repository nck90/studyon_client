ALTER TYPE "PointSource" ADD VALUE IF NOT EXISTS 'DAILY_MISSION';
ALTER TYPE "PointSource" ADD VALUE IF NOT EXISTS 'LEVEL_UP_BONUS';

CREATE TYPE "CharacterXpSource" AS ENUM (
  'STUDY_SESSION',
  'DAILY_MISSION',
  'LEVEL_UP_BONUS',
  'ADMIN_GRANT'
);

ALTER TABLE "student_characters"
  ADD COLUMN "level" INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN "xp" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "growthStage" VARCHAR(40) NOT NULL DEFAULT 'stage_01',
  ADD COLUMN "lastLevelUpAt" TIMESTAMP(3);

CREATE TABLE "character_xp_transactions" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "source" "CharacterXpSource" NOT NULL,
  "amount" INTEGER NOT NULL,
  "points" INTEGER NOT NULL DEFAULT 0,
  "levelBefore" INTEGER NOT NULL DEFAULT 1,
  "levelAfter" INTEGER NOT NULL DEFAULT 1,
  "xpAfter" INTEGER NOT NULL DEFAULT 0,
  "balanceAfter" INTEGER NOT NULL,
  "referenceKey" VARCHAR(160) NOT NULL,
  "memo" VARCHAR(255),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "character_xp_transactions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "character_xp_transactions_studentId_referenceKey_key"
  ON "character_xp_transactions"("studentId", "referenceKey");

CREATE INDEX "character_xp_transactions_studentId_createdAt_idx"
  ON "character_xp_transactions"("studentId", "createdAt");

ALTER TABLE "character_xp_transactions"
  ADD CONSTRAINT "character_xp_transactions_studentId_fkey"
  FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
