import { DeviceType } from '@prisma/client';
export declare class RegisterDeviceDto {
    deviceCode: string;
    deviceType: DeviceType;
    seatId?: string;
}
