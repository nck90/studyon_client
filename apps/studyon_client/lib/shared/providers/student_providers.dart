import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_client/shared/repositories/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepository(),
);

// ── Data Models ──

class StudyPlanItem {
  final String id;
  final String subject;
  final String detail;
  final int targetHours;
  final String priority;
  final double progress;

  const StudyPlanItem({
    required this.id,
    required this.subject,
    required this.detail,
    this.targetHours = 3,
    this.priority = '보통',
    this.progress = 0.0,
  });
}

class StudyRecord {
  final String date;
  final String subject;
  final int studyMinutes;
  final bool goalAchieved;
  final String goalDetail;

  const StudyRecord({
    required this.date,
    required this.subject,
    required this.studyMinutes,
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
  final int weeklyStudyMinutes;
  final int monthlyStudyMinutes;
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
  final List<NotificationItem> notifications;
  final bool isDarkMode;
  final bool isStudying;

  const StudentState({
    this.name = '김민수',
    this.studentNo = '2401',
    this.grade = '고3',
    this.className = 'A반',
    this.seatNo = 'A-12',
    this.isCheckedIn = false,
    this.checkInTime,
    this.todayStudySeconds = 0,
    this.todayBreakSeconds = 0,
    this.weeklyStudyMinutes = 1020,
    this.monthlyStudyMinutes = 4080,
    this.streakDays = 7,
    this.todayRank = 3,
    this.goalProgress = 0.0,
    this.goalSubject = '',
    this.goalDetail = '',
    this.goalHours = 3,
    this.plans = const [],
    this.recentRecords = const [],
    this.level = 2,
    this.totalPoints = 1250,
    this.badges = const [],
    this.notifications = const [],
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
    int? weeklyStudyMinutes,
    int? monthlyStudyMinutes,
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
    List<NotificationItem>? notifications,
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
      weeklyStudyMinutes: weeklyStudyMinutes ?? this.weeklyStudyMinutes,
      monthlyStudyMinutes: monthlyStudyMinutes ?? this.monthlyStudyMinutes,
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
      notifications: notifications ?? this.notifications,
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
  StudentNotifier() : super(_initialState);

  static final _initialState = StudentState(
    goalSubject: '수학',
    goalDetail: '수1 3단원 문제풀이',
    goalHours: 3,
    goalProgress: 0.74,
    plans: const [
      StudyPlanItem(
        id: '1',
        subject: '수학',
        detail: '수1 3단원 문제풀이',
        targetHours: 3,
        priority: '높음',
        progress: 0.74,
      ),
      StudyPlanItem(
        id: '2',
        subject: '영어',
        detail: '단어 100개 암기',
        targetHours: 1,
        priority: '보통',
        progress: 0.0,
      ),
    ],
    recentRecords: const [
      StudyRecord(
        date: '4월 14일',
        subject: '수학',
        studyMinutes: 192,
        goalAchieved: true,
        goalDetail: '수1 3단원',
      ),
      StudyRecord(
        date: '4월 13일',
        subject: '영어',
        studyMinutes: 210,
        goalAchieved: true,
        goalDetail: '단어 암기',
      ),
      StudyRecord(
        date: '4월 12일',
        subject: '과학',
        studyMinutes: 168,
        goalAchieved: false,
        goalDetail: '화학 개념',
      ),
      StudyRecord(
        date: '4월 11일',
        subject: '국어',
        studyMinutes: 110,
        goalAchieved: false,
        goalDetail: '지문 분석',
      ),
      StudyRecord(
        date: '4월 10일',
        subject: '수학',
        studyMinutes: 195,
        goalAchieved: true,
        goalDetail: '기출 분석',
      ),
    ],
    badges: const ['7일연속', '첫100시간', 'TOP3'],
    notifications: const [
      NotificationItem(
        id: '1',
        title: '자습실 마감 안내',
        body: '오늘 자습실 21:30에 마감됩니다',
        type: 'announcement',
        timeAgo: '30분 전',
      ),
      NotificationItem(
        id: '2',
        title: '좌석 재배정',
        body: '내일 좌석 재배정이 있습니다',
        type: 'schedule',
        timeAgo: '2시간 전',
      ),
      NotificationItem(
        id: '3',
        title: '랭킹 축하',
        body: '이번 주 랭킹 3위를 달성했어요',
        type: 'ranking',
        timeAgo: '5시간 전',
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: '휴식 초과',
        body: '휴식 시간이 15분 초과되었어요',
        type: 'warning',
        timeAgo: '어제',
        isRead: true,
      ),
    ],
  );

  void checkIn() {
    state = state.copyWith(isCheckedIn: true, checkInTime: DateTime.now());
  }

  void checkOut() {
    state = state.copyWith(
      isCheckedIn: false,
      clearCheckInTime: true,
      todayStudySeconds: 0,
      todayBreakSeconds: 0,
    );
  }

  void addStudyTime(int seconds) {
    state = state.copyWith(
      todayStudySeconds: state.todayStudySeconds + seconds,
    );
  }

  void addBreakTime(int seconds) {
    state = state.copyWith(
      todayBreakSeconds: state.todayBreakSeconds + seconds,
    );
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

  void addPlan(StudyPlanItem plan) {
    state = state.copyWith(plans: [...state.plans, plan]);
  }

  void removePlan(String id) {
    state = state.copyWith(
      plans: state.plans.where((p) => p.id != id).toList(),
    );
  }

  void addPoints(int points) {
    state = state.copyWith(totalPoints: state.totalPoints + points);
  }

  void startStudying() => state = state.copyWith(isStudying: true);
  void stopStudying() => state = state.copyWith(isStudying: false);

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void markNotificationRead(String id) {
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
}

final studentProvider =
    StateNotifierProvider<StudentNotifier, StudentState>(
  (ref) => StudentNotifier(),
);
