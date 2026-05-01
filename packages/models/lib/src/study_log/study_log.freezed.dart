// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudyLog _$StudyLogFromJson(Map<String, dynamic> json) {
  return _StudyLog.fromJson(json);
}

/// @nodoc
mixin _$StudyLog {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get logDate => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  String? get planId => throw _privateConstructorUsedError;
  String? get studySessionId => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;
  int get studySeconds => throw _privateConstructorUsedError;
  int get pagesCompleted => throw _privateConstructorUsedError;
  int get problemsSolved => throw _privateConstructorUsedError;
  double get progressPercent => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;

  /// Serializes this StudyLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyLogCopyWith<StudyLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyLogCopyWith<$Res> {
  factory $StudyLogCopyWith(StudyLog value, $Res Function(StudyLog) then) =
      _$StudyLogCopyWithImpl<$Res, StudyLog>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String logDate,
    String subjectName,
    String? planId,
    String? studySessionId,
    int studyMinutes,
    int studySeconds,
    int pagesCompleted,
    int problemsSolved,
    double progressPercent,
    bool isCompleted,
    String? memo,
  });
}

/// @nodoc
class _$StudyLogCopyWithImpl<$Res, $Val extends StudyLog>
    implements $StudyLogCopyWith<$Res> {
  _$StudyLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? logDate = null,
    Object? subjectName = null,
    Object? planId = freezed,
    Object? studySessionId = freezed,
    Object? studyMinutes = null,
    Object? studySeconds = null,
    Object? pagesCompleted = null,
    Object? problemsSolved = null,
    Object? progressPercent = null,
    Object? isCompleted = null,
    Object? memo = freezed,
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
            logDate: null == logDate
                ? _value.logDate
                : logDate // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            planId: freezed == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                      as String?,
            studySessionId: freezed == studySessionId
                ? _value.studySessionId
                : studySessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            studySeconds: null == studySeconds
                ? _value.studySeconds
                : studySeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            pagesCompleted: null == pagesCompleted
                ? _value.pagesCompleted
                : pagesCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            problemsSolved: null == problemsSolved
                ? _value.problemsSolved
                : problemsSolved // ignore: cast_nullable_to_non_nullable
                      as int,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudyLogImplCopyWith<$Res>
    implements $StudyLogCopyWith<$Res> {
  factory _$$StudyLogImplCopyWith(
    _$StudyLogImpl value,
    $Res Function(_$StudyLogImpl) then,
  ) = __$$StudyLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String logDate,
    String subjectName,
    String? planId,
    String? studySessionId,
    int studyMinutes,
    int studySeconds,
    int pagesCompleted,
    int problemsSolved,
    double progressPercent,
    bool isCompleted,
    String? memo,
  });
}

/// @nodoc
class __$$StudyLogImplCopyWithImpl<$Res>
    extends _$StudyLogCopyWithImpl<$Res, _$StudyLogImpl>
    implements _$$StudyLogImplCopyWith<$Res> {
  __$$StudyLogImplCopyWithImpl(
    _$StudyLogImpl _value,
    $Res Function(_$StudyLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? logDate = null,
    Object? subjectName = null,
    Object? planId = freezed,
    Object? studySessionId = freezed,
    Object? studyMinutes = null,
    Object? studySeconds = null,
    Object? pagesCompleted = null,
    Object? problemsSolved = null,
    Object? progressPercent = null,
    Object? isCompleted = null,
    Object? memo = freezed,
  }) {
    return _then(
      _$StudyLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        logDate: null == logDate
            ? _value.logDate
            : logDate // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        planId: freezed == planId
            ? _value.planId
            : planId // ignore: cast_nullable_to_non_nullable
                  as String?,
        studySessionId: freezed == studySessionId
            ? _value.studySessionId
            : studySessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        studySeconds: null == studySeconds
            ? _value.studySeconds
            : studySeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        pagesCompleted: null == pagesCompleted
            ? _value.pagesCompleted
            : pagesCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        problemsSolved: null == problemsSolved
            ? _value.problemsSolved
            : problemsSolved // ignore: cast_nullable_to_non_nullable
                  as int,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyLogImpl extends _StudyLog {
  const _$StudyLogImpl({
    required this.id,
    required this.studentId,
    required this.logDate,
    required this.subjectName,
    this.planId,
    this.studySessionId,
    this.studyMinutes = 0,
    this.studySeconds = 0,
    this.pagesCompleted = 0,
    this.problemsSolved = 0,
    this.progressPercent = 0,
    this.isCompleted = false,
    this.memo,
  }) : super._();

  factory _$StudyLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyLogImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String logDate;
  @override
  final String subjectName;
  @override
  final String? planId;
  @override
  final String? studySessionId;
  @override
  @JsonKey()
  final int studyMinutes;
  @override
  @JsonKey()
  final int studySeconds;
  @override
  @JsonKey()
  final int pagesCompleted;
  @override
  @JsonKey()
  final int problemsSolved;
  @override
  @JsonKey()
  final double progressPercent;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final String? memo;

  @override
  String toString() {
    return 'StudyLog(id: $id, studentId: $studentId, logDate: $logDate, subjectName: $subjectName, planId: $planId, studySessionId: $studySessionId, studyMinutes: $studyMinutes, studySeconds: $studySeconds, pagesCompleted: $pagesCompleted, problemsSolved: $problemsSolved, progressPercent: $progressPercent, isCompleted: $isCompleted, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.studySessionId, studySessionId) ||
                other.studySessionId == studySessionId) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes) &&
            (identical(other.studySeconds, studySeconds) ||
                other.studySeconds == studySeconds) &&
            (identical(other.pagesCompleted, pagesCompleted) ||
                other.pagesCompleted == pagesCompleted) &&
            (identical(other.problemsSolved, problemsSolved) ||
                other.problemsSolved == problemsSolved) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    logDate,
    subjectName,
    planId,
    studySessionId,
    studyMinutes,
    studySeconds,
    pagesCompleted,
    problemsSolved,
    progressPercent,
    isCompleted,
    memo,
  );

  /// Create a copy of StudyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyLogImplCopyWith<_$StudyLogImpl> get copyWith =>
      __$$StudyLogImplCopyWithImpl<_$StudyLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyLogImplToJson(this);
  }
}

abstract class _StudyLog extends StudyLog {
  const factory _StudyLog({
    required final String id,
    required final String studentId,
    required final String logDate,
    required final String subjectName,
    final String? planId,
    final String? studySessionId,
    final int studyMinutes,
    final int studySeconds,
    final int pagesCompleted,
    final int problemsSolved,
    final double progressPercent,
    final bool isCompleted,
    final String? memo,
  }) = _$StudyLogImpl;
  const _StudyLog._() : super._();

  factory _StudyLog.fromJson(Map<String, dynamic> json) =
      _$StudyLogImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get logDate;
  @override
  String get subjectName;
  @override
  String? get planId;
  @override
  String? get studySessionId;
  @override
  int get studyMinutes;
  @override
  int get studySeconds;
  @override
  int get pagesCompleted;
  @override
  int get problemsSolved;
  @override
  double get progressPercent;
  @override
  bool get isCompleted;
  @override
  String? get memo;

  /// Create a copy of StudyLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyLogImplCopyWith<_$StudyLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateStudyLogRequest _$CreateStudyLogRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateStudyLogRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateStudyLogRequest {
  String get logDate => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  String? get planId => throw _privateConstructorUsedError;
  String? get studySessionId => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;
  int get studySeconds => throw _privateConstructorUsedError;
  int get pagesCompleted => throw _privateConstructorUsedError;
  int get problemsSolved => throw _privateConstructorUsedError;
  double get progressPercent => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;

  /// Serializes this CreateStudyLogRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateStudyLogRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateStudyLogRequestCopyWith<CreateStudyLogRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStudyLogRequestCopyWith<$Res> {
  factory $CreateStudyLogRequestCopyWith(
    CreateStudyLogRequest value,
    $Res Function(CreateStudyLogRequest) then,
  ) = _$CreateStudyLogRequestCopyWithImpl<$Res, CreateStudyLogRequest>;
  @useResult
  $Res call({
    String logDate,
    String subjectName,
    String? planId,
    String? studySessionId,
    int studyMinutes,
    int studySeconds,
    int pagesCompleted,
    int problemsSolved,
    double progressPercent,
    bool isCompleted,
    String? memo,
  });
}

/// @nodoc
class _$CreateStudyLogRequestCopyWithImpl<
  $Res,
  $Val extends CreateStudyLogRequest
>
    implements $CreateStudyLogRequestCopyWith<$Res> {
  _$CreateStudyLogRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateStudyLogRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logDate = null,
    Object? subjectName = null,
    Object? planId = freezed,
    Object? studySessionId = freezed,
    Object? studyMinutes = null,
    Object? studySeconds = null,
    Object? pagesCompleted = null,
    Object? problemsSolved = null,
    Object? progressPercent = null,
    Object? isCompleted = null,
    Object? memo = freezed,
  }) {
    return _then(
      _value.copyWith(
            logDate: null == logDate
                ? _value.logDate
                : logDate // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            planId: freezed == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                      as String?,
            studySessionId: freezed == studySessionId
                ? _value.studySessionId
                : studySessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            studySeconds: null == studySeconds
                ? _value.studySeconds
                : studySeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            pagesCompleted: null == pagesCompleted
                ? _value.pagesCompleted
                : pagesCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            problemsSolved: null == problemsSolved
                ? _value.problemsSolved
                : problemsSolved // ignore: cast_nullable_to_non_nullable
                      as int,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateStudyLogRequestImplCopyWith<$Res>
    implements $CreateStudyLogRequestCopyWith<$Res> {
  factory _$$CreateStudyLogRequestImplCopyWith(
    _$CreateStudyLogRequestImpl value,
    $Res Function(_$CreateStudyLogRequestImpl) then,
  ) = __$$CreateStudyLogRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String logDate,
    String subjectName,
    String? planId,
    String? studySessionId,
    int studyMinutes,
    int studySeconds,
    int pagesCompleted,
    int problemsSolved,
    double progressPercent,
    bool isCompleted,
    String? memo,
  });
}

/// @nodoc
class __$$CreateStudyLogRequestImplCopyWithImpl<$Res>
    extends
        _$CreateStudyLogRequestCopyWithImpl<$Res, _$CreateStudyLogRequestImpl>
    implements _$$CreateStudyLogRequestImplCopyWith<$Res> {
  __$$CreateStudyLogRequestImplCopyWithImpl(
    _$CreateStudyLogRequestImpl _value,
    $Res Function(_$CreateStudyLogRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateStudyLogRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logDate = null,
    Object? subjectName = null,
    Object? planId = freezed,
    Object? studySessionId = freezed,
    Object? studyMinutes = null,
    Object? studySeconds = null,
    Object? pagesCompleted = null,
    Object? problemsSolved = null,
    Object? progressPercent = null,
    Object? isCompleted = null,
    Object? memo = freezed,
  }) {
    return _then(
      _$CreateStudyLogRequestImpl(
        logDate: null == logDate
            ? _value.logDate
            : logDate // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        planId: freezed == planId
            ? _value.planId
            : planId // ignore: cast_nullable_to_non_nullable
                  as String?,
        studySessionId: freezed == studySessionId
            ? _value.studySessionId
            : studySessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        studySeconds: null == studySeconds
            ? _value.studySeconds
            : studySeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        pagesCompleted: null == pagesCompleted
            ? _value.pagesCompleted
            : pagesCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        problemsSolved: null == problemsSolved
            ? _value.problemsSolved
            : problemsSolved // ignore: cast_nullable_to_non_nullable
                  as int,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStudyLogRequestImpl extends _CreateStudyLogRequest {
  const _$CreateStudyLogRequestImpl({
    required this.logDate,
    required this.subjectName,
    this.planId,
    this.studySessionId,
    this.studyMinutes = 0,
    this.studySeconds = 0,
    this.pagesCompleted = 0,
    this.problemsSolved = 0,
    this.progressPercent = 0,
    this.isCompleted = false,
    this.memo,
  }) : super._();

  factory _$CreateStudyLogRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStudyLogRequestImplFromJson(json);

  @override
  final String logDate;
  @override
  final String subjectName;
  @override
  final String? planId;
  @override
  final String? studySessionId;
  @override
  @JsonKey()
  final int studyMinutes;
  @override
  @JsonKey()
  final int studySeconds;
  @override
  @JsonKey()
  final int pagesCompleted;
  @override
  @JsonKey()
  final int problemsSolved;
  @override
  @JsonKey()
  final double progressPercent;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final String? memo;

  @override
  String toString() {
    return 'CreateStudyLogRequest(logDate: $logDate, subjectName: $subjectName, planId: $planId, studySessionId: $studySessionId, studyMinutes: $studyMinutes, studySeconds: $studySeconds, pagesCompleted: $pagesCompleted, problemsSolved: $problemsSolved, progressPercent: $progressPercent, isCompleted: $isCompleted, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStudyLogRequestImpl &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.studySessionId, studySessionId) ||
                other.studySessionId == studySessionId) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes) &&
            (identical(other.studySeconds, studySeconds) ||
                other.studySeconds == studySeconds) &&
            (identical(other.pagesCompleted, pagesCompleted) ||
                other.pagesCompleted == pagesCompleted) &&
            (identical(other.problemsSolved, problemsSolved) ||
                other.problemsSolved == problemsSolved) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    logDate,
    subjectName,
    planId,
    studySessionId,
    studyMinutes,
    studySeconds,
    pagesCompleted,
    problemsSolved,
    progressPercent,
    isCompleted,
    memo,
  );

  /// Create a copy of CreateStudyLogRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStudyLogRequestImplCopyWith<_$CreateStudyLogRequestImpl>
  get copyWith =>
      __$$CreateStudyLogRequestImplCopyWithImpl<_$CreateStudyLogRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStudyLogRequestImplToJson(this);
  }
}

abstract class _CreateStudyLogRequest extends CreateStudyLogRequest {
  const factory _CreateStudyLogRequest({
    required final String logDate,
    required final String subjectName,
    final String? planId,
    final String? studySessionId,
    final int studyMinutes,
    final int studySeconds,
    final int pagesCompleted,
    final int problemsSolved,
    final double progressPercent,
    final bool isCompleted,
    final String? memo,
  }) = _$CreateStudyLogRequestImpl;
  const _CreateStudyLogRequest._() : super._();

  factory _CreateStudyLogRequest.fromJson(Map<String, dynamic> json) =
      _$CreateStudyLogRequestImpl.fromJson;

  @override
  String get logDate;
  @override
  String get subjectName;
  @override
  String? get planId;
  @override
  String? get studySessionId;
  @override
  int get studyMinutes;
  @override
  int get studySeconds;
  @override
  int get pagesCompleted;
  @override
  int get problemsSolved;
  @override
  double get progressPercent;
  @override
  bool get isCompleted;
  @override
  String? get memo;

  /// Create a copy of CreateStudyLogRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateStudyLogRequestImplCopyWith<_$CreateStudyLogRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
