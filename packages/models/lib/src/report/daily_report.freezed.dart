// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyReport _$DailyReportFromJson(Map<String, dynamic> json) {
  return _DailyReport.fromJson(json);
}

/// @nodoc
mixin _$DailyReport {
  String get date => throw _privateConstructorUsedError;
  int get attendanceMinutes => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;
  int get breakMinutes => throw _privateConstructorUsedError;
  int get targetMinutes => throw _privateConstructorUsedError;
  double get achievedRate => throw _privateConstructorUsedError;
  String get attendanceStatus => throw _privateConstructorUsedError;
  List<SubjectBreakdown> get subjectBreakdown =>
      throw _privateConstructorUsedError;

  /// Serializes this DailyReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyReportCopyWith<DailyReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyReportCopyWith<$Res> {
  factory $DailyReportCopyWith(
    DailyReport value,
    $Res Function(DailyReport) then,
  ) = _$DailyReportCopyWithImpl<$Res, DailyReport>;
  @useResult
  $Res call({
    String date,
    int attendanceMinutes,
    int studyMinutes,
    int breakMinutes,
    int targetMinutes,
    double achievedRate,
    String attendanceStatus,
    List<SubjectBreakdown> subjectBreakdown,
  });
}

/// @nodoc
class _$DailyReportCopyWithImpl<$Res, $Val extends DailyReport>
    implements $DailyReportCopyWith<$Res> {
  _$DailyReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? attendanceMinutes = null,
    Object? studyMinutes = null,
    Object? breakMinutes = null,
    Object? targetMinutes = null,
    Object? achievedRate = null,
    Object? attendanceStatus = null,
    Object? subjectBreakdown = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            attendanceMinutes: null == attendanceMinutes
                ? _value.attendanceMinutes
                : attendanceMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            breakMinutes: null == breakMinutes
                ? _value.breakMinutes
                : breakMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            targetMinutes: null == targetMinutes
                ? _value.targetMinutes
                : targetMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            achievedRate: null == achievedRate
                ? _value.achievedRate
                : achievedRate // ignore: cast_nullable_to_non_nullable
                      as double,
            attendanceStatus: null == attendanceStatus
                ? _value.attendanceStatus
                : attendanceStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectBreakdown: null == subjectBreakdown
                ? _value.subjectBreakdown
                : subjectBreakdown // ignore: cast_nullable_to_non_nullable
                      as List<SubjectBreakdown>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyReportImplCopyWith<$Res>
    implements $DailyReportCopyWith<$Res> {
  factory _$$DailyReportImplCopyWith(
    _$DailyReportImpl value,
    $Res Function(_$DailyReportImpl) then,
  ) = __$$DailyReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    int attendanceMinutes,
    int studyMinutes,
    int breakMinutes,
    int targetMinutes,
    double achievedRate,
    String attendanceStatus,
    List<SubjectBreakdown> subjectBreakdown,
  });
}

/// @nodoc
class __$$DailyReportImplCopyWithImpl<$Res>
    extends _$DailyReportCopyWithImpl<$Res, _$DailyReportImpl>
    implements _$$DailyReportImplCopyWith<$Res> {
  __$$DailyReportImplCopyWithImpl(
    _$DailyReportImpl _value,
    $Res Function(_$DailyReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? attendanceMinutes = null,
    Object? studyMinutes = null,
    Object? breakMinutes = null,
    Object? targetMinutes = null,
    Object? achievedRate = null,
    Object? attendanceStatus = null,
    Object? subjectBreakdown = null,
  }) {
    return _then(
      _$DailyReportImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        attendanceMinutes: null == attendanceMinutes
            ? _value.attendanceMinutes
            : attendanceMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        breakMinutes: null == breakMinutes
            ? _value.breakMinutes
            : breakMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        targetMinutes: null == targetMinutes
            ? _value.targetMinutes
            : targetMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        achievedRate: null == achievedRate
            ? _value.achievedRate
            : achievedRate // ignore: cast_nullable_to_non_nullable
                  as double,
        attendanceStatus: null == attendanceStatus
            ? _value.attendanceStatus
            : attendanceStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectBreakdown: null == subjectBreakdown
            ? _value._subjectBreakdown
            : subjectBreakdown // ignore: cast_nullable_to_non_nullable
                  as List<SubjectBreakdown>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyReportImpl extends _DailyReport {
  const _$DailyReportImpl({
    required this.date,
    this.attendanceMinutes = 0,
    this.studyMinutes = 0,
    this.breakMinutes = 0,
    this.targetMinutes = 0,
    this.achievedRate = 0,
    required this.attendanceStatus,
    final List<SubjectBreakdown> subjectBreakdown = const [],
  }) : _subjectBreakdown = subjectBreakdown,
       super._();

  factory _$DailyReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyReportImplFromJson(json);

  @override
  final String date;
  @override
  @JsonKey()
  final int attendanceMinutes;
  @override
  @JsonKey()
  final int studyMinutes;
  @override
  @JsonKey()
  final int breakMinutes;
  @override
  @JsonKey()
  final int targetMinutes;
  @override
  @JsonKey()
  final double achievedRate;
  @override
  final String attendanceStatus;
  final List<SubjectBreakdown> _subjectBreakdown;
  @override
  @JsonKey()
  List<SubjectBreakdown> get subjectBreakdown {
    if (_subjectBreakdown is EqualUnmodifiableListView)
      return _subjectBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectBreakdown);
  }

  @override
  String toString() {
    return 'DailyReport(date: $date, attendanceMinutes: $attendanceMinutes, studyMinutes: $studyMinutes, breakMinutes: $breakMinutes, targetMinutes: $targetMinutes, achievedRate: $achievedRate, attendanceStatus: $attendanceStatus, subjectBreakdown: $subjectBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyReportImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.attendanceMinutes, attendanceMinutes) ||
                other.attendanceMinutes == attendanceMinutes) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes) &&
            (identical(other.breakMinutes, breakMinutes) ||
                other.breakMinutes == breakMinutes) &&
            (identical(other.targetMinutes, targetMinutes) ||
                other.targetMinutes == targetMinutes) &&
            (identical(other.achievedRate, achievedRate) ||
                other.achievedRate == achievedRate) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            const DeepCollectionEquality().equals(
              other._subjectBreakdown,
              _subjectBreakdown,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    attendanceMinutes,
    studyMinutes,
    breakMinutes,
    targetMinutes,
    achievedRate,
    attendanceStatus,
    const DeepCollectionEquality().hash(_subjectBreakdown),
  );

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyReportImplCopyWith<_$DailyReportImpl> get copyWith =>
      __$$DailyReportImplCopyWithImpl<_$DailyReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyReportImplToJson(this);
  }
}

abstract class _DailyReport extends DailyReport {
  const factory _DailyReport({
    required final String date,
    final int attendanceMinutes,
    final int studyMinutes,
    final int breakMinutes,
    final int targetMinutes,
    final double achievedRate,
    required final String attendanceStatus,
    final List<SubjectBreakdown> subjectBreakdown,
  }) = _$DailyReportImpl;
  const _DailyReport._() : super._();

  factory _DailyReport.fromJson(Map<String, dynamic> json) =
      _$DailyReportImpl.fromJson;

  @override
  String get date;
  @override
  int get attendanceMinutes;
  @override
  int get studyMinutes;
  @override
  int get breakMinutes;
  @override
  int get targetMinutes;
  @override
  double get achievedRate;
  @override
  String get attendanceStatus;
  @override
  List<SubjectBreakdown> get subjectBreakdown;

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyReportImplCopyWith<_$DailyReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubjectBreakdown _$SubjectBreakdownFromJson(Map<String, dynamic> json) {
  return _SubjectBreakdown.fromJson(json);
}

/// @nodoc
mixin _$SubjectBreakdown {
  String get subjectName => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;

  /// Serializes this SubjectBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectBreakdownCopyWith<SubjectBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectBreakdownCopyWith<$Res> {
  factory $SubjectBreakdownCopyWith(
    SubjectBreakdown value,
    $Res Function(SubjectBreakdown) then,
  ) = _$SubjectBreakdownCopyWithImpl<$Res, SubjectBreakdown>;
  @useResult
  $Res call({String subjectName, int studyMinutes});
}

/// @nodoc
class _$SubjectBreakdownCopyWithImpl<$Res, $Val extends SubjectBreakdown>
    implements $SubjectBreakdownCopyWith<$Res> {
  _$SubjectBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? subjectName = null, Object? studyMinutes = null}) {
    return _then(
      _value.copyWith(
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubjectBreakdownImplCopyWith<$Res>
    implements $SubjectBreakdownCopyWith<$Res> {
  factory _$$SubjectBreakdownImplCopyWith(
    _$SubjectBreakdownImpl value,
    $Res Function(_$SubjectBreakdownImpl) then,
  ) = __$$SubjectBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String subjectName, int studyMinutes});
}

/// @nodoc
class __$$SubjectBreakdownImplCopyWithImpl<$Res>
    extends _$SubjectBreakdownCopyWithImpl<$Res, _$SubjectBreakdownImpl>
    implements _$$SubjectBreakdownImplCopyWith<$Res> {
  __$$SubjectBreakdownImplCopyWithImpl(
    _$SubjectBreakdownImpl _value,
    $Res Function(_$SubjectBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubjectBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? subjectName = null, Object? studyMinutes = null}) {
    return _then(
      _$SubjectBreakdownImpl(
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectBreakdownImpl extends _SubjectBreakdown {
  const _$SubjectBreakdownImpl({
    required this.subjectName,
    this.studyMinutes = 0,
  }) : super._();

  factory _$SubjectBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectBreakdownImplFromJson(json);

  @override
  final String subjectName;
  @override
  @JsonKey()
  final int studyMinutes;

  @override
  String toString() {
    return 'SubjectBreakdown(subjectName: $subjectName, studyMinutes: $studyMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectBreakdownImpl &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subjectName, studyMinutes);

  /// Create a copy of SubjectBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectBreakdownImplCopyWith<_$SubjectBreakdownImpl> get copyWith =>
      __$$SubjectBreakdownImplCopyWithImpl<_$SubjectBreakdownImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectBreakdownImplToJson(this);
  }
}

abstract class _SubjectBreakdown extends SubjectBreakdown {
  const factory _SubjectBreakdown({
    required final String subjectName,
    final int studyMinutes,
  }) = _$SubjectBreakdownImpl;
  const _SubjectBreakdown._() : super._();

  factory _SubjectBreakdown.fromJson(Map<String, dynamic> json) =
      _$SubjectBreakdownImpl.fromJson;

  @override
  String get subjectName;
  @override
  int get studyMinutes;

  /// Create a copy of SubjectBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectBreakdownImplCopyWith<_$SubjectBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
