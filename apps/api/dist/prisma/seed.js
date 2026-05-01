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
    const studentPassword = await bcrypt.hash('studyon123!', 10);
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
            loginId: 'honggildong',
            passwordHash: studentPassword,
            gradeId: grade.id,
            classId: klass.id,
            groupId: group.id,
            assignedSeatId: seat.id,
        },
        create: {
            userId: studentUser.id,
            studentNo: '2026001',
            loginId: 'honggildong',
            passwordHash: studentPassword,
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
    const characterItems = [
        { category: 'HAT', name: '야구모자', price: 100, svgKey: 'hat_cap', sortOrder: 1 },
        { category: 'HAT', name: '왕관', price: 500, svgKey: 'hat_crown', sortOrder: 2 },
        { category: 'HAT', name: '졸업모', price: 300, svgKey: 'hat_grad', sortOrder: 3 },
        { category: 'HAT', name: '고양이귀', price: 200, svgKey: 'hat_catears', sortOrder: 4 },
        { category: 'GLASSES', name: '둥근안경', price: 100, svgKey: 'glasses_round', sortOrder: 1 },
        { category: 'GLASSES', name: '선글라스', price: 200, svgKey: 'glasses_sun', sortOrder: 2 },
        { category: 'GLASSES', name: '하트안경', price: 300, svgKey: 'glasses_heart', sortOrder: 3 },
        { category: 'GLASSES', name: 'VR 헤드셋', price: 500, svgKey: 'glasses_vr', sortOrder: 4 },
        { category: 'OUTFIT', name: '후디', price: 200, svgKey: 'outfit_hoodie', sortOrder: 1 },
        { category: 'OUTFIT', name: '교복', price: 100, svgKey: 'outfit_uniform', sortOrder: 2 },
        { category: 'OUTFIT', name: '슈퍼히어로', price: 500, svgKey: 'outfit_hero', sortOrder: 3 },
        { category: 'OUTFIT', name: '한복', price: 300, svgKey: 'outfit_hanbok', sortOrder: 4 },
        { category: 'BACKGROUND', name: '하늘', price: 100, svgKey: 'bg_sky', sortOrder: 1 },
        { category: 'BACKGROUND', name: '우주', price: 300, svgKey: 'bg_space', sortOrder: 2 },
        { category: 'BACKGROUND', name: '벚꽃', price: 200, svgKey: 'bg_sakura', sortOrder: 3 },
        { category: 'BACKGROUND', name: '무지개', price: 500, svgKey: 'bg_rainbow', sortOrder: 4 },
        { category: 'EXPRESSION', name: '웃음', price: 0, svgKey: 'expr_smile', sortOrder: 1, isDefault: true },
        { category: 'EXPRESSION', name: '졸림', price: 100, svgKey: 'expr_sleepy', sortOrder: 2 },
        { category: 'EXPRESSION', name: '화남', price: 100, svgKey: 'expr_angry', sortOrder: 3 },
        { category: 'EXPRESSION', name: '하트눈', price: 200, svgKey: 'expr_heartEyes', sortOrder: 4 },
    ];
    const existingItems = await prisma.characterItem.count();
    if (existingItems === 0) {
        await prisma.characterItem.createMany({
            data: characterItems.map((item) => ({
                category: item.category,
                name: item.name,
                price: item.price,
                svgKey: item.svgKey,
                sortOrder: item.sortOrder,
                isDefault: 'isDefault' in item ? item.isDefault : false,
            })),
        });
        console.log(`Seeded ${characterItems.length} character items.`);
    }
    else {
        console.log(`Character items already exist (${existingItems}), skipping.`);
    }
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