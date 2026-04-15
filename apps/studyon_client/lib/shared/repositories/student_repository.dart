import 'package:dio/dio.dart';
import 'package:studyon_api_client/studyon_api_client.dart';
import 'package:studyon_auth/studyon_auth.dart';
import 'package:studyon_models/studyon_models.dart';

import '../providers/student_providers.dart';

class StudentRepository {
  StudentRepository({
    required this.authNotifier,
    required this.studentApi,
    required this.dio,
  });

  final AuthNotifier authNotifier;
  final StudentApi studentApi;
  final Dio dio;

  Future<void> login(String studentNo, String name) {
    return authNotifier.loginAsStudent(
      StudentLoginRequest(studentNo: studentNo, name: name),
    );
  }

  Future<void> signup({
    required String studentNo,
    required String name,
    String? phone,
  }) {
    return authNotifier.signupAsStudent(
      StudentSignupRequest(
        studentNo: studentNo,
        name: name,
        phone: phone,
      ),
    );
  }

  Future<void> logout() {
    return authNotifier.logout();
  }

  Future<StudentState> fetchState({required bool isDarkMode}) async {
    final home = await studentApi.getHome();
    final profile = await studentApi.getProfile();
    final plans = await studentApi.getStudyPlans();
    final logs = await studentApi.getStudyLogs();
    final rankings = await studentApi.getRankings(
      periodType: 'DAILY',
      rankingType: 'STUDY_TIME',
    );
    final notifications = await studentApi.getNotifications();
    final badgesResponse = await dio.get('/student/badges');
    final weeklyResponse = await dio.get('/student/reports/weekly');
    final monthlyResponse = await dio.get('/student/reports/monthly');

    final seatNo =
        home.seat?.seatNo ??
        ((profile['assignedSeat'] as Map<String, dynamic>?)?['seatNo']
                as String?) ??
        '';

    final studyMinutes = home.study?.studyMinutes ?? 0;
    final targetMinutes = home.plans?.targetMinutes ?? 0;
    final firstPlan = plans.isNotEmpty ? plans.first : null;

    return StudentState(
      name: profile['user']?['name'] as String? ?? '',
      studentNo: profile['studentNo'] as String? ?? '',
      grade: profile['grade']?['name'] as String? ?? '',
      className: profile['class']?['name'] as String? ?? '',
      seatNo: seatNo,
      isCheckedIn:
          (home.todayAttendance?.status ?? '') == 'CHECKED_IN' ||
          (home.todayAttendance?.status ?? '') == 'CHECKED_OUT',
      checkInTime: _parseDateTime(home.todayAttendance?.checkInAt),
      todayStudySeconds: studyMinutes * 60,
      todayBreakSeconds: (home.study?.breakMinutes ?? 0) * 60,
      weeklyStudyMinutes:
          (weeklyResponse.data['data']?['studyMinutes'] as int? ?? 0),
      monthlyStudyMinutes:
          (monthlyResponse.data['data']?['studyMinutes'] as int? ?? 0),
      streakDays: 0,
      todayRank: rankings.myRank.rankNo,
      goalProgress: targetMinutes == 0
          ? 0
          : (studyMinutes / targetMinutes).clamp(0.0, 1.0),
      goalSubject: firstPlan?.subjectName ?? '',
      goalDetail: firstPlan?.title ?? '',
      goalHours: ((firstPlan?.targetMinutes ?? 0) / 60).ceil(),
      plans: plans.map(_mapPlan).toList(),
      recentRecords: logs.take(20).map(_mapLog).toList(),
      totalPoints: 0,
      badges: ((badgesResponse.data['data'] as List?) ?? [])
          .map((item) => item['badge']?['name'] as String? ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
      notifications: notifications.map(_mapNotification).toList(),
      isDarkMode: isDarkMode,
      isStudying: (home.study?.sessionStatus ?? '') == 'ACTIVE' ||
          (home.study?.sessionStatus ?? '') == 'PAUSED',
    );
  }

  Future<DateTime> checkIn({String? seatId}) async {
    final attendance = await studentApi.checkIn(seatId: seatId);
    return _parseDateTime(attendance.checkInAt) ?? DateTime.now();
  }

  Future<void> checkOut() async {
    await studentApi.checkOut();
  }

  Future<List<StudyPlanItem>> getPlans() async {
    final plans = await studentApi.getStudyPlans();
    return plans.map(_mapPlan).toList();
  }

  Future<StudyPlanItem> addPlan({
    required String subject,
    required String detail,
    required int targetHours,
    String priority = '보통',
  }) async {
    final plan = await studentApi.createStudyPlan(
      CreateStudyPlanRequest(
        planDate: DateTime.now().toIso8601String(),
        subjectName: subject,
        title: detail,
        targetMinutes: targetHours * 60,
        priority: _priorityToApi(priority),
      ),
    );
    return _mapPlan(plan);
  }

  Future<StudyPlanItem> updatePlan({
    required String planId,
    required String subject,
    required String detail,
    required int targetHours,
    String priority = '보통',
  }) async {
    final plan = await studentApi.updateStudyPlan(planId, {
      'subjectName': subject,
      'title': detail,
      'targetMinutes': targetHours * 60,
      'priority': _priorityToApi(priority),
    });
    return _mapPlan(plan);
  }

  Future<void> deletePlan(String planId) {
    return studentApi.deleteStudyPlan(planId);
  }

  Future<void> completePlan(String planId) {
    return studentApi.completePlan(planId);
  }

  Future<StudySession?> getActiveSession() {
    return studentApi.getActiveSession();
  }

  Future<StudySession> startSession({String? linkedPlanId}) {
    return studentApi.startSession(linkedPlanId: linkedPlanId);
  }

  Future<StudySession> pauseSession(String sessionId) {
    return studentApi.pauseSession(sessionId);
  }

  Future<StudySession> resumeSession(String sessionId) {
    return studentApi.resumeSession(sessionId);
  }

  Future<StudySession> endSession(String sessionId) {
    return studentApi.endSession(sessionId);
  }

  Future<StudyLog> createStudyLog({
    required String subjectName,
    String? planId,
    String? studySessionId,
    String? memo,
    double progressPercent = 0,
    bool isCompleted = false,
  }) {
    return studentApi.createStudyLog(
      CreateStudyLogRequest(
        logDate: DateTime.now().toIso8601String(),
        subjectName: subjectName,
        planId: planId,
        studySessionId: studySessionId,
        progressPercent: progressPercent,
        isCompleted: isCompleted,
        memo: memo,
      ),
    );
  }

  Future<List<StudyRecord>> getRecords() async {
    final logs = await studentApi.getStudyLogs();
    return logs.map(_mapLog).toList();
  }

  Future<RankingResponse> getRankings({required String periodType}) {
    return studentApi.getRankings(
      periodType: periodType,
      rankingType: 'STUDY_TIME',
    );
  }

  Future<List<NotificationItem>> getNotifications() async {
    final notifications = await studentApi.getNotifications();
    return notifications.map(_mapNotification).toList();
  }

  Future<void> markNotificationRead(String notificationId) {
    return studentApi.markNotificationRead(notificationId);
  }

  Future<List<Map<String, dynamic>>> getSeatMap() {
    return studentApi.getSeatMap();
  }

  Future<void> requestSeatChange({
    required String toSeatId,
    String? reason,
  }) {
    return studentApi.requestSeatChange(toSeatId: toSeatId, reason: reason);
  }

  StudyPlanItem _mapPlan(StudyPlan plan) {
    return StudyPlanItem(
      id: plan.id,
      subject: plan.subjectName,
      detail: plan.title,
      targetHours: (plan.targetMinutes / 60).ceil(),
      priority: _priorityFromApi(plan.priority),
      progress: plan.status == 'completed' ? 1.0 : 0.0,
    );
  }

  StudyRecord _mapLog(StudyLog log) {
    final date = DateTime.tryParse(log.logDate);
    final displayDate = date == null
        ? log.logDate
        : '${date.month}월 ${date.day}일';
    return StudyRecord(
      date: displayDate,
      subject: log.subjectName,
      studyMinutes: (log.progressPercent * 60).round(),
      goalAchieved: log.isCompleted,
      goalDetail: log.memo ?? log.subjectName,
    );
  }

  NotificationItem _mapNotification(Map<String, dynamic> raw) {
    final notification = raw['notification'] as Map<String, dynamic>? ?? raw;
    final readAt = raw['readAt'];
    return NotificationItem(
      id: raw['id'] as String? ?? notification['id'] as String? ?? '',
      title: notification['title'] as String? ?? '',
      body: notification['body'] as String? ?? '',
      type: (notification['notificationType'] as String? ?? 'notice')
          .toLowerCase(),
      timeAgo: _timeAgo(
        notification['createdAt'] as String? ??
            raw['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      isRead: readAt != null,
    );
  }

  String _priorityToApi(String priority) {
    switch (priority) {
      case '높음':
        return 'high';
      case '낮음':
        return 'low';
      default:
        return 'medium';
    }
  }

  String _priorityFromApi(String priority) {
    switch (priority) {
      case 'high':
        return '높음';
      case 'low':
        return '낮음';
      default:
        return '보통';
    }
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _timeAgo(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
