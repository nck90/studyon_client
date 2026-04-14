import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

@freezed
class Attendance with _$Attendance {
  const Attendance._();
  const factory Attendance({
    required String id,
    required String studentId,
    required String attendanceDate,
    required String status,
    String? checkInAt,
    String? checkOutAt,
    @Default(0) int stayMinutes,
    @Default(false) bool isLate,
    @Default(false) bool isEarlyLeave,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}
