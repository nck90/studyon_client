import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/student_repository.dart';
import 'app_providers.dart';
import '../services/local_storage.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(
    authNotifier: ref.read(authNotifierProvider.notifier),
    studentApi: ref.read(studentApiProvider),
    dio: ref.read(authenticatedApiClientProvider).dio,
  );
});

// ── Data Models ──

class StudyPlanItem {
  final String id;
  final String subject;
  final String detail;
  final int targetMinutes;
  final int priorityStars;
  final double progress;
  final String planDate;

  const StudyPlanItem({
    required this.id,
    required this.subject,
    required this.detail,
    this.targetMinutes = 60,
    this.priorityStars = 3,
    this.progress = 0.0,
    this.planDate = '',
  });

  int get targetHours => (targetMinutes / 60).ceil();

  String get targetLabel {
    final h = targetMinutes ~/ 60;
    final m = targetMinutes % 60;
    if (h == 0) return '${m}분';
    if (m == 0) return '${h}시간';
    return '${h}시간 ${m}분';
  }
}

class StudyRecord {
  final String date;
  final String subject;
  final int studyMinutes;
  final int studySeconds;
  final bool goalAchieved;
  final String goalDetail;

  const StudyRecord({
    required this.date,
    required this.subject,
    required this.studyMinutes,
    required this.studySeconds,
    required this.goalAchieved,
    required this.goalDetail,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // announcement, schedule, ranking, warning, achievement
  final String timeAgo;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
  });
}

class RecommendedPlanItem {
  final String subject;
  final String detail;
  final int targetMinutes;

  const RecommendedPlanItem({
    required this.subject,
    required this.detail,
    required this.targetMinutes,
  });
}

class StudentRecommendation {
  final int recommendedTargetMinutes;
  final List<String> focusSubjects;
  final List<RecommendedPlanItem> planTemplate;
  final String riskLevel;

  const StudentRecommendation({
    this.recommendedTargetMinutes = 0,
    this.focusSubjects = const [],
    this.planTemplate = const [],
    this.riskLevel = 'LOW',
  });
}

// ── Student Session State ──

class StudentState {
  final String name;
  final String studentNo;
  final String grade;
  final String className;
  final String seatNo;
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final int todayStudySeconds;
  final int todayBreakSeconds;
  final int todayTargetMinutes;
  final int todayAttendanceMinutes;
  final double dailyAchievedRate;
  final int weeklyStudyMinutes;
  final int weeklyStudySeconds;
  final int weeklyTargetMinutes;
  final double weeklyAchievedRate;
  final int weeklyPagesCompleted;
  final int weeklyProblemsSolved;
  final int monthlyStudyMinutes;
  final int monthlyStudySeconds;
  final int monthlyTargetMinutes;
  final double monthlyAchievedRate;
  final int monthlyPagesCompleted;
  final int monthlyProblemsSolved;
  final int streakDays;
  final int todayRank;
  final double goalProgress;
  final String goalSubject;
  final String goalDetail;
  final int goalHours;
  final List<StudyPlanItem> plans;
  final List<StudyRecord> recentRecords;
  final int level; // 1=초보, 2=집중러, 3=숙련자, 4=마스터
  final int totalPoints;
  final List<String> badges;
  final bool notificationEnabled;
  final List<NotificationItem> notifications;
  final List<int> hourlyStudyMinutes;
  final Map<String, int> dailySubjectSeconds;
  final StudentRecommendation recommendation;
  final bool isDarkMode;
  final bool isStudying;

  const StudentState({
    this.name = '',
    this.studentNo = '',
    this.grade = '',
    this.className = '',
    this.seatNo = '',
    this.isCheckedIn = false,
    this.checkInTime,
    this.todayStudySeconds = 0,
    this.todayBreakSeconds = 0,
    this.todayTargetMinutes = 0,
    this.todayAttendanceMinutes = 0,
    this.dailyAchievedRate = 0,
    this.weeklyStudyMinutes = 0,
    this.weeklyStudySeconds = 0,
    this.weeklyTargetMinutes = 0,
    this.weeklyAchievedRate = 0,
    this.weeklyPagesCompleted = 0,
    this.weeklyProblemsSolved = 0,
    this.monthlyStudyMinutes = 0,
    this.monthlyStudySeconds = 0,
    this.monthlyTargetMinutes = 0,
    this.monthlyAchievedRate = 0,
    this.monthlyPagesCompleted = 0,
    this.monthlyProblemsSolved = 0,
    this.streakDays = 0,
    this.todayRank = 0,
    this.goalProgress = 0.0,
    this.goalSubject = '',
    this.goalDetail = '',
    this.goalHours = 0,
    this.plans = const [],
    this.recentRecords = const [],
    this.level = 1,
    this.totalPoints = 0,
    this.badges = const [],
    this.notificationEnabled = true,
    this.notifications = const [],
    this.hourlyStudyMinutes = const [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ],
    this.dailySubjectSeconds = const {},
    this.recommendation = const StudentRecommendation(),
    this.isDarkMode = false,
    this.isStudying = false,
  });

  StudentState copyWith({
    String? name,
    String? studentNo,
    String? grade,
    String? className,
    String? seatNo,
    bool? isCheckedIn,
    DateTime? checkInTime,
    bool clearCheckInTime = false,
    int? todayStudySeconds,
    int? todayBreakSeconds,
    int? todayTargetMinutes,
    int? todayAttendanceMinutes,
    double? dailyAchievedRate,
    int? weeklyStudyMinutes,
    int? weeklyStudySeconds,
    int? weeklyTargetMinutes,
    double? weeklyAchievedRate,
    int? weeklyPagesCompleted,
    int? weeklyProblemsSolved,
    int? monthlyStudyMinutes,
    int? monthlyStudySeconds,
    int? monthlyTargetMinutes,
    double? monthlyAchievedRate,
    int? monthlyPagesCompleted,
    int? monthlyProblemsSolved,
    int? streakDays,
    int? todayRank,
    double? goalProgress,
    String? goalSubject,
    String? goalDetail,
    int? goalHours,
    List<StudyPlanItem>? plans,
    List<StudyRecord>? recentRecords,
    int? level,
    int? totalPoints,
    List<String>? badges,
    bool? notificationEnabled,
    List<NotificationItem>? notifications,
    List<int>? hourlyStudyMinutes,
    Map<String, int>? dailySubjectSeconds,
    StudentRecommendation? recommendation,
    bool? isDarkMode,
    bool? isStudying,
  }) {
    return StudentState(
      name: name ?? this.name,
      studentNo: studentNo ?? this.studentNo,
      grade: grade ?? this.grade,
      className: className ?? this.className,
      seatNo: seatNo ?? this.seatNo,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      todayStudySeconds: todayStudySeconds ?? this.todayStudySeconds,
      todayBreakSeconds: todayBreakSeconds ?? this.todayBreakSeconds,
      todayTargetMinutes: todayTargetMinutes ?? this.todayTargetMinutes,
      todayAttendanceMinutes:
          todayAttendanceMinutes ?? this.todayAttendanceMinutes,
      dailyAchievedRate: dailyAchievedRate ?? this.dailyAchievedRate,
      weeklyStudyMinutes: weeklyStudyMinutes ?? this.weeklyStudyMinutes,
      weeklyStudySeconds: weeklyStudySeconds ?? this.weeklyStudySeconds,
      weeklyTargetMinutes: weeklyTargetMinutes ?? this.weeklyTargetMinutes,
      weeklyAchievedRate: weeklyAchievedRate ?? this.weeklyAchievedRate,
      weeklyPagesCompleted:
          weeklyPagesCompleted ?? this.weeklyPagesCompleted,
      weeklyProblemsSolved:
          weeklyProblemsSolved ?? this.weeklyProblemsSolved,
      monthlyStudyMinutes: monthlyStudyMinutes ?? this.monthlyStudyMinutes,
      monthlyStudySeconds: monthlyStudySeconds ?? this.monthlyStudySeconds,
      monthlyTargetMinutes: monthlyTargetMinutes ?? this.monthlyTargetMinutes,
      monthlyAchievedRate: monthlyAchievedRate ?? this.monthlyAchievedRate,
      monthlyPagesCompleted:
          monthlyPagesCompleted ?? this.monthlyPagesCompleted,
      monthlyProblemsSolved:
          monthlyProblemsSolved ?? this.monthlyProblemsSolved,
      streakDays: streakDays ?? this.streakDays,
      todayRank: todayRank ?? this.todayRank,
      goalProgress: goalProgress ?? this.goalProgress,
      goalSubject: goalSubject ?? this.goalSubject,
      goalDetail: goalDetail ?? this.goalDetail,
      goalHours: goalHours ?? this.goalHours,
      plans: plans ?? this.plans,
      recentRecords: recentRecords ?? this.recentRecords,
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notifications: notifications ?? this.notifications,
      hourlyStudyMinutes: hourlyStudyMinutes ?? this.hourlyStudyMinutes,
      dailySubjectSeconds: dailySubjectSeconds ?? this.dailySubjectSeconds,
      recommendation: recommendation ?? this.recommendation,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isStudying: isStudying ?? this.isStudying,
    );
  }

  String get todayStudyFormatted {
    final h = todayStudySeconds ~/ 3600;
    final m = (todayStudySeconds % 3600) ~/ 60;
    if (h > 0) return '$h시간 $m분';
    return '$m분';
  }

  String get levelName {
    switch (level) {
      case 1:
        return '초보';
      case 2:
        return '집중러';
      case 3:
        return '숙련자';
      case 4:
        return '마스터';
      default:
        return '초보';
    }
  }
}

// ── Notifier ──

class StudentNotifier extends StateNotifier<StudentState> {
  StudentNotifier(this._repository) : super(_initialState);

  final StudentRepository _repository;

  static const _initialState = StudentState();

  Future<void> hydrate() async {
    try {
      final next = await _repository.fetchState(isDarkMode: state.isDarkMode);
      state = next;
    } catch (_) {
      // Keep current state if hydration fails (e.g. new user with no data)
    }
  }

  Future<void> login(String loginId, String password) async {
    await _repository.login(loginId, password);
    await hydrate();
  }

  Future<void> signup({
    required String loginId,
    required String password,
    required String studentNo,
    required String name,
    String? phone,
  }) async {
    await _repository.signup(
      loginId: loginId,
      password: password,
      studentNo: studentNo,
      name: name,
      phone: phone,
    );
    await hydrate();
  }

  Future<void> logout() async {
    final isDarkMode = state.isDarkMode;
    await _repository.logout();
    state = StudentState(isDarkMode: isDarkMode);
  }

  Future<void> checkIn({String? seatId}) async {
    final checkInTime = await _repository.checkIn(seatId: seatId);
    state = state.copyWith(isCheckedIn: true, checkInTime: checkInTime);
    await hydrate();
  }

  Future<void> checkOut() async {
    await _repository.checkOut();
    await hydrate();
  }

  void addStudyTime(int seconds) {
    state = state.copyWith(todayStudySeconds: state.todayStudySeconds + seconds);
  }

  void addBreakTime(int seconds) {
    state = state.copyWith(todayBreakSeconds: state.todayBreakSeconds + seconds);
  }

  void setGoal(String subject, String detail, int hours) {
    state = state.copyWith(
      goalSubject: subject,
      goalDetail: detail,
      goalHours: hours,
      goalProgress: 0.0,
    );
  }

  void updateGoalProgress(double progress) {
    state = state.copyWith(goalProgress: progress.clamp(0.0, 1.0));
  }

  Future<void> addPlan(StudyPlanItem plan, {String? planDate}) async {
    await _repository.addPlan(
      subject: plan.subject,
      detail: plan.detail,
      targetMinutes: plan.targetMinutes,
      priorityStars: plan.priorityStars,
      planDate: planDate ?? plan.planDate,
    );
    await hydrate();
  }

  Future<void> updatePlan(StudyPlanItem plan) async {
    await _repository.updatePlan(
      planId: plan.id,
      subject: plan.subject,
      detail: plan.detail,
      targetMinutes: plan.targetMinutes,
      priorityStars: plan.priorityStars,
    );
    await hydrate();
  }

  Future<void> removePlan(String id) async {
    await _repository.deletePlan(id);
    await hydrate();
  }

  Future<void> completePlan(String id) async {
    await _repository.completePlan(id);
    await hydrate();
  }

  Future<void> applyRecommendation() async {
    final templates = state.recommendation.planTemplate;
    if (templates.isEmpty) return;

    final existingKeys = state.plans
        .map((plan) => '${plan.subject}|${plan.detail}')
        .toSet();

    for (final item in templates) {
      final key = '${item.subject}|${item.detail}';
      if (existingKeys.contains(key)) continue;
      await _repository.addPlan(
        subject: item.subject,
        detail: item.detail,
        targetMinutes: item.targetMinutes,
      );
      existingKeys.add(key);
    }

    await hydrate();
  }

  void addSessionRecord(String subject, int studyMinutes, bool goalAchieved) {
    final now = DateTime.now();
    final dateStr = '${now.month}월 ${now.day}일';
    final record = StudyRecord(
      date: dateStr,
      subject: subject.isEmpty ? '공부' : subject,
      studyMinutes: studyMinutes,
      studySeconds: studyMinutes * 60,
      goalAchieved: goalAchieved,
      goalDetail: state.goalDetail,
    );
    state = state.copyWith(
      recentRecords: [record, ...state.recentRecords].take(20).toList(),
    );
  }

  void addPoints(int points) {
    state = state.copyWith(totalPoints: state.totalPoints + points);
  }

  void startStudying() => state = state.copyWith(isStudying: true);
  void stopStudying() => state = state.copyWith(isStudying: false);

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    LocalStorage.setDarkMode(state.isDarkMode);
  }

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    LocalStorage.setDarkMode(value);
  }

  Future<void> markNotificationRead(String id) async {
    await _repository.markNotificationRead(id);
    state = state.copyWith(
      notifications: state.notifications
          .map(
            (n) => n.id == id
                ? NotificationItem(
                    id: n.id,
                    title: n.title,
                    body: n.body,
                    type: n.type,
                    timeAgo: n.timeAgo,
                    isRead: true,
                  )
                : n,
          )
          .toList(),
    );
  }

  Future<void> setNotificationEnabled(bool value) async {
    await _repository.updateNotificationPreference(value);
    state = state.copyWith(notificationEnabled: value);
  }
}

final studentProvider =
    StateNotifierProvider<StudentNotifier, StudentState>(
  (ref) => StudentNotifier(ref.read(studentRepositoryProvider)),
);
