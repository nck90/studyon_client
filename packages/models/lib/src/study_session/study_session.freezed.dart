// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudySession _$StudySessionFromJson(Map<String, dynamic> json) {
  return _StudySession.fromJson(json);
}

/// @nodoc
mixin _$StudySession {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get linkedPlanId => throw _privateConstructorUsedError;
  String? get startedAt => throw _privateConstructorUsedError;
  String? get endedAt => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;
  int get studySeconds => throw _privateConstructorUsedError;
  int get breakMinutes => throw _privateConstructorUsedError;
  int get breakSeconds => throw _privateConstructorUsedError;

  /// Serializes this StudySession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudySessionCopyWith<StudySession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudySessionCopyWith<$Res> {
  factory $StudySessionCopyWith(
    StudySession value,
    $Res Function(StudySession) then,
  ) = _$StudySessionCopyWithImpl<$Res, StudySession>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String status,
    String? linkedPlanId,
    String? startedAt,
    String? endedAt,
    int studyMinutes,
    int studySeconds,
    int breakMinutes,
    int breakSeconds,
  });
}

/// @nodoc
class _$StudySessionCopyWithImpl<$Res, $Val extends StudySession>
    implements $StudySessionCopyWith<$Res> {
  _$StudySessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? status = null,
    Object? linkedPlanId = freezed,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? studyMinutes = null,
    Object? studySeconds = null,
    Object? breakMinutes = null,
    Object? breakSeconds = null,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedPlanId: freezed == linkedPlanId
                ? _value.linkedPlanId
                : linkedPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            studySeconds: null == studySeconds
                ? _value.studySeconds
                : studySeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            breakMinutes: null == breakMinutes
                ? _value.breakMinutes
                : breakMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            breakSeconds: null == breakSeconds
                ? _value.breakSeconds
                : breakSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudySessionImplCopyWith<$Res>
    implements $StudySessionCopyWith<$Res> {
  factory _$$StudySessionImplCopyWith(
    _$StudySessionImpl value,
    $Res Function(_$StudySessionImpl) then,
  ) = __$$StudySessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String status,
    String? linkedPlanId,
    String? startedAt,
    String? endedAt,
    int studyMinutes,
    int studySeconds,
    int breakMinutes,
    int breakSeconds,
  });
}

/// @nodoc
class __$$StudySessionImplCopyWithImpl<$Res>
    extends _$StudySessionCopyWithImpl<$Res, _$StudySessionImpl>
    implements _$$StudySessionImplCopyWith<$Res> {
  __$$StudySessionImplCopyWithImpl(
    _$StudySessionImpl _value,
    $Res Function(_$StudySessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? status = null,
    Object? linkedPlanId = freezed,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? studyMinutes = null,
    Object? studySeconds = null,
    Object? breakMinutes = null,
    Object? breakSeconds = null,
  }) {
    return _then(
      _$StudySessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedPlanId: freezed == linkedPlanId
            ? _value.linkedPlanId
            : linkedPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        studySeconds: null == studySeconds
            ? _value.studySeconds
            : studySeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        breakMinutes: null == breakMinutes
            ? _value.breakMinutes
            : breakMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        breakSeconds: null == breakSeconds
            ? _value.breakSeconds
            : breakSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudySessionImpl extends _StudySession {
  const _$StudySessionImpl({
    required this.id,
    required this.studentId,
    required this.status,
    this.linkedPlanId,
    this.startedAt,
    this.endedAt,
    this.studyMinutes = 0,
    this.studySeconds = 0,
    this.breakMinutes = 0,
    this.breakSeconds = 0,
  }) : super._();

  factory _$StudySessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudySessionImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String status;
  @override
  final String? linkedPlanId;
  @override
  final String? startedAt;
  @override
  final String? endedAt;
  @override
  @JsonKey()
  final int studyMinutes;
  @override
  @JsonKey()
  final int studySeconds;
  @override
  @JsonKey()
  final int breakMinutes;
  @override
  @JsonKey()
  final int breakSeconds;

  @override
  String toString() {
    return 'StudySession(id: $id, studentId: $studentId, status: $status, linkedPlanId: $linkedPlanId, startedAt: $startedAt, endedAt: $endedAt, studyMinutes: $studyMinutes, studySeconds: $studySeconds, breakMinutes: $breakMinutes, breakSeconds: $breakSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudySessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.linkedPlanId, linkedPlanId) ||
                other.linkedPlanId == linkedPlanId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes) &&
            (identical(other.studySeconds, studySeconds) ||
                other.studySeconds == studySeconds) &&
            (identical(other.breakMinutes, breakMinutes) ||
                other.breakMinutes == breakMinutes) &&
            (identical(other.breakSeconds, breakSeconds) ||
                other.breakSeconds == breakSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    status,
    linkedPlanId,
    startedAt,
    endedAt,
    studyMinutes,
    studySeconds,
    breakMinutes,
    breakSeconds,
  );

  /// Create a copy of StudySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudySessionImplCopyWith<_$StudySessionImpl> get copyWith =>
      __$$StudySessionImplCopyWithImpl<_$StudySessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudySessionImplToJson(this);
  }
}

abstract class _StudySession extends StudySession {
  const factory _StudySession({
    required final String id,
    required final String studentId,
    required final String status,
    final String? linkedPlanId,
    final String? startedAt,
    final String? endedAt,
    final int studyMinutes,
    final int studySeconds,
    final int breakMinutes,
    final int breakSeconds,
  }) = _$StudySessionImpl;
  const _StudySession._() : super._();

  factory _StudySession.fromJson(Map<String, dynamic> json) =
      _$StudySessionImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get status;
  @override
  String? get linkedPlanId;
  @override
  String? get startedAt;
  @override
  String? get endedAt;
  @override
  int get studyMinutes;
  @override
  int get studySeconds;
  @override
  int get breakMinutes;
  @override
  int get breakSeconds;

  /// Create a copy of StudySession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudySessionImplCopyWith<_$StudySessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
