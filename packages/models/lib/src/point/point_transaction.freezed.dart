// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PointTransaction _$PointTransactionFromJson(Map<String, dynamic> json) {
  return _PointTransaction.fromJson(json);
}

/// @nodoc
mixin _$PointTransaction {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // EARN, SPEND
  String get source =>
      throw _privateConstructorUsedError; // STUDY_TIME, ATTENDANCE, STREAK_BONUS, BADGE_EARNED, ITEM_PURCHASE, ADMIN_GRANT
  int get amount => throw _privateConstructorUsedError;
  int get balance => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PointTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PointTransactionCopyWith<PointTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointTransactionCopyWith<$Res> {
  factory $PointTransactionCopyWith(
    PointTransaction value,
    $Res Function(PointTransaction) then,
  ) = _$PointTransactionCopyWithImpl<$Res, PointTransaction>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String type,
    String source,
    int amount,
    int balance,
    String? memo,
    String createdAt,
  });
}

/// @nodoc
class _$PointTransactionCopyWithImpl<$Res, $Val extends PointTransaction>
    implements $PointTransactionCopyWith<$Res> {
  _$PointTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? type = null,
    Object? source = null,
    Object? amount = null,
    Object? balance = null,
    Object? memo = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as int,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PointTransactionImplCopyWith<$Res>
    implements $PointTransactionCopyWith<$Res> {
  factory _$$PointTransactionImplCopyWith(
    _$PointTransactionImpl value,
    $Res Function(_$PointTransactionImpl) then,
  ) = __$$PointTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String type,
    String source,
    int amount,
    int balance,
    String? memo,
    String createdAt,
  });
}

/// @nodoc
class __$$PointTransactionImplCopyWithImpl<$Res>
    extends _$PointTransactionCopyWithImpl<$Res, _$PointTransactionImpl>
    implements _$$PointTransactionImplCopyWith<$Res> {
  __$$PointTransactionImplCopyWithImpl(
    _$PointTransactionImpl _value,
    $Res Function(_$PointTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? type = null,
    Object? source = null,
    Object? amount = null,
    Object? balance = null,
    Object? memo = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$PointTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as int,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PointTransactionImpl implements _PointTransaction {
  const _$PointTransactionImpl({
    required this.id,
    required this.studentId,
    required this.type,
    required this.source,
    required this.amount,
    required this.balance,
    this.memo,
    required this.createdAt,
  });

  factory _$PointTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String type;
  // EARN, SPEND
  @override
  final String source;
  // STUDY_TIME, ATTENDANCE, STREAK_BONUS, BADGE_EARNED, ITEM_PURCHASE, ADMIN_GRANT
  @override
  final int amount;
  @override
  final int balance;
  @override
  final String? memo;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'PointTransaction(id: $id, studentId: $studentId, type: $type, source: $source, amount: $amount, balance: $balance, memo: $memo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    type,
    source,
    amount,
    balance,
    memo,
    createdAt,
  );

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PointTransactionImplCopyWith<_$PointTransactionImpl> get copyWith =>
      __$$PointTransactionImplCopyWithImpl<_$PointTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PointTransactionImplToJson(this);
  }
}

abstract class _PointTransaction implements PointTransaction {
  const factory _PointTransaction({
    required final String id,
    required final String studentId,
    required final String type,
    required final String source,
    required final int amount,
    required final int balance,
    final String? memo,
    required final String createdAt,
  }) = _$PointTransactionImpl;

  factory _PointTransaction.fromJson(Map<String, dynamic> json) =
      _$PointTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get type; // EARN, SPEND
  @override
  String get source; // STUDY_TIME, ATTENDANCE, STREAK_BONUS, BADGE_EARNED, ITEM_PURCHASE, ADMIN_GRANT
  @override
  int get amount;
  @override
  int get balance;
  @override
  String? get memo;
  @override
  String get createdAt;

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointTransactionImplCopyWith<_$PointTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PointBalance _$PointBalanceFromJson(Map<String, dynamic> json) {
  return _PointBalance.fromJson(json);
}

/// @nodoc
mixin _$PointBalance {
  int get balance => throw _privateConstructorUsedError;

  /// Serializes this PointBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PointBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PointBalanceCopyWith<PointBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointBalanceCopyWith<$Res> {
  factory $PointBalanceCopyWith(
    PointBalance value,
    $Res Function(PointBalance) then,
  ) = _$PointBalanceCopyWithImpl<$Res, PointBalance>;
  @useResult
  $Res call({int balance});
}

/// @nodoc
class _$PointBalanceCopyWithImpl<$Res, $Val extends PointBalance>
    implements $PointBalanceCopyWith<$Res> {
  _$PointBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PointBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? balance = null}) {
    return _then(
      _value.copyWith(
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PointBalanceImplCopyWith<$Res>
    implements $PointBalanceCopyWith<$Res> {
  factory _$$PointBalanceImplCopyWith(
    _$PointBalanceImpl value,
    $Res Function(_$PointBalanceImpl) then,
  ) = __$$PointBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int balance});
}

/// @nodoc
class __$$PointBalanceImplCopyWithImpl<$Res>
    extends _$PointBalanceCopyWithImpl<$Res, _$PointBalanceImpl>
    implements _$$PointBalanceImplCopyWith<$Res> {
  __$$PointBalanceImplCopyWithImpl(
    _$PointBalanceImpl _value,
    $Res Function(_$PointBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? balance = null}) {
    return _then(
      _$PointBalanceImpl(
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PointBalanceImpl implements _PointBalance {
  const _$PointBalanceImpl({this.balance = 0});

  factory _$PointBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointBalanceImplFromJson(json);

  @override
  @JsonKey()
  final int balance;

  @override
  String toString() {
    return 'PointBalance(balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointBalanceImpl &&
            (identical(other.balance, balance) || other.balance == balance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, balance);

  /// Create a copy of PointBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PointBalanceImplCopyWith<_$PointBalanceImpl> get copyWith =>
      __$$PointBalanceImplCopyWithImpl<_$PointBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointBalanceImplToJson(this);
  }
}

abstract class _PointBalance implements PointBalance {
  const factory _PointBalance({final int balance}) = _$PointBalanceImpl;

  factory _PointBalance.fromJson(Map<String, dynamic> json) =
      _$PointBalanceImpl.fromJson;

  @override
  int get balance;

  /// Create a copy of PointBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointBalanceImplCopyWith<_$PointBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
