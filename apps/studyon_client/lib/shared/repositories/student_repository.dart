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

  Future<void> login(String loginId, String password) {
    return authNotifier.loginAsStudent(
      StudentLoginRequest(loginId: loginId, password: password),
    );
  }

  Future<void> signup({
    required String loginId,
    required String password,
    required String studentNo,
    required String name,
    String? phone,
  }) {
    return authNotifier.signupAsStudent(
      StudentSignupRequest(
        loginId: loginId,
        password: password,
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
    final todayIso = DateTime.now().toIso8601String().split('T').first;
    final homeRaw = await _safeMapData(
      '/student/home',
      fallback: const {
        'todayAttendance': {
          'status': 'NOT_CHECKED_IN',
          'checkInAt': null,
          'checkOutAt': null,
          'stayMinutes': 0,
        },
        'seat': null,
        'study': {
          'sessionStatus': 'READY',
          'studyMinutes': 0,
          'breakMinutes': 0,
        },
        'plans': {
          'totalCount': 0,
          'completedCount': 0,
          'targetMinutes': 0,
        },
        'notifications': [],
        'streakDays': 0,
        'student': {
          'id': '',
          'name': '',
          'studentNo': '',
          'className': null,
        },
      },
    );
    final dailyReport = await _safeAsync(
      () => studentApi.getDailyReport(),
      fallback: const DailyReport(
        date: '',
        attendanceStatus: 'NOT_CHECKED_IN',
      ),
    );
    final profile = await _safeAsync<Map<String, dynamic>>(
      () => studentApi.getProfile(),
      fallback: const {},
    );
    final plans = await _safeAsync<List<StudyPlan>>(
      () => studentApi.getStudyPlans(),
      fallback: const [],
    );
    final logPayloads = await _safeAsync<List<Map<String, dynamic>>>(
      _getStudyLogPayloads,
      fallback: const [],
    );
    final rankings = await _safeAsync(
      () => studentApi.getRankings(
        periodType: 'DAILY',
        rankingType: 'STUDY_TIME',
      ),
      fallback: const RankingResponse(
        myRank: MyRank(rankNo: 0, score: 0),
      ),
    );
    final notifications = await _safeAsync<List<Map<String, dynamic>>>(
      () => studentApi.getNotifications(),
      fallback: const [],
    );
    final badges = await _safeListData(
      '/student/badges',
      fallback: const [],
    );
    final weeklyData = await _safeMapData(
      '/student/reports/weekly',
      fallback: const {},
    );
    final monthlyData = await _safeMapData(
      '/student/reports/monthly',
      fallback: const {},
    );
    final recommendationData = await _safeMapData(
      '/student/insights/recommendation',
      fallback: const {},
    );
    final sessionPayloads = await _safeListData(
      '/student/study-sessions',
      queryParameters: {
        'startDate': todayIso,
        'endDate': todayIso,
      },
      fallback: const [],
    );

    final home = StudentHome.fromJson(homeRaw);
    final seatNo =
        home.seat?.seatNo ??
        ((profile['assignedSeat'] as Map<String, dynamic>?)?['seatNo']
                as String?) ??
        '';

    final studySeconds = sessionPayloads.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['studySeconds'] as num?)?.toInt() ?? 0),
    );
    final breakSeconds = sessionPayloads.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['breakSeconds'] as num?)?.toInt() ?? 0),
    );
    final studyMinutes =
        studySeconds > 0 ? studySeconds ~/ 60 : home.study?.studyMinutes ?? 0;
    final targetMinutes = home.plans?.targetMinutes ?? 0;
    final effectiveTargetMinutes = targetMinutes > 0 ? targetMinutes : 180;
    final firstPlan = plans.isNotEmpty ? plans.first : null;

    return StudentState(
      name: profile['user']?['name'] as String? ?? '',
      studentNo: profile['studentNo'] as String? ?? '',
      grade: profile['grade']?['name'] as String? ?? '',
      className: profile['class']?['name'] as String? ?? '',
      seatNo: seatNo,
      isCheckedIn: (home.todayAttendance?.status ?? '') == 'CHECKED_IN',
      checkInTime: _parseDateTime(home.todayAttendance?.checkInAt),
      todayStudySeconds:
          studySeconds > 0 ? studySeconds : dailyReport.studySeconds,
      todayBreakSeconds:
          breakSeconds > 0
              ? breakSeconds
              : (dailyReport.breakSeconds > 0
                    ? dailyReport.breakSeconds
                    : (home.study?.breakMinutes ?? 0) * 60),
      todayTargetMinutes: dailyReport.targetMinutes,
      todayAttendanceMinutes: dailyReport.attendanceMinutes,
      dailyAchievedRate: dailyReport.achievedRate,
      weeklyStudyMinutes: (weeklyData['studyMinutes'] as num?)?.toInt() ?? 0,
      weeklyStudySeconds: (weeklyData['studySeconds'] as num?)?.toInt() ?? 0,
      weeklyTargetMinutes:
          (weeklyData['targetMinutes'] as num?)?.toInt() ?? 0,
      weeklyAchievedRate:
          _toDouble(weeklyData['achievedRate'] ?? 0),
      weeklyPagesCompleted:
          (weeklyData['pagesCompleted'] as num?)?.toInt() ?? 0,
      weeklyProblemsSolved:
          (weeklyData['problemsSolved'] as num?)?.toInt() ?? 0,
      monthlyStudyMinutes: (monthlyData['studyMinutes'] as num?)?.toInt() ?? 0,
      monthlyStudySeconds:
          (monthlyData['studySeconds'] as num?)?.toInt() ?? 0,
      monthlyTargetMinutes:
          (monthlyData['targetMinutes'] as num?)?.toInt() ?? 0,
      monthlyAchievedRate:
          _toDouble(monthlyData['achievedRate'] ?? 0),
      monthlyPagesCompleted:
          (monthlyData['pagesCompleted'] as num?)?.toInt() ?? 0,
      monthlyProblemsSolved:
          (monthlyData['problemsSolved'] as num?)?.toInt() ?? 0,
      streakDays: homeRaw['streakDays'] as int? ?? 0,
      todayRank: rankings.myRank.rankNo,
      goalProgress:
          (studyMinutes / effectiveTargetMinutes).clamp(0.0, 1.0),
      goalSubject: firstPlan?.subjectName ?? '',
      goalDetail: firstPlan?.title ?? '',
      goalHours: ((firstPlan?.targetMinutes ?? 0) / 60).ceil(),
      plans: plans.map(_mapPlan).toList()
        ..sort((a, b) => b.priorityStars.compareTo(a.priorityStars)),
      recentRecords: logPayloads.take(20).map(_mapLogPayload).toList(),
      level:
          (profile['profileStats']?['level'] as num?)?.toInt() ?? 1,
      totalPoints:
          (profile['profileStats']?['totalPoints'] as num?)?.toInt() ?? 0,
      badges: badges
          .map((item) => item['badge']?['name'] as String? ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
      notificationEnabled:
          profile['preferences']?['notificationEnabled'] != false,
      notifications: notifications.map(_mapNotification).toList(),
      hourlyStudyMinutes: _buildHourlyStudyMinutes(sessionPayloads),
      dailySubjectSeconds: {
        for (final item in dailyReport.subjectBreakdown)
          item.subjectName: item.studySeconds,
      },
      recommendation: _mapRecommendation(recommendationData),
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

  Future<List<StudyPlanItem>> getPlans({String? date}) async {
    final plans = await studentApi.getStudyPlans(date: date);
    return plans.map(_mapPlan).toList();
  }

  Future<StudyPlanItem> addPlan({
    required String subject,
    required String detail,
    required int targetMinutes,
    int priorityStars = 3,
    String? planDate,
  }) async {
    final iso = (planDate == null || planDate.isEmpty)
        ? DateTime.now().toIso8601String()
        : planDate;
    final plan = await studentApi.createStudyPlan(
      CreateStudyPlanRequest(
        planDate: iso,
        subjectName: subject,
        title: detail,
        targetMinutes: targetMinutes,
        priority: _starsToApi(priorityStars),
      ),
    );
    return _mapPlan(plan);
  }

  Future<StudyPlanItem> updatePlan({
    required String planId,
    required String subject,
    required String detail,
    required int targetMinutes,
    int priorityStars = 3,
  }) async {
    final plan = await studentApi.updateStudyPlan(planId, {
      'subjectName': subject,
      'title': detail,
      'targetMinutes': targetMinutes,
      'priority': _starsToApi(priorityStars),
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
    int studyMinutes = 0,
    int studySeconds = 0,
    int pagesCompleted = 0,
    int problemsSolved = 0,
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
        studyMinutes: studyMinutes,
        studySeconds: studySeconds,
        pagesCompleted: pagesCompleted,
        problemsSolved: problemsSolved,
        progressPercent: progressPercent,
        isCompleted: isCompleted,
        memo: memo,
      ),
    );
  }

  Future<List<StudyRecord>> getRecords() async {
    final logPayloads = await _getStudyLogPayloads();
    return logPayloads.map(_mapLogPayload).toList();
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

  Future<void> updateNotificationPreference(bool value) {
    return studentApi.updatePreferences(notificationEnabled: value);
  }

  Future<List<Map<String, dynamic>>> getSeatMap() {
    return studentApi.getSeatMap();
  }

  Future<({int checkedInStudentCount, int totalActiveStudents})>
      getCheckInLobbyStats() async {
    final data = await _safeMapData(
      '/student/home',
      fallback: const {},
    );
    final community = data['community'] as Map<String, dynamic>?;
    return (
      checkedInStudentCount:
          (community?['checkedInStudentCount'] as num?)?.toInt() ?? 0,
      totalActiveStudents:
          (community?['totalActiveStudents'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<String>> getSubjects() async {
    final response = await dio.get('/common/subjects');
    final list = response.data['data'] as List? ?? const [];
    return list.map((item) => item.toString()).toList();
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
      targetMinutes: plan.targetMinutes,
      priorityStars: _starsFromApi(plan.priority),
      progress: plan.status == 'completed' ? 1.0 : 0.0,
      planDate: plan.planDate,
    );
  }

  Future<List<Map<String, dynamic>>> _getStudyLogPayloads() async {
    final response = await dio.get('/student/study-logs');
    final list = response.data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<T> _safeAsync<T>(Future<T> Function() action, {required T fallback}) async {
    try {
      return await action();
    } catch (_) {
      return fallback;
    }
  }

  Future<Map<String, dynamic>> _safeMapData(
    String path, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> fallback,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<List<Map<String, dynamic>>> _safeListData(
    String path, {
    Map<String, dynamic>? queryParameters,
    required List<Map<String, dynamic>> fallback,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      final data = response.data['data'] as List? ?? const [];
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return fallback;
    }
  }

  StudyRecord _mapLogPayload(Map<String, dynamic> raw) {
    final logDate = raw['logDate'] as String? ?? '';
    final date = DateTime.tryParse(logDate);
    final displayDate = date == null ? logDate : '${date.month}월 ${date.day}일';
    final studySession = raw['studySession'] as Map<String, dynamic>?;
    final progressPercent = _toDouble(raw['progressPercent']);
    final studySeconds =
        (raw['studySeconds'] as num?)?.toInt() ??
        (studySession?['studySeconds'] as num?)?.toInt() ??
        ((studySession?['studyMinutes'] as num?)?.toInt() ?? 0) * 60;
    final studyMinutes =
        (raw['studyMinutes'] as num?)?.toInt() ??
        (studySeconds > 0
            ? (studySeconds / 60).ceil()
            : (studySession?['studyMinutes'] as num?)?.toInt() ??
                  (progressPercent > 0 ? (progressPercent * 60).round() : 0));
    final memo = (raw['memo'] as String?)?.trim();

    return StudyRecord(
      date: displayDate,
      subject: raw['subjectName'] as String? ?? '',
      studyMinutes: studyMinutes,
      studySeconds: studySeconds,
      goalAchieved: raw['isCompleted'] == true,
      goalDetail: (memo?.isNotEmpty ?? false)
          ? memo!
          : (raw['plan']?['title'] as String? ?? raw['subjectName'] as String? ?? ''),
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

  StudentRecommendation _mapRecommendation(Map<String, dynamic> raw) {
    final templates = (raw['recommendedPlanTemplate'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => RecommendedPlanItem(
            subject: item['subjectName'] as String? ?? '',
            detail: item['title'] as String? ?? '',
            targetMinutes: item['targetMinutes'] as int? ?? 0,
          ),
        )
        .where((item) => item.subject.isNotEmpty && item.detail.isNotEmpty)
        .toList();

    return StudentRecommendation(
      recommendedTargetMinutes: raw['recommendedTargetMinutes'] as int? ?? 0,
      focusSubjects: (raw['recommendedFocusSubjects'] as List? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(),
      planTemplate: templates,
      riskLevel: raw['riskLevel'] as String? ?? 'LOW',
    );
  }

  String _starsToApi(int stars) {
    if (stars >= 4) return 'HIGH';
    if (stars <= 2) return 'LOW';
    return 'MEDIUM';
  }

  int _starsFromApi(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return 5;
      case 'LOW':
        return 1;
      default:
        return 3;
    }
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  List<int> _buildHourlyStudyMinutes(List<Map<String, dynamic>> sessions) {
    final buckets = List<int>.filled(18, 0);

    for (final session in sessions) {
      final startedAt = _parseDateTime(session['startedAt'] as String?);
      final endedAt = _parseDateTime(session['endedAt'] as String?) ?? DateTime.now();
      if (startedAt == null || !endedAt.isAfter(startedAt)) continue;

      final breaks = ((session['studyBreaks'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort((a, b) => (_parseDateTime(a['startedAt'] as String?) ?? startedAt)
            .compareTo(_parseDateTime(b['startedAt'] as String?) ?? startedAt));

      var cursor = startedAt;
      for (final item in breaks) {
        final breakStart = _parseDateTime(item['startedAt'] as String?);
        final breakEnd = _parseDateTime(item['endedAt'] as String?);
        if (breakStart == null) continue;
        if (breakStart.isAfter(cursor)) {
          _addIntervalToBuckets(buckets, cursor, breakStart);
        }
        if (breakEnd != null && breakEnd.isAfter(cursor)) {
          cursor = breakEnd;
        }
      }

      if (endedAt.isAfter(cursor)) {
        _addIntervalToBuckets(buckets, cursor, endedAt);
      }
    }

    return buckets;
  }

  void _addIntervalToBuckets(List<int> buckets, DateTime start, DateTime end) {
    var cursor = start;
    while (end.isAfter(cursor)) {
      final nextHour = DateTime(
        cursor.year,
        cursor.month,
        cursor.day,
        cursor.hour + 1,
      );
      final boundary = end.isBefore(nextHour) ? end : nextHour;
      final minutes = boundary.difference(cursor).inMinutes;
      final index = cursor.hour - 6;
      if (minutes > 0 && index >= 0 && index < buckets.length) {
        buckets[index] += minutes;
      }
      cursor = boundary;
    }
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
