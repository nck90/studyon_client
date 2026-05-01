import 'package:freezed_annotation/freezed_annotation.dart';

part 'point_transaction.freezed.dart';
part 'point_transaction.g.dart';

@freezed
class PointTransaction with _$PointTransaction {
  const factory PointTransaction({
    required String id,
    required String studentId,
    required String type, // EARN, SPEND
    required String source, // STUDY_TIME, ATTENDANCE, STREAK_BONUS, BADGE_EARNED, ITEM_PURCHASE, ADMIN_GRANT
    required int amount,
    required int balance,
    String? memo,
    required String createdAt,
  }) = _PointTransaction;

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionFromJson(json);
}

@freezed
class PointBalance with _$PointBalance {
  const factory PointBalance({
    @Default(0) int balance,
  }) = _PointBalance;

  factory PointBalance.fromJson(Map<String, dynamic> json) =>
      _$PointBalanceFromJson(json);
}
