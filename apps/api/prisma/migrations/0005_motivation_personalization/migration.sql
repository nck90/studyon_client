CREATE TYPE "MediaAssetKind" AS ENUM ('TARGET_UNIVERSITY', 'HOME_BACKGROUND', 'CHECKIN_BACKGROUND');

CREATE TYPE "BadgeRuleMetric" AS ENUM ('ATTENDANCE_STREAK_DAYS', 'DAILY_STUDY_MINUTES', 'DAILY_ACHIEVED_RATE', 'WEEKLY_STUDY_MINUTES', 'MONTHLY_STUDY_MINUTES', 'PROBLEMS_SOLVED', 'PAGES_COMPLETED');

CREATE TYPE "FocusPolicyMode" AS ENUM ('SOFT_LOCK', 'ANDROID_DEVICE_OWNER', 'IOS_SCREEN_TIME');

CREATE TABLE "media_assets" (
  "id" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "kind" "MediaAssetKind" NOT NULL,
  "originalName" VARCHAR(255) NOT NULL,
  "mimeType" VARCHAR(100) NOT NULL,
  "byteSize" INTEGER NOT NULL,
  "storageKey" VARCHAR(500) NOT NULL,
  "publicUrl" VARCHAR(700) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "media_assets_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "badge_rules" (
  "id" UUID NOT NULL,
  "badgeId" UUID NOT NULL,
  "metric" "BadgeRuleMetric" NOT NULL,
  "threshold" INTEGER NOT NULL,
  "windowDays" INTEGER,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "badge_rules_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "focus_policies" (
  "id" UUID NOT NULL,
  "policyName" VARCHAR(100) NOT NULL,
  "mode" "FocusPolicyMode" NOT NULL DEFAULT 'SOFT_LOCK',
  "isEnabled" BOOLEAN NOT NULL DEFAULT false,
  "blockedPackages" JSONB NOT NULL DEFAULT '[]',
  "allowedPackages" JSONB NOT NULL DEFAULT '[]',
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "focus_policies_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "media_assets_storageKey_key" ON "media_assets"("storageKey");
CREATE INDEX "media_assets_studentId_kind_idx" ON "media_assets"("studentId", "kind");
CREATE INDEX "badge_rules_badgeId_idx" ON "badge_rules"("badgeId");
CREATE INDEX "badge_rules_metric_isActive_idx" ON "badge_rules"("metric", "isActive");

ALTER TABLE "media_assets" ADD CONSTRAINT "media_assets_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "badge_rules" ADD CONSTRAINT "badge_rules_badgeId_fkey" FOREIGN KEY ("badgeId") REFERENCES "badges"("id") ON DELETE CASCADE ON UPDATE CASCADE;
