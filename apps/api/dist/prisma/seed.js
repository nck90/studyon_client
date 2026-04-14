"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const prisma = new client_1.PrismaClient();
async function main() {
    const adminEmail = process.env.DEFAULT_ADMIN_EMAIL ?? 'admin@studyon.local';
    const adminPassword = process.env.DEFAULT_ADMIN_PASSWORD ?? 'ChangeMe123!';
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    const grade = await prisma.grade.upsert({
        where: { id: '11111111-1111-1111-1111-111111111111' },
        update: { name: '고2' },
        create: {
            id: '11111111-1111-1111-1111-111111111111',
            name: '고2',
            sortOrder: 1,
        },
    });
    const klass = await prisma.class.upsert({
        where: { id: '22222222-2222-2222-2222-222222222222' },
        update: { name: 'A반', gradeId: grade.id },
        create: {
            id: '22222222-2222-2222-2222-222222222222',
            name: 'A반',
            gradeId: grade.id,
            sortOrder: 1,
        },
    });
    const group = await prisma.group.upsert({
        where: { id: '33333333-3333-3333-3333-333333333333' },
        update: { name: '심화반', classId: klass.id },
        create: {
            id: '33333333-3333-3333-3333-333333333333',
            name: '심화반',
            classId: klass.id,
            sortOrder: 1,
        },
    });
    const seat = await prisma.seat.upsert({
        where: { seatNo: 'A-01' },
        update: { zone: 'A', isActive: true },
        create: { seatNo: 'A-01', zone: 'A', isActive: true },
    });
    const adminUser = await prisma.user.upsert({
        where: { id: '44444444-4444-4444-4444-444444444444' },
        update: { role: client_1.UserRole.DIRECTOR, name: '원장', status: 'ACTIVE' },
        create: {
            id: '44444444-4444-4444-4444-444444444444',
            role: client_1.UserRole.DIRECTOR,
            name: '원장',
            status: 'ACTIVE',
        },
    });
    await prisma.adminUser.upsert({
        where: { email: adminEmail },
        update: {
            userId: adminUser.id,
            adminType: client_1.UserRole.DIRECTOR,
            passwordHash,
        },
        create: {
            userId: adminUser.id,
            adminType: client_1.UserRole.DIRECTOR,
            email: adminEmail,
            passwordHash,
        },
    });
    const studentUser = await prisma.user.upsert({
        where: { id: '55555555-5555-5555-5555-555555555555' },
        update: { role: client_1.UserRole.STUDENT, name: '홍길동', status: 'ACTIVE' },
        create: {
            id: '55555555-5555-5555-5555-555555555555',
            role: client_1.UserRole.STUDENT,
            name: '홍길동',
            status: 'ACTIVE',
        },
    });
    await prisma.student.upsert({
        where: { studentNo: '2026001' },
        update: {
            userId: studentUser.id,
            gradeId: grade.id,
            classId: klass.id,
            groupId: group.id,
            assignedSeatId: seat.id,
        },
        create: {
            userId: studentUser.id,
            studentNo: '2026001',
            gradeId: grade.id,
            classId: klass.id,
            groupId: group.id,
            assignedSeatId: seat.id,
        },
    });
    await prisma.attendancePolicy.create({
        data: {
            policyName: 'Default Attendance Policy',
            lateCutoffTime: '09:00',
            earlyLeaveCutoffTime: '22:00',
            autoCheckoutEnabled: false,
            isActive: true,
            createdById: adminUser.id,
        },
    }).catch(() => undefined);
    await prisma.rankingPolicy.create({
        data: {
            policyName: 'Default Ranking Policy',
            studyTimeWeight: 1,
            studyVolumeWeight: 1,
            attendanceWeight: 1,
            tieBreakerRule: { order: ['score', 'subScore1', 'subScore2'] },
            isActive: true,
            createdById: adminUser.id,
        },
    }).catch(() => undefined);
    await prisma.tvDisplaySetting.create({
        data: {
            activeScreen: 'RANKING',
            rotationEnabled: true,
            rotationIntervalSeconds: 30,
            displayOptions: { rankingType: 'STUDY_TIME', periodType: 'DAILY' },
            updatedById: adminUser.id,
        },
    }).catch(() => undefined);
    await prisma.badge.upsert({
        where: { code: 'ATTENDANCE_STARTER' },
        update: {
            name: '첫 출석',
            description: '첫 입실을 완료했습니다.',
            badgeType: client_1.BadgeType.ATTENDANCE,
        },
        create: {
            code: 'ATTENDANCE_STARTER',
            name: '첫 출석',
            description: '첫 입실을 완료했습니다.',
            badgeType: client_1.BadgeType.ATTENDANCE,
        },
    });
    await prisma.badge.upsert({
        where: { code: 'ATTENDANCE_STREAK_7' },
        update: {
            name: '7일 연속 출석',
            description: '7일 연속 출석을 달성했습니다.',
            badgeType: client_1.BadgeType.ATTENDANCE,
        },
        create: {
            code: 'ATTENDANCE_STREAK_7',
            name: '7일 연속 출석',
            description: '7일 연속 출석을 달성했습니다.',
            badgeType: client_1.BadgeType.ATTENDANCE,
        },
    });
    await prisma.badge.upsert({
        where: { code: 'STUDY_5H' },
        update: {
            name: '5시간 집중',
            description: '하루 공부 시간 5시간을 달성했습니다.',
            badgeType: client_1.BadgeType.STUDY_TIME,
        },
        create: {
            code: 'STUDY_5H',
            name: '5시간 집중',
            description: '하루 공부 시간 5시간을 달성했습니다.',
            badgeType: client_1.BadgeType.STUDY_TIME,
        },
    });
    await prisma.badge.upsert({
        where: { code: 'GOAL_ACHIEVER' },
        update: {
            name: '목표 달성',
            description: '하루 계획 달성률 100%를 달성했습니다.',
            badgeType: client_1.BadgeType.ACHIEVEMENT,
        },
        create: {
            code: 'GOAL_ACHIEVER',
            name: '목표 달성',
            description: '하루 계획 달성률 100%를 달성했습니다.',
            badgeType: client_1.BadgeType.ACHIEVEMENT,
        },
    });
    console.log(`Seed complete. Admin email: ${adminEmail}`);
}
main()
    .catch((error) => {
    console.error(error);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map