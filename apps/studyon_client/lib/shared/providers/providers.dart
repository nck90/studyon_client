import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_models/studyon_models.dart';

// ── Admin Dashboard ──────────────────────────────────────────────────────────

class AdminDashboardData {
  const AdminDashboardData({
    required this.checkedIn,
    required this.emptySeats,
    required this.totalSeats,
    required this.totalStudyMinutes,
    required this.avgStudyMinutes,
    required this.seats,
    required this.topRankings,
  });

  final int checkedIn;
  final int emptySeats;
  final int totalSeats;
  final int totalStudyMinutes;
  final double avgStudyMinutes;
  final List<Seat> seats;
  final List<RankingItem> topRankings;
}

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) async {
  // Mock data — replace with real API calls
  await Future.delayed(const Duration(milliseconds: 300));
  return AdminDashboardData(
    checkedIn: 18,
    emptySeats: 4,
    totalSeats: 22,
    totalStudyMinutes: 2580,
    avgStudyMinutes: 138,
    seats: _mockSeats,
    topRankings: _mockRankings,
  );
});

// ── Admin Seats ──────────────────────────────────────────────────────────────

final adminSeatsProvider = FutureProvider<List<Seat>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockSeats;
});

// ── Admin Students ───────────────────────────────────────────────────────────

final adminStudentsProvider = FutureProvider<List<Student>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockStudents;
});

final studentDetailProvider =
    FutureProvider.family<Student, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockStudents.firstWhere((s) => s.id == id,
      orElse: () => _mockStudents.first);
});

// ── Admin Rankings ───────────────────────────────────────────────────────────

final adminRankingsProvider =
    FutureProvider.family<List<RankingItem>, String>((ref, period) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockRankings;
});

// ── Admin Attendance ─────────────────────────────────────────────────────────

final adminAttendanceProvider =
    FutureProvider.family<List<Attendance>, String>((ref, date) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockAttendances;
});

// ── Study Overview ───────────────────────────────────────────────────────────

class StudyOverviewData {
  const StudyOverviewData({
    required this.totalStudyMinutes,
    required this.avgStudyMinutes,
    required this.attendanceRate,
    required this.activeStudents,
    required this.dailyStats,
  });

  final int totalStudyMinutes;
  final int avgStudyMinutes;
  final double attendanceRate;
  final int activeStudents;
  final List<DailyStat> dailyStats;
}

class DailyStat {
  const DailyStat({required this.date, required this.minutes, required this.count});
  final String date;
  final int minutes;
  final int count;
}

final studyOverviewProvider =
    FutureProvider.family<StudyOverviewData, String>((ref, period) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return StudyOverviewData(
    totalStudyMinutes: 15480,
    avgStudyMinutes: 258,
    attendanceRate: 0.87,
    activeStudents: 42,
    dailyStats: List.generate(
      7,
      (i) => DailyStat(
        date: '04/${i + 8}',
        minutes: 200 + i * 30 + (i % 3) * 20,
        count: 30 + i * 2,
      ),
    ),
  );
});

// ── Settings ─────────────────────────────────────────────────────────────────

class AppSettings {
  const AppSettings({
    required this.academyName,
    required this.openTime,
    required this.closeTime,
    required this.lateThresholdMinutes,
    required this.autoCheckoutEnabled,
    required this.notificationEnabled,
    required this.tvDisplayEnabled,
  });

  final String academyName;
  final String openTime;
  final String closeTime;
  final int lateThresholdMinutes;
  final bool autoCheckoutEnabled;
  final bool notificationEnabled;
  final bool tvDisplayEnabled;
}

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return const AppSettings(
    academyName: '자습ON 학원',
    openTime: '09:00',
    closeTime: '22:00',
    lateThresholdMinutes: 15,
    autoCheckoutEnabled: true,
    notificationEnabled: true,
    tvDisplayEnabled: true,
  );
});

// ── Notifications ─────────────────────────────────────────────────────────────

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
  final String id;
  final String title;
  final String body;
  final String type;
  final String createdAt;
  final bool isRead;
}

final adminNotificationsProvider =
    FutureProvider<List<AdminNotification>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return [
    const AdminNotification(
      id: '1', title: '미입실 알림', body: '김민수 학생이 아직 입실하지 않았습니다.',
      type: 'attendance', createdAt: '10:05', isRead: false,
    ),
    const AdminNotification(
      id: '2', title: '퇴실 알림', body: '박지현 학생이 퇴실하였습니다.',
      type: 'checkout', createdAt: '09:50', isRead: false,
    ),
    const AdminNotification(
      id: '3', title: '지각 알림', body: '이서준 학생이 15분 지각하였습니다.',
      type: 'late', createdAt: '09:20', isRead: true,
    ),
    const AdminNotification(
      id: '4', title: '공부 목표 달성', body: '정다은 학생이 오늘 목표를 달성했습니다.',
      type: 'goal', createdAt: '08:30', isRead: true,
    ),
  ];
});

// ── TV Control ─────────────────────────────────────────────────────────────

class TvDisplayData {
  const TvDisplayData({
    required this.isOn,
    required this.displayMode,
    required this.message,
    required this.rankings,
  });
  final bool isOn;
  final String displayMode;
  final String message;
  final List<RankingItem> rankings;
}

final tvControlProvider = FutureProvider<TvDisplayData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return TvDisplayData(
    isOn: true,
    displayMode: 'ranking',
    message: '오늘도 열심히 공부합시다!',
    rankings: _mockRankings,
  );
});

// ── Mock Data ─────────────────────────────────────────────────────────────────

const _mockSeats = [
  Seat(id: 's1', seatNo: 'A1', status: 'studying', zone: 'A', assignedStudentName: '김민수'),
  Seat(id: 's2', seatNo: 'A2', status: 'empty', zone: 'A'),
  Seat(id: 's3', seatNo: 'A3', status: 'onBreak', zone: 'A', assignedStudentName: '이서준'),
  Seat(id: 's4', seatNo: 'A4', status: 'studying', zone: 'A', assignedStudentName: '정다은'),
  Seat(id: 's5', seatNo: 'A5', status: 'studying', zone: 'A', assignedStudentName: '최우진'),
  Seat(id: 's6', seatNo: 'A6', status: 'empty', zone: 'A'),
  Seat(id: 's7', seatNo: 'B1', status: 'studying', zone: 'B', assignedStudentName: '박서연'),
  Seat(id: 's8', seatNo: 'B2', status: 'studying', zone: 'B', assignedStudentName: '강지호'),
  Seat(id: 's9', seatNo: 'B3', status: 'notCheckedIn', zone: 'B'),
  Seat(id: 's10', seatNo: 'B4', status: 'studying', zone: 'B', assignedStudentName: '윤하은'),
  Seat(id: 's11', seatNo: 'B5', status: 'onBreak', zone: 'B', assignedStudentName: '임준혁'),
  Seat(id: 's12', seatNo: 'B6', status: 'empty', zone: 'B'),
  Seat(id: 's13', seatNo: 'C1', status: 'studying', zone: 'C', assignedStudentName: '송유나'),
  Seat(id: 's14', seatNo: 'C2', status: 'studying', zone: 'C', assignedStudentName: '오민재'),
  Seat(id: 's15', seatNo: 'C3', status: 'empty', zone: 'C'),
  Seat(id: 's16', seatNo: 'C4', status: 'studying', zone: 'C', assignedStudentName: '배수진'),
  Seat(id: 's17', seatNo: 'C5', status: 'studying', zone: 'C', assignedStudentName: '황태양'),
  Seat(id: 's18', seatNo: 'C6', status: 'notCheckedIn', zone: 'C'),
  Seat(id: 's19', seatNo: 'D1', status: 'empty', zone: 'D'),
  Seat(id: 's20', seatNo: 'D2', status: 'studying', zone: 'D', assignedStudentName: '전지우'),
  Seat(id: 's21', seatNo: 'D3', status: 'studying', zone: 'D', assignedStudentName: '노은서'),
  Seat(id: 's22', seatNo: 'D4', status: 'studying', zone: 'D', assignedStudentName: '한도윤'),
];

const _mockRankings = [
  RankingItem(studentId: '1', studentName: '김민수', rankNo: 1, score: 252),
  RankingItem(studentId: '2', studentName: '박지현', rankNo: 2, score: 228),
  RankingItem(studentId: '3', studentName: '이서준', rankNo: 3, score: 192),
  RankingItem(studentId: '4', studentName: '정다은', rankNo: 4, score: 178),
  RankingItem(studentId: '5', studentName: '최우진', rankNo: 5, score: 154),
  RankingItem(studentId: '6', studentName: '박서연', rankNo: 6, score: 142),
  RankingItem(studentId: '7', studentName: '강지호', rankNo: 7, score: 138),
  RankingItem(studentId: '8', studentName: '윤하은', rankNo: 8, score: 125),
  RankingItem(studentId: '9', studentName: '임준혁', rankNo: 9, score: 118),
  RankingItem(studentId: '10', studentName: '송유나', rankNo: 10, score: 112),
];

const _mockStudents = [
  Student(id: '1', studentNo: '2401', name: '김민수', gradeName: '고3', className: 'A반', status: 'studying', assignedSeatNo: 'A1'),
  Student(id: '2', studentNo: '2402', name: '박지현', gradeName: '고3', className: 'A반', status: 'studying', assignedSeatNo: 'A4'),
  Student(id: '3', studentNo: '2403', name: '이서준', gradeName: '고2', className: 'B반', status: 'onBreak', assignedSeatNo: 'A3'),
  Student(id: '4', studentNo: '2404', name: '정다은', gradeName: '고2', className: 'B반', status: 'studying', assignedSeatNo: 'A5'),
  Student(id: '5', studentNo: '2405', name: '최우진', gradeName: '고3', className: 'A반', status: 'studying', assignedSeatNo: 'B1'),
  Student(id: '6', studentNo: '2406', name: '박서연', gradeName: '고1', className: 'C반', status: 'studying', assignedSeatNo: 'B2'),
  Student(id: '7', studentNo: '2407', name: '강지호', gradeName: '고1', className: 'C반', status: 'notCheckedIn', assignedSeatNo: 'B3'),
  Student(id: '8', studentNo: '2408', name: '윤하은', gradeName: '고2', className: 'B반', status: 'studying', assignedSeatNo: 'B4'),
  Student(id: '9', studentNo: '2409', name: '임준혁', gradeName: '고3', className: 'A반', status: 'onBreak', assignedSeatNo: 'B5'),
  Student(id: '10', studentNo: '2410', name: '송유나', gradeName: '고1', className: 'C반', status: 'studying', assignedSeatNo: 'C1'),
];

const _mockAttendances = [
  Attendance(id: 'a1', studentId: '1', attendanceDate: '2024-04-14', status: 'checked_in', checkInAt: '09:05', stayMinutes: 180),
  Attendance(id: 'a2', studentId: '2', attendanceDate: '2024-04-14', status: 'checked_in', checkInAt: '09:00', stayMinutes: 200),
  Attendance(id: 'a3', studentId: '3', attendanceDate: '2024-04-14', status: 'late', checkInAt: '09:25', stayMinutes: 150, isLate: true),
  Attendance(id: 'a4', studentId: '4', attendanceDate: '2024-04-14', status: 'checked_in', checkInAt: '09:10', stayMinutes: 170),
  Attendance(id: 'a5', studentId: '5', attendanceDate: '2024-04-14', status: 'checked_in', checkInAt: '09:02', stayMinutes: 190),
  Attendance(id: 'a6', studentId: '6', attendanceDate: '2024-04-14', status: 'checked_in', checkInAt: '09:15', stayMinutes: 140),
  Attendance(id: 'a7', studentId: '7', attendanceDate: '2024-04-14', status: 'absent', checkInAt: null, stayMinutes: 0),
];
