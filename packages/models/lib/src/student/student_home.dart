import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_home.freezed.dart';
part 'student_home.g.dart';

@freezed
class StudentHome with _$StudentHome {
  const StudentHome._();
  const factory StudentHome({
    required TodayAttendanceSummary? todayAttendance,
    required SeatSummary? seat,
    required StudySummary? study,
    required PlanSummary? plans,
    @Default([]) List<NotificationSummary> notifications,
  }) = _StudentHome;

  factory StudentHome.fromJson(Map<String, dynamic> json) =>
      _$StudentHomeFromJson(json);
}

@freezed
class TodayAttendanceSummary with _$TodayAttendanceSummary {
  const TodayAttendanceSummary._();
  const factory TodayAttendanceSummary({
    required String status,
    String? checkInAt,
    String? checkOutAt,
    @Default(0) int stayMinutes,
  }) = _TodayAttendanceSummary;

  factory TodayAttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$TodayAttendanceSummaryFromJson(json);
}

@freezed
class SeatSummary with _$SeatSummary {
  const SeatSummary._();
  const factory SeatSummary({
    required String seatId,
    required String seatNo,
    required String status,
  }) = _SeatSummary;

  factory SeatSummary.fromJson(Map<String, dynamic> json) =>
      _$SeatSummaryFromJson(json);
}

@freezed
class StudySummary with _$StudySummary {
  const StudySummary._();
  const factory StudySummary({
    required String sessionStatus,
    @Default(0) int studyMinutes,
    @Default(0) int breakMinutes,
  }) = _StudySummary;

  factory StudySummary.fromJson(Map<String, dynamic> json) =>
      _$StudySummaryFromJson(json);
}

@freezed
class PlanSummary with _$PlanSummary {
  const PlanSummary._();
  const factory PlanSummary({
    @Default(0) int totalCount,
    @Default(0) int completedCount,
    @Default(0) int targetMinutes,
  }) = _PlanSummary;

  factory PlanSummary.fromJson(Map<String, dynamic> json) =>
      _$PlanSummaryFromJson(json);
}

@freezed
class NotificationSummary with _$NotificationSummary {
  const NotificationSummary._();
  const factory NotificationSummary({
    required String id,
    required String title,
  }) = _NotificationSummary;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) =>
      _$NotificationSummaryFromJson(json);
}
