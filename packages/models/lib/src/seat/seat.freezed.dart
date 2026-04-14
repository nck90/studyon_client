// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Seat _$SeatFromJson(Map<String, dynamic> json) {
  return _Seat.fromJson(json);
}

/// @nodoc
mixin _$Seat {
  String get id => throw _privateConstructorUsedError;
  String get seatNo => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get zone => throw _privateConstructorUsedError;
  String? get assignedStudentId => throw _privateConstructorUsedError;
  String? get assignedStudentName => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  bool get isReserved => throw _privateConstructorUsedError;

  /// Serializes this Seat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeatCopyWith<Seat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeatCopyWith<$Res> {
  factory $SeatCopyWith(Seat value, $Res Function(Seat) then) =
      _$SeatCopyWithImpl<$Res, Seat>;
  @useResult
  $Res call({
    String id,
    String seatNo,
    String status,
    String? zone,
    String? assignedStudentId,
    String? assignedStudentName,
    bool isLocked,
    bool isReserved,
  });
}

/// @nodoc
class _$SeatCopyWithImpl<$Res, $Val extends Seat>
    implements $SeatCopyWith<$Res> {
  _$SeatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? seatNo = null,
    Object? status = null,
    Object? zone = freezed,
    Object? assignedStudentId = freezed,
    Object? assignedStudentName = freezed,
    Object? isLocked = null,
    Object? isReserved = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            seatNo: null == seatNo
                ? _value.seatNo
                : seatNo // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            zone: freezed == zone
                ? _value.zone
                : zone // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedStudentId: freezed == assignedStudentId
                ? _value.assignedStudentId
                : assignedStudentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedStudentName: freezed == assignedStudentName
                ? _value.assignedStudentName
                : assignedStudentName // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLocked: null == isLocked
                ? _value.isLocked
                : isLocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isReserved: null == isReserved
                ? _value.isReserved
                : isReserved // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SeatImplCopyWith<$Res> implements $SeatCopyWith<$Res> {
  factory _$$SeatImplCopyWith(
    _$SeatImpl value,
    $Res Function(_$SeatImpl) then,
  ) = __$$SeatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String seatNo,
    String status,
    String? zone,
    String? assignedStudentId,
    String? assignedStudentName,
    bool isLocked,
    bool isReserved,
  });
}

/// @nodoc
class __$$SeatImplCopyWithImpl<$Res>
    extends _$SeatCopyWithImpl<$Res, _$SeatImpl>
    implements _$$SeatImplCopyWith<$Res> {
  __$$SeatImplCopyWithImpl(_$SeatImpl _value, $Res Function(_$SeatImpl) _then)
    : super(_value, _then);

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? seatNo = null,
    Object? status = null,
    Object? zone = freezed,
    Object? assignedStudentId = freezed,
    Object? assignedStudentName = freezed,
    Object? isLocked = null,
    Object? isReserved = null,
  }) {
    return _then(
      _$SeatImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        seatNo: null == seatNo
            ? _value.seatNo
            : seatNo // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        zone: freezed == zone
            ? _value.zone
            : zone // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedStudentId: freezed == assignedStudentId
            ? _value.assignedStudentId
            : assignedStudentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedStudentName: freezed == assignedStudentName
            ? _value.assignedStudentName
            : assignedStudentName // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLocked: null == isLocked
            ? _value.isLocked
            : isLocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isReserved: null == isReserved
            ? _value.isReserved
            : isReserved // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SeatImpl extends _Seat {
  const _$SeatImpl({
    required this.id,
    required this.seatNo,
    required this.status,
    this.zone,
    this.assignedStudentId,
    this.assignedStudentName,
    this.isLocked = false,
    this.isReserved = false,
  }) : super._();

  factory _$SeatImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeatImplFromJson(json);

  @override
  final String id;
  @override
  final String seatNo;
  @override
  final String status;
  @override
  final String? zone;
  @override
  final String? assignedStudentId;
  @override
  final String? assignedStudentName;
  @override
  @JsonKey()
  final bool isLocked;
  @override
  @JsonKey()
  final bool isReserved;

  @override
  String toString() {
    return 'Seat(id: $id, seatNo: $seatNo, status: $status, zone: $zone, assignedStudentId: $assignedStudentId, assignedStudentName: $assignedStudentName, isLocked: $isLocked, isReserved: $isReserved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.seatNo, seatNo) || other.seatNo == seatNo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.assignedStudentId, assignedStudentId) ||
                other.assignedStudentId == assignedStudentId) &&
            (identical(other.assignedStudentName, assignedStudentName) ||
                other.assignedStudentName == assignedStudentName) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.isReserved, isReserved) ||
                other.isReserved == isReserved));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    seatNo,
    status,
    zone,
    assignedStudentId,
    assignedStudentName,
    isLocked,
    isReserved,
  );

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeatImplCopyWith<_$SeatImpl> get copyWith =>
      __$$SeatImplCopyWithImpl<_$SeatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeatImplToJson(this);
  }
}

abstract class _Seat extends Seat {
  const factory _Seat({
    required final String id,
    required final String seatNo,
    required final String status,
    final String? zone,
    final String? assignedStudentId,
    final String? assignedStudentName,
    final bool isLocked,
    final bool isReserved,
  }) = _$SeatImpl;
  const _Seat._() : super._();

  factory _Seat.fromJson(Map<String, dynamic> json) = _$SeatImpl.fromJson;

  @override
  String get id;
  @override
  String get seatNo;
  @override
  String get status;
  @override
  String? get zone;
  @override
  String? get assignedStudentId;
  @override
  String? get assignedStudentName;
  @override
  bool get isLocked;
  @override
  bool get isReserved;

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeatImplCopyWith<_$SeatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
