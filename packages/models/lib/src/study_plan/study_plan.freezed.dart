// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudyPlan _$StudyPlanFromJson(Map<String, dynamic> json) {
  return _StudyPlan.fromJson(json);
}

/// @nodoc
mixin _$StudyPlan {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get planDate => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get targetMinutes => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this StudyPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyPlanCopyWith<StudyPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanCopyWith<$Res> {
  factory $StudyPlanCopyWith(StudyPlan value, $Res Function(StudyPlan) then) =
      _$StudyPlanCopyWithImpl<$Res, StudyPlan>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String planDate,
    String subjectName,
    String title,
    String? description,
    int targetMinutes,
    String priority,
    String status,
  });
}

/// @nodoc
class _$StudyPlanCopyWithImpl<$Res, $Val extends StudyPlan>
    implements $StudyPlanCopyWith<$Res> {
  _$StudyPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? planDate = null,
    Object? subjectName = null,
    Object? title = null,
    Object? description = freezed,
    Object? targetMinutes = null,
    Object? priority = null,
    Object? status = null,
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
            planDate: null == planDate
                ? _value.planDate
                : planDate // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetMinutes: null == targetMinutes
                ? _value.targetMinutes
                : targetMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudyPlanImplCopyWith<$Res>
    implements $StudyPlanCopyWith<$Res> {
  factory _$$StudyPlanImplCopyWith(
    _$StudyPlanImpl value,
    $Res Function(_$StudyPlanImpl) then,
  ) = __$$StudyPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String planDate,
    String subjectName,
    String title,
    String? description,
    int targetMinutes,
    String priority,
    String status,
  });
}

/// @nodoc
class __$$StudyPlanImplCopyWithImpl<$Res>
    extends _$StudyPlanCopyWithImpl<$Res, _$StudyPlanImpl>
    implements _$$StudyPlanImplCopyWith<$Res> {
  __$$StudyPlanImplCopyWithImpl(
    _$StudyPlanImpl _value,
    $Res Function(_$StudyPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? planDate = null,
    Object? subjectName = null,
    Object? title = null,
    Object? description = freezed,
    Object? targetMinutes = null,
    Object? priority = null,
    Object? status = null,
  }) {
    return _then(
      _$StudyPlanImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        planDate: null == planDate
            ? _value.planDate
            : planDate // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetMinutes: null == targetMinutes
            ? _value.targetMinutes
            : targetMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanImpl extends _StudyPlan {
  const _$StudyPlanImpl({
    required this.id,
    required this.studentId,
    required this.planDate,
    required this.subjectName,
    required this.title,
    this.description,
    this.targetMinutes = 0,
    this.priority = 'medium',
    this.status = 'pending',
  }) : super._();

  factory _$StudyPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String planDate;
  @override
  final String subjectName;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final int targetMinutes;
  @override
  @JsonKey()
  final String priority;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'StudyPlan(id: $id, studentId: $studentId, planDate: $planDate, subjectName: $subjectName, title: $title, description: $description, targetMinutes: $targetMinutes, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.planDate, planDate) ||
                other.planDate == planDate) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.targetMinutes, targetMinutes) ||
                other.targetMinutes == targetMinutes) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    planDate,
    subjectName,
    title,
    description,
    targetMinutes,
    priority,
    status,
  );

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPlanImplCopyWith<_$StudyPlanImpl> get copyWith =>
      __$$StudyPlanImplCopyWithImpl<_$StudyPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPlanImplToJson(this);
  }
}

abstract class _StudyPlan extends StudyPlan {
  const factory _StudyPlan({
    required final String id,
    required final String studentId,
    required final String planDate,
    required final String subjectName,
    required final String title,
    final String? description,
    final int targetMinutes,
    final String priority,
    final String status,
  }) = _$StudyPlanImpl;
  const _StudyPlan._() : super._();

  factory _StudyPlan.fromJson(Map<String, dynamic> json) =
      _$StudyPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get planDate;
  @override
  String get subjectName;
  @override
  String get title;
  @override
  String? get description;
  @override
  int get targetMinutes;
  @override
  String get priority;
  @override
  String get status;

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyPlanImplCopyWith<_$StudyPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateStudyPlanRequest _$CreateStudyPlanRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateStudyPlanRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateStudyPlanRequest {
  String get planDate => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get targetMinutes => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;

  /// Serializes this CreateStudyPlanRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateStudyPlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateStudyPlanRequestCopyWith<CreateStudyPlanRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStudyPlanRequestCopyWith<$Res> {
  factory $CreateStudyPlanRequestCopyWith(
    CreateStudyPlanRequest value,
    $Res Function(CreateStudyPlanRequest) then,
  ) = _$CreateStudyPlanRequestCopyWithImpl<$Res, CreateStudyPlanRequest>;
  @useResult
  $Res call({
    String planDate,
    String subjectName,
    String title,
    String? description,
    int targetMinutes,
    String priority,
  });
}

/// @nodoc
class _$CreateStudyPlanRequestCopyWithImpl<
  $Res,
  $Val extends CreateStudyPlanRequest
>
    implements $CreateStudyPlanRequestCopyWith<$Res> {
  _$CreateStudyPlanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateStudyPlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planDate = null,
    Object? subjectName = null,
    Object? title = null,
    Object? description = freezed,
    Object? targetMinutes = null,
    Object? priority = null,
  }) {
    return _then(
      _value.copyWith(
            planDate: null == planDate
                ? _value.planDate
                : planDate // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetMinutes: null == targetMinutes
                ? _value.targetMinutes
                : targetMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateStudyPlanRequestImplCopyWith<$Res>
    implements $CreateStudyPlanRequestCopyWith<$Res> {
  factory _$$CreateStudyPlanRequestImplCopyWith(
    _$CreateStudyPlanRequestImpl value,
    $Res Function(_$CreateStudyPlanRequestImpl) then,
  ) = __$$CreateStudyPlanRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String planDate,
    String subjectName,
    String title,
    String? description,
    int targetMinutes,
    String priority,
  });
}

/// @nodoc
class __$$CreateStudyPlanRequestImplCopyWithImpl<$Res>
    extends
        _$CreateStudyPlanRequestCopyWithImpl<$Res, _$CreateStudyPlanRequestImpl>
    implements _$$CreateStudyPlanRequestImplCopyWith<$Res> {
  __$$CreateStudyPlanRequestImplCopyWithImpl(
    _$CreateStudyPlanRequestImpl _value,
    $Res Function(_$CreateStudyPlanRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateStudyPlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planDate = null,
    Object? subjectName = null,
    Object? title = null,
    Object? description = freezed,
    Object? targetMinutes = null,
    Object? priority = null,
  }) {
    return _then(
      _$CreateStudyPlanRequestImpl(
        planDate: null == planDate
            ? _value.planDate
            : planDate // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetMinutes: null == targetMinutes
            ? _value.targetMinutes
            : targetMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStudyPlanRequestImpl extends _CreateStudyPlanRequest {
  const _$CreateStudyPlanRequestImpl({
    required this.planDate,
    required this.subjectName,
    required this.title,
    this.description,
    this.targetMinutes = 0,
    this.priority = 'medium',
  }) : super._();

  factory _$CreateStudyPlanRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStudyPlanRequestImplFromJson(json);

  @override
  final String planDate;
  @override
  final String subjectName;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final int targetMinutes;
  @override
  @JsonKey()
  final String priority;

  @override
  String toString() {
    return 'CreateStudyPlanRequest(planDate: $planDate, subjectName: $subjectName, title: $title, description: $description, targetMinutes: $targetMinutes, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStudyPlanRequestImpl &&
            (identical(other.planDate, planDate) ||
                other.planDate == planDate) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.targetMinutes, targetMinutes) ||
                other.targetMinutes == targetMinutes) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    planDate,
    subjectName,
    title,
    description,
    targetMinutes,
    priority,
  );

  /// Create a copy of CreateStudyPlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStudyPlanRequestImplCopyWith<_$CreateStudyPlanRequestImpl>
  get copyWith =>
      __$$CreateStudyPlanRequestImplCopyWithImpl<_$CreateStudyPlanRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStudyPlanRequestImplToJson(this);
  }
}

abstract class _CreateStudyPlanRequest extends CreateStudyPlanRequest {
  const factory _CreateStudyPlanRequest({
    required final String planDate,
    required final String subjectName,
    required final String title,
    final String? description,
    final int targetMinutes,
    final String priority,
  }) = _$CreateStudyPlanRequestImpl;
  const _CreateStudyPlanRequest._() : super._();

  factory _CreateStudyPlanRequest.fromJson(Map<String, dynamic> json) =
      _$CreateStudyPlanRequestImpl.fromJson;

  @override
  String get planDate;
  @override
  String get subjectName;
  @override
  String get title;
  @override
  String? get description;
  @override
  int get targetMinutes;
  @override
  String get priority;

  /// Create a copy of CreateStudyPlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateStudyPlanRequestImplCopyWith<_$CreateStudyPlanRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
