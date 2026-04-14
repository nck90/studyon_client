// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Attendance _$AttendanceFromJson(Map<String, dynamic> json) {
  return _Attendance.fromJson(json);
}

/// @nodoc
mixin _$Attendance {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get attendanceDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get checkInAt => throw _privateConstructorUsedError;
  String? get checkOutAt => throw _privateConstructorUsedError;
  int get stayMinutes => throw _privateConstructorUsedError;
  bool get isLate => throw _privateConstructorUsedError;
  bool get isEarlyLeave => throw _privateConstructorUsedError;

  /// Serializes this Attendance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceCopyWith<Attendance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceCopyWith<$Res> {
  factory $AttendanceCopyWith(
    Attendance value,
    $Res Function(Attendance) then,
  ) = _$AttendanceCopyWithImpl<$Res, Attendance>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String attendanceDate,
    String status,
    String? checkInAt,
    String? checkOutAt,
    int stayMinutes,
    bool isLate,
    bool isEarlyLeave,
  });
}

/// @nodoc
class _$AttendanceCopyWithImpl<$Res, $Val extends Attendance>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? attendanceDate = null,
    Object? status = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? stayMinutes = null,
    Object? isLate = null,
    Object? isEarlyLeave = null,
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
            attendanceDate: null == attendanceDate
                ? _value.attendanceDate
                : attendanceDate // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            checkInAt: freezed == checkInAt
                ? _value.checkInAt
                : checkInAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkOutAt: freezed == checkOutAt
                ? _value.checkOutAt
                : checkOutAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            stayMinutes: null == stayMinutes
                ? _value.stayMinutes
                : stayMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            isLate: null == isLate
                ? _value.isLate
                : isLate // ignore: cast_nullable_to_non_nullable
                      as bool,
            isEarlyLeave: null == isEarlyLeave
                ? _value.isEarlyLeave
                : isEarlyLeave // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceImplCopyWith<$Res>
    implements $AttendanceCopyWith<$Res> {
  factory _$$AttendanceImplCopyWith(
    _$AttendanceImpl value,
    $Res Function(_$AttendanceImpl) then,
  ) = __$$AttendanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String attendanceDate,
    String status,
    String? checkInAt,
    String? checkOutAt,
    int stayMinutes,
    bool isLate,
    bool isEarlyLeave,
  });
}

/// @nodoc
class __$$AttendanceImplCopyWithImpl<$Res>
    extends _$AttendanceCopyWithImpl<$Res, _$AttendanceImpl>
    implements _$$AttendanceImplCopyWith<$Res> {
  __$$AttendanceImplCopyWithImpl(
    _$AttendanceImpl _value,
    $Res Function(_$AttendanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? attendanceDate = null,
    Object? status = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? stayMinutes = null,
    Object? isLate = null,
    Object? isEarlyLeave = null,
  }) {
    return _then(
      _$AttendanceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        attendanceDate: null == attendanceDate
            ? _value.attendanceDate
            : attendanceDate // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        checkInAt: freezed == checkInAt
            ? _value.checkInAt
            : checkInAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkOutAt: freezed == checkOutAt
            ? _value.checkOutAt
            : checkOutAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        stayMinutes: null == stayMinutes
            ? _value.stayMinutes
            : stayMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        isLate: null == isLate
            ? _value.isLate
            : isLate // ignore: cast_nullable_to_non_nullable
                  as bool,
        isEarlyLeave: null == isEarlyLeave
            ? _value.isEarlyLeave
            : isEarlyLeave // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceImpl extends _Attendance {
  const _$AttendanceImpl({
    required this.id,
    required this.studentId,
    required this.attendanceDate,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    this.stayMinutes = 0,
    this.isLate = false,
    this.isEarlyLeave = false,
  }) : super._();

  factory _$AttendanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String attendanceDate;
  @override
  final String status;
  @override
  final String? checkInAt;
  @override
  final String? checkOutAt;
  @override
  @JsonKey()
  final int stayMinutes;
  @override
  @JsonKey()
  final bool isLate;
  @override
  @JsonKey()
  final bool isEarlyLeave;

  @override
  String toString() {
    return 'Attendance(id: $id, studentId: $studentId, attendanceDate: $attendanceDate, status: $status, checkInAt: $checkInAt, checkOutAt: $checkOutAt, stayMinutes: $stayMinutes, isLate: $isLate, isEarlyLeave: $isEarlyLeave)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.attendanceDate, attendanceDate) ||
                other.attendanceDate == attendanceDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.checkInAt, checkInAt) ||
                other.checkInAt == checkInAt) &&
            (identical(other.checkOutAt, checkOutAt) ||
                other.checkOutAt == checkOutAt) &&
            (identical(other.stayMinutes, stayMinutes) ||
                other.stayMinutes == stayMinutes) &&
            (identical(other.isLate, isLate) || other.isLate == isLate) &&
            (identical(other.isEarlyLeave, isEarlyLeave) ||
                other.isEarlyLeave == isEarlyLeave));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    attendanceDate,
    status,
    checkInAt,
    checkOutAt,
    stayMinutes,
    isLate,
    isEarlyLeave,
  );

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceImplCopyWith<_$AttendanceImpl> get copyWith =>
      __$$AttendanceImplCopyWithImpl<_$AttendanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceImplToJson(this);
  }
}

abstract class _Attendance extends Attendance {
  const factory _Attendance({
    required final String id,
    required final String studentId,
    required final String attendanceDate,
    required final String status,
    final String? checkInAt,
    final String? checkOutAt,
    final int stayMinutes,
    final bool isLate,
    final bool isEarlyLeave,
  }) = _$AttendanceImpl;
  const _Attendance._() : super._();

  factory _Attendance.fromJson(Map<String, dynamic> json) =
      _$AttendanceImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get attendanceDate;
  @override
  String get status;
  @override
  String? get checkInAt;
  @override
  String? get checkOutAt;
  @override
  int get stayMinutes;
  @override
  bool get isLate;
  @override
  bool get isEarlyLeave;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceImplCopyWith<_$AttendanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
