import { AttendanceFlag, AttendanceStatus } from '@prisma/client';
export declare class UpdateAttendanceDto {
    attendanceStatus?: AttendanceStatus;
    checkInAt?: string;
    checkOutAt?: string;
    seatId?: string;
    lateStatus?: AttendanceFlag;
    earlyLeaveStatus?: AttendanceFlag;
}
