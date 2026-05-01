import 'package:studyon_models/studyon_models.dart';

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

class DailyStat {
  const DailyStat({
    required this.date,
    required this.minutes,
    required this.count,
  });

  final String date;
  final int minutes;
  final int count;
}

class StudyOverviewData {
  const StudyOverviewData({
    required this.totalStudyMinutes,
    required this.avgStudyMinutes,
    required this.attendanceRate,
    required this.activeStudents,
    required this.dailyStats,
    required this.subjectStats,
  });

  final int totalStudyMinutes;
  final int avgStudyMinutes;
  final double attendanceRate;
  final int activeStudents;
  final List<DailyStat> dailyStats;
  final List<SubjectStat> subjectStats;
}

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

class TvDisplayData {
  const TvDisplayData({
    required this.isOn,
    required this.displayMode,
    required this.message,
    required this.rankings,
    required this.occupiedSeats,
    required this.totalSeats,
  });

  final bool isOn;
  final String displayMode;
  final String message;
  final List<RankingItem> rankings;
  final int occupiedSeats;
  final int totalSeats;
}

class AdminOption {
  const AdminOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class SubjectStat {
  const SubjectStat({
    required this.subject,
    required this.minutes,
  });

  final String subject;
  final int minutes;
}

class ActivityLogItem {
  const ActivityLogItem({
    required this.time,
    required this.label,
    required this.kind,
  });

  final String time;
  final String label;
  final String kind;
}

class AdminStudentDetail {
  const AdminStudentDetail({
    required this.student,
    required this.todayStudyMinutes,
    required this.weeklyStudyMinutes,
    required this.monthlyStudyMinutes,
    required this.attendanceRate,
    required this.weeklyStats,
    required this.subjectStats,
    required this.activityLogs,
  });

  final Student student;
  final int todayStudyMinutes;
  final int weeklyStudyMinutes;
  final int monthlyStudyMinutes;
  final double attendanceRate;
  final List<DailyStat> weeklyStats;
  final List<SubjectStat> subjectStats;
  final List<ActivityLogItem> activityLogs;
}

class AdminAttendanceRecord {
  const AdminAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentNo,
    required this.studentName,
    required this.status,
    required this.isLate,
    required this.stayMinutes,
    this.checkInAt,
    this.checkOutAt,
  });

  final String id;
  final String studentId;
  final String studentNo;
  final String studentName;
  final String status;
  final bool isLate;
  final int stayMinutes;
  final String? checkInAt;
  final String? checkOutAt;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.periodLabel,
    required this.attendanceRate,
    required this.avgStayMinutes,
    required this.lateCount,
    required this.absentCount,
    required this.totalCount,
  });

  final String periodLabel;
  final double attendanceRate;
  final int avgStayMinutes;
  final int lateCount;
  final int absentCount;
  final int totalCount;
}

class AdminFormOptions {
  const AdminFormOptions({
    required this.grades,
    required this.classes,
    required this.seats,
  });

  final List<AdminOption> grades;
  final List<AdminOption> classes;
  final List<AdminOption> seats;
}
