import { PrismaService } from "../database/prisma.service";
import { AttendancesService } from './attendances.service';
export declare class AttendancesAutomationService {
    private readonly prisma;
    private readonly attendancesService;
    constructor(prisma: PrismaService, attendancesService: AttendancesService);
    autoCheckout(): Promise<void>;
}
