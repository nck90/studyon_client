import { BadRequestException } from '@nestjs/common';
import { BadgeRuleMetric, FocusPolicyMode } from '@prisma/client';
import { AuditService } from '@/audit/audit.service';
import { PrismaService } from '@/database/prisma.service';
import { NotificationsService } from '@/notifications/notifications.service';
import { AdminService } from './admin.service';

describe('AdminService motivation operations', () => {
  let service: AdminService;
  let prisma: {
    badgeRule: {
      create: jest.Mock;
      findMany: jest.Mock;
      update: jest.Mock;
    };
    focusPolicy: {
      create: jest.Mock;
      findFirst: jest.Mock;
      update: jest.Mock;
    };
  };

  beforeEach(() => {
    prisma = {
      badgeRule: {
        create: jest.fn(),
        findMany: jest.fn(),
        update: jest.fn(),
      },
      focusPolicy: {
        create: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
    };
    service = new AdminService(
      prisma as unknown as PrismaService,
      {} as AuditService,
      {} as NotificationsService,
    );
  });

  it('sanitizes package lists when updating focus policy', async () => {
    prisma.focusPolicy.findFirst.mockResolvedValue({
      id: 'policy-1',
      policyName: '기본 정책',
      mode: FocusPolicyMode.SOFT_LOCK,
      isEnabled: false,
      blockedPackages: [],
      allowedPackages: [],
    });
    prisma.focusPolicy.update.mockResolvedValue({
      id: 'policy-1',
      policyName: '학습 집중',
      mode: FocusPolicyMode.ANDROID_DEVICE_OWNER,
      isEnabled: true,
      blockedPackages: ['com.instagram.android'],
      allowedPackages: ['com.studyon.studyon_client'],
    });

    await service.updateFocusPolicy({
      policyName: ' 학습 집중 ',
      mode: FocusPolicyMode.ANDROID_DEVICE_OWNER,
      isEnabled: true,
      blockedPackages: ['com.instagram.android', '', '  '],
      allowedPackages: [' com.studyon.studyon_client '],
    });

    expect(prisma.focusPolicy.update).toHaveBeenCalledWith({
      where: { id: 'policy-1' },
      data: {
        policyName: '학습 집중',
        mode: FocusPolicyMode.ANDROID_DEVICE_OWNER,
        isEnabled: true,
        blockedPackages: ['com.instagram.android'],
        allowedPackages: ['com.studyon.studyon_client'],
      },
    });
  });

  it('rejects invalid badge rule thresholds', async () => {
    await expect(
      service.updateBadgeRules([
        {
          badgeId: 'badge-1',
          metric: BadgeRuleMetric.DAILY_STUDY_MINUTES,
          threshold: 0,
        },
      ]),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
