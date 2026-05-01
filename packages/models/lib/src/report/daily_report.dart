import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_report.freezed.dart';
part 'daily_report.g.dart';

@freezed
class DailyReport with _$DailyReport {
  const DailyReport._();
  const factory DailyReport({
    required String date,
    @Default(0) int attendanceMinutes,
    @Default(0) int studyMinutes,
    @Default(0) int studySeconds,
    @Default(0) int breakMinutes,
    @Default(0) int breakSeconds,
    @Default(0) int targetMinutes,
    @Default(0) double achievedRate,
    required String attendanceStatus,
    @Default([]) List<SubjectBreakdown> subjectBreakdown,
  }) = _DailyReport;

  factory DailyReport.fromJson(Map<String, dynamic> json) =>
      _$DailyReportFromJson(json);
}

@freezed
class SubjectBreakdown with _$SubjectBreakdown {
  const SubjectBreakdown._();
  const factory SubjectBreakdown({
    required String subjectName,
    @Default(0) int studyMinutes,
    @Default(0) int studySeconds,
  }) = _SubjectBreakdown;

  factory SubjectBreakdown.fromJson(Map<String, dynamic> json) =>
      _$SubjectBreakdownFromJson(json);
}
