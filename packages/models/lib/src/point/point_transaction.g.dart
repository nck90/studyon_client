// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointTransactionImpl _$$PointTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$PointTransactionImpl(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  type: json['type'] as String,
  source: json['source'] as String,
  amount: (json['amount'] as num).toInt(),
  balance: (json['balance'] as num).toInt(),
  memo: json['memo'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$PointTransactionImplToJson(
  _$PointTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'type': instance.type,
  'source': instance.source,
  'amount': instance.amount,
  'balance': instance.balance,
  'memo': instance.memo,
  'createdAt': instance.createdAt,
};

_$PointBalanceImpl _$$PointBalanceImplFromJson(Map<String, dynamic> json) =>
    _$PointBalanceImpl(balance: (json['balance'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$$PointBalanceImplToJson(_$PointBalanceImpl instance) =>
    <String, dynamic>{'balance': instance.balance};
