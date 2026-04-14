import { Injectable } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { AttendanceStatus } from '@prisma/client';
import { PrismaService } from '@/database/prisma.service';
import { AttendancesService } from './attendances.service';

@Injectable()
export class AttendancesAutomationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly attendancesService: AttendancesService,
  ) {}

  @Cron('0 */10 * * * *')
  async autoCheckout() {
    const policy = await this.prisma.attendancePolicy.findFirst({
      where: { isActive: true, autoCheckoutEnabled: true },
      orderBy: { createdAt: 'desc' },
    });

    if (!policy?.autoCheckoutAfterMinutes) {
      return;
    }

    const cutoff = new Date(
      Date.now() - policy.autoCheckoutAfterMinutes * 60 * 1000,
    );
    const today = new Date(new Date().toISOString().slice(0, 10));
    const attendances = await this.prisma.attendance.findMany({
      where: {
        attendanceDate: today,
        attendanceStatus: AttendanceStatus.CHECKED_IN,
        checkInAt: { lte: cutoff },
      },
      select: { studentId: true },
      take: 200,
    });

    for (const attendance of attendances) {
      await this.attendancesService.checkOut(attendance.studentId, true);
    }
  }
}
