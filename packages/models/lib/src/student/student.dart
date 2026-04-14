import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
class Student with _$Student {
  const Student._();
  const factory Student({
    required String id,
    required String studentNo,
    required String name,
    String? gradeId,
    String? classId,
    String? groupId,
    String? gradeName,
    String? className,
    String? groupName,
    String? assignedSeatId,
    String? assignedSeatNo,
    required String status,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}
