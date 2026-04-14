import 'package:studyon_client/shared/providers/student_providers.dart';

/// Repository interface for student data.
/// Currently returns mock data. Replace implementations with real API calls.
class StudentRepository {
  // ── Auth ──
  Future<StudentState> login(String id, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const StudentState(); // returns default mock state
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── Check-in/out ──
  Future<DateTime> checkIn(String studentId, String seatNo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DateTime.now();
  }

  Future<void> checkOut(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── Study Session ──
  Future<String> startSession(String studentId, {String? subject}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> endSession(
    String sessionId, {
    required int studySeconds,
    required int breakSeconds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> pauseSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> resumeSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // ── Study Plans ──
  Future<List<StudyPlanItem>> getPlans(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const StudyPlanItem(
        id: '1',
        subject: '수학',
        detail: '수1 3단원 문제풀이',
        targetHours: 3,
        priority: '높음',
        progress: 0.74,
      ),
      const StudyPlanItem(
        id: '2',
        subject: '영어',
        detail: '단어 100개 암기',
        targetHours: 1,
        priority: '보통',
        progress: 0.0,
      ),
    ];
  }

  Future<void> addPlan(String studentId, StudyPlanItem plan) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> deletePlan(String studentId, String planId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> reorderPlans(String studentId, List<String> planIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── Rankings ──
  Future<List<Map<String, dynamic>>> getRankings({
    required String period,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'name': '김민수', 'time': '4시간 12분', 'trend': 0},
      {'name': '박지현', 'time': '3시간 48분', 'trend': 1},
      {'name': '이서준', 'time': '3시간 12분', 'trend': -2},
      {'name': '정다은', 'time': '2시간 58분', 'trend': 3},
      {'name': '최우진', 'time': '2시간 34분', 'trend': -1},
    ];
  }

  // ── Records ──
  Future<List<StudyRecord>> getRecords(
    String studentId, {
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const StudyRecord(
        date: '4월 14일',
        subject: '수학',
        studyMinutes: 192,
        goalAchieved: true,
        goalDetail: '수1 3단원',
      ),
      const StudyRecord(
        date: '4월 13일',
        subject: '영어',
        studyMinutes: 210,
        goalAchieved: true,
        goalDetail: '단어 암기',
      ),
      const StudyRecord(
        date: '4월 12일',
        subject: '과학',
        studyMinutes: 168,
        goalAchieved: false,
        goalDetail: '화학 개념',
      ),
      const StudyRecord(
        date: '4월 11일',
        subject: '국어',
        studyMinutes: 110,
        goalAchieved: false,
        goalDetail: '지문 분석',
      ),
      const StudyRecord(
        date: '4월 10일',
        subject: '수학',
        studyMinutes: 195,
        goalAchieved: true,
        goalDetail: '기출 분석',
      ),
    ];
  }

  // ── Seat ──
  Future<void> requestSeatChange(
    String studentId,
    String fromSeat,
    String toSeat,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── Notifications ──
  Future<List<NotificationItem>> getNotifications(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const NotificationItem(
        id: '1',
        title: '자습실 마감 안내',
        body: '오늘 자습실 21:30에 마감됩니다',
        type: 'announcement',
        timeAgo: '30분 전',
      ),
      const NotificationItem(
        id: '2',
        title: '좌석 재배정',
        body: '내일 좌석 재배정이 있습니다',
        type: 'schedule',
        timeAgo: '2시간 전',
      ),
    ];
  }

  Future<void> markNotificationRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
