import 'package:freezed_annotation/freezed_annotation.dart';

part 'seat.freezed.dart';
part 'seat.g.dart';

@freezed
class Seat with _$Seat {
  const Seat._();
  const factory Seat({
    required String id,
    required String seatNo,
    required String status,
    String? zone,
    String? assignedStudentId,
    String? assignedStudentName,
    @Default(false) bool isLocked,
    @Default(false) bool isReserved,
  }) = _Seat;

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
}
