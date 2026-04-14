import { Injectable } from '@nestjs/common';
import { AuditService } from '@/audit/audit.service';
import { PrismaService } from '@/database/prisma.service';
import { EventsService } from '@/events/events.service';

function stringWithDefault(value: unknown, fallback: string): string {
  return typeof value === 'string' && value.length > 0 ? value : fallback;
}

@Injectable()
export class SettingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly events: EventsService,
  ) {}

  getAttendancePolicy() {
    return this.prisma.attendancePolicy
      .findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  updateAttendancePolicy(data: Record<string, unknown>, actorUserId?: string) {
    return this.prisma.attendancePolicy
      .create({
        data: {
          policyName: stringWithDefault(
            data.policyName,
            'Default Attendance Policy',
          ),
          lateCutoffTime: stringWithDefault(data.lateCutoffTime, '09:00'),
          earlyLeaveCutoffTime: stringWithDefault(
            data.earlyLeaveCutoffTime,
            '22:00',
          ),
          autoCheckoutEnabled: Boolean(data.autoCheckoutEnabled ?? false),
          autoCheckoutAfterMinutes:
            data.autoCheckoutAfterMinutes !== undefined
              ? Number(data.autoCheckoutAfterMinutes)
              : null,
          isActive: true,
          createdById: actorUserId,
        },
      })
      .then(async (created) => {
        await this.audit.log({
          actorUserId,
          actionType: 'ATTENDANCE_POLICY_UPDATED',
          targetType: 'attendance_policy',
          targetId: created.id,
          afterData: created,
        });
        return { success: true, data: created, meta: {} };
      });
  }

  getRankingPolicy() {
    return this.prisma.rankingPolicy
      .findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  getTvDisplay() {
    return this.prisma.tvDisplaySetting
      .findFirst({
        orderBy: { createdAt: 'desc' },
      })
      .then((data) => ({ success: true, data, meta: {} }));
  }

  async updateTvDisplay(data: Record<string, unknown>, actorUserId?: string) {
    const existing = await this.prisma.tvDisplaySetting.findFirst({
      orderBy: { createdAt: 'desc' },
    });

    const payload = {
      activeScreen: data.activeScreen as never,
      rotationEnabled:
        data.rotationEnabled !== undefined
          ? Boolean(data.rotationEnabled)
          : undefined,
      rotationIntervalSeconds:
        data.rotationIntervalSeconds !== undefined
          ? Number(data.rotationIntervalSeconds)
          : undefined,
      displayOptions: (data.displayOptions as object) ?? {
        rankingType: 'STUDY_TIME',
      },
    };

    const record = existing
      ? await this.prisma.tvDisplaySetting.update({
          where: { id: existing.id },
          data: { ...payload, updatedById: actorUserId },
        })
      : await this.prisma.tvDisplaySetting.create({
          data: { ...payload, updatedById: actorUserId },
        });

    await this.audit.log({
      actorUserId,
      actionType: 'TV_DISPLAY_UPDATED',
      targetType: 'tv_display_setting',
      targetId: record.id,
      beforeData: existing,
      afterData: record,
    });
    this.events.emit({
      channel: 'display',
      event: 'display.updated',
      payload: record,
    });

    return { success: true, data: record, meta: {} };
  }
}
