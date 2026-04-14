// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_home.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentHome _$StudentHomeFromJson(Map<String, dynamic> json) {
  return _StudentHome.fromJson(json);
}

/// @nodoc
mixin _$StudentHome {
  TodayAttendanceSummary? get todayAttendance =>
      throw _privateConstructorUsedError;
  SeatSummary? get seat => throw _privateConstructorUsedError;
  StudySummary? get study => throw _privateConstructorUsedError;
  PlanSummary? get plans => throw _privateConstructorUsedError;
  List<NotificationSummary> get notifications =>
      throw _privateConstructorUsedError;

  /// Serializes this StudentHome to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentHomeCopyWith<StudentHome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentHomeCopyWith<$Res> {
  factory $StudentHomeCopyWith(
    StudentHome value,
    $Res Function(StudentHome) then,
  ) = _$StudentHomeCopyWithImpl<$Res, StudentHome>;
  @useResult
  $Res call({
    TodayAttendanceSummary? todayAttendance,
    SeatSummary? seat,
    StudySummary? study,
    PlanSummary? plans,
    List<NotificationSummary> notifications,
  });

  $TodayAttendanceSummaryCopyWith<$Res>? get todayAttendance;
  $SeatSummaryCopyWith<$Res>? get seat;
  $StudySummaryCopyWith<$Res>? get study;
  $PlanSummaryCopyWith<$Res>? get plans;
}

/// @nodoc
class _$StudentHomeCopyWithImpl<$Res, $Val extends StudentHome>
    implements $StudentHomeCopyWith<$Res> {
  _$StudentHomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayAttendance = freezed,
    Object? seat = freezed,
    Object? study = freezed,
    Object? plans = freezed,
    Object? notifications = null,
  }) {
    return _then(
      _value.copyWith(
            todayAttendance: freezed == todayAttendance
                ? _value.todayAttendance
                : todayAttendance // ignore: cast_nullable_to_non_nullable
                      as TodayAttendanceSummary?,
            seat: freezed == seat
                ? _value.seat
                : seat // ignore: cast_nullable_to_non_nullable
                      as SeatSummary?,
            study: freezed == study
                ? _value.study
                : study // ignore: cast_nullable_to_non_nullable
                      as StudySummary?,
            plans: freezed == plans
                ? _value.plans
                : plans // ignore: cast_nullable_to_non_nullable
                      as PlanSummary?,
            notifications: null == notifications
                ? _value.notifications
                : notifications // ignore: cast_nullable_to_non_nullable
                      as List<NotificationSummary>,
          )
          as $Val,
    );
  }

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodayAttendanceSummaryCopyWith<$Res>? get todayAttendance {
    if (_value.todayAttendance == null) {
      return null;
    }

    return $TodayAttendanceSummaryCopyWith<$Res>(_value.todayAttendance!, (
      value,
    ) {
      return _then(_value.copyWith(todayAttendance: value) as $Val);
    });
  }

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeatSummaryCopyWith<$Res>? get seat {
    if (_value.seat == null) {
      return null;
    }

    return $SeatSummaryCopyWith<$Res>(_value.seat!, (value) {
      return _then(_value.copyWith(seat: value) as $Val);
    });
  }

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudySummaryCopyWith<$Res>? get study {
    if (_value.study == null) {
      return null;
    }

    return $StudySummaryCopyWith<$Res>(_value.study!, (value) {
      return _then(_value.copyWith(study: value) as $Val);
    });
  }

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlanSummaryCopyWith<$Res>? get plans {
    if (_value.plans == null) {
      return null;
    }

    return $PlanSummaryCopyWith<$Res>(_value.plans!, (value) {
      return _then(_value.copyWith(plans: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudentHomeImplCopyWith<$Res>
    implements $StudentHomeCopyWith<$Res> {
  factory _$$StudentHomeImplCopyWith(
    _$StudentHomeImpl value,
    $Res Function(_$StudentHomeImpl) then,
  ) = __$$StudentHomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TodayAttendanceSummary? todayAttendance,
    SeatSummary? seat,
    StudySummary? study,
    PlanSummary? plans,
    List<NotificationSummary> notifications,
  });

  @override
  $TodayAttendanceSummaryCopyWith<$Res>? get todayAttendance;
  @override
  $SeatSummaryCopyWith<$Res>? get seat;
  @override
  $StudySummaryCopyWith<$Res>? get study;
  @override
  $PlanSummaryCopyWith<$Res>? get plans;
}

/// @nodoc
class __$$StudentHomeImplCopyWithImpl<$Res>
    extends _$StudentHomeCopyWithImpl<$Res, _$StudentHomeImpl>
    implements _$$StudentHomeImplCopyWith<$Res> {
  __$$StudentHomeImplCopyWithImpl(
    _$StudentHomeImpl _value,
    $Res Function(_$StudentHomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayAttendance = freezed,
    Object? seat = freezed,
    Object? study = freezed,
    Object? plans = freezed,
    Object? notifications = null,
  }) {
    return _then(
      _$StudentHomeImpl(
        todayAttendance: freezed == todayAttendance
            ? _value.todayAttendance
            : todayAttendance // ignore: cast_nullable_to_non_nullable
                  as TodayAttendanceSummary?,
        seat: freezed == seat
            ? _value.seat
            : seat // ignore: cast_nullable_to_non_nullable
                  as SeatSummary?,
        study: freezed == study
            ? _value.study
            : study // ignore: cast_nullable_to_non_nullable
                  as StudySummary?,
        plans: freezed == plans
            ? _value.plans
            : plans // ignore: cast_nullable_to_non_nullable
                  as PlanSummary?,
        notifications: null == notifications
            ? _value._notifications
            : notifications // ignore: cast_nullable_to_non_nullable
                  as List<NotificationSummary>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentHomeImpl extends _StudentHome {
  const _$StudentHomeImpl({
    required this.todayAttendance,
    required this.seat,
    required this.study,
    required this.plans,
    final List<NotificationSummary> notifications = const [],
  }) : _notifications = notifications,
       super._();

  factory _$StudentHomeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentHomeImplFromJson(json);

  @override
  final TodayAttendanceSummary? todayAttendance;
  @override
  final SeatSummary? seat;
  @override
  final StudySummary? study;
  @override
  final PlanSummary? plans;
  final List<NotificationSummary> _notifications;
  @override
  @JsonKey()
  List<NotificationSummary> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  String toString() {
    return 'StudentHome(todayAttendance: $todayAttendance, seat: $seat, study: $study, plans: $plans, notifications: $notifications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentHomeImpl &&
            (identical(other.todayAttendance, todayAttendance) ||
                other.todayAttendance == todayAttendance) &&
            (identical(other.seat, seat) || other.seat == seat) &&
            (identical(other.study, study) || other.study == study) &&
            (identical(other.plans, plans) || other.plans == plans) &&
            const DeepCollectionEquality().equals(
              other._notifications,
              _notifications,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    todayAttendance,
    seat,
    study,
    plans,
    const DeepCollectionEquality().hash(_notifications),
  );

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentHomeImplCopyWith<_$StudentHomeImpl> get copyWith =>
      __$$StudentHomeImplCopyWithImpl<_$StudentHomeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentHomeImplToJson(this);
  }
}

abstract class _StudentHome extends StudentHome {
  const factory _StudentHome({
    required final TodayAttendanceSummary? todayAttendance,
    required final SeatSummary? seat,
    required final StudySummary? study,
    required final PlanSummary? plans,
    final List<NotificationSummary> notifications,
  }) = _$StudentHomeImpl;
  const _StudentHome._() : super._();

  factory _StudentHome.fromJson(Map<String, dynamic> json) =
      _$StudentHomeImpl.fromJson;

  @override
  TodayAttendanceSummary? get todayAttendance;
  @override
  SeatSummary? get seat;
  @override
  StudySummary? get study;
  @override
  PlanSummary? get plans;
  @override
  List<NotificationSummary> get notifications;

  /// Create a copy of StudentHome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentHomeImplCopyWith<_$StudentHomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TodayAttendanceSummary _$TodayAttendanceSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _TodayAttendanceSummary.fromJson(json);
}

/// @nodoc
mixin _$TodayAttendanceSummary {
  String get status => throw _privateConstructorUsedError;
  String? get checkInAt => throw _privateConstructorUsedError;
  String? get checkOutAt => throw _privateConstructorUsedError;
  int get stayMinutes => throw _privateConstructorUsedError;

  /// Serializes this TodayAttendanceSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodayAttendanceSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodayAttendanceSummaryCopyWith<TodayAttendanceSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodayAttendanceSummaryCopyWith<$Res> {
  factory $TodayAttendanceSummaryCopyWith(
    TodayAttendanceSummary value,
    $Res Function(TodayAttendanceSummary) then,
  ) = _$TodayAttendanceSummaryCopyWithImpl<$Res, TodayAttendanceSummary>;
  @useResult
  $Res call({
    String status,
    String? checkInAt,
    String? checkOutAt,
    int stayMinutes,
  });
}

/// @nodoc
class _$TodayAttendanceSummaryCopyWithImpl<
  $Res,
  $Val extends TodayAttendanceSummary
>
    implements $TodayAttendanceSummaryCopyWith<$Res> {
  _$TodayAttendanceSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodayAttendanceSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? stayMinutes = null,
  }) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodayAttendanceSummaryImplCopyWith<$Res>
    implements $TodayAttendanceSummaryCopyWith<$Res> {
  factory _$$TodayAttendanceSummaryImplCopyWith(
    _$TodayAttendanceSummaryImpl value,
    $Res Function(_$TodayAttendanceSummaryImpl) then,
  ) = __$$TodayAttendanceSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String status,
    String? checkInAt,
    String? checkOutAt,
    int stayMinutes,
  });
}

/// @nodoc
class __$$TodayAttendanceSummaryImplCopyWithImpl<$Res>
    extends
        _$TodayAttendanceSummaryCopyWithImpl<$Res, _$TodayAttendanceSummaryImpl>
    implements _$$TodayAttendanceSummaryImplCopyWith<$Res> {
  __$$TodayAttendanceSummaryImplCopyWithImpl(
    _$TodayAttendanceSummaryImpl _value,
    $Res Function(_$TodayAttendanceSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodayAttendanceSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? stayMinutes = null,
  }) {
    return _then(
      _$TodayAttendanceSummaryImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TodayAttendanceSummaryImpl extends _TodayAttendanceSummary {
  const _$TodayAttendanceSummaryImpl({
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    this.stayMinutes = 0,
  }) : super._();

  factory _$TodayAttendanceSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodayAttendanceSummaryImplFromJson(json);

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
  String toString() {
    return 'TodayAttendanceSummary(status: $status, checkInAt: $checkInAt, checkOutAt: $checkOutAt, stayMinutes: $stayMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodayAttendanceSummaryImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.checkInAt, checkInAt) ||
                other.checkInAt == checkInAt) &&
            (identical(other.checkOutAt, checkOutAt) ||
                other.checkOutAt == checkOutAt) &&
            (identical(other.stayMinutes, stayMinutes) ||
                other.stayMinutes == stayMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, status, checkInAt, checkOutAt, stayMinutes);

  /// Create a copy of TodayAttendanceSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodayAttendanceSummaryImplCopyWith<_$TodayAttendanceSummaryImpl>
  get copyWith =>
      __$$TodayAttendanceSummaryImplCopyWithImpl<_$TodayAttendanceSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TodayAttendanceSummaryImplToJson(this);
  }
}

abstract class _TodayAttendanceSummary extends TodayAttendanceSummary {
  const factory _TodayAttendanceSummary({
    required final String status,
    final String? checkInAt,
    final String? checkOutAt,
    final int stayMinutes,
  }) = _$TodayAttendanceSummaryImpl;
  const _TodayAttendanceSummary._() : super._();

  factory _TodayAttendanceSummary.fromJson(Map<String, dynamic> json) =
      _$TodayAttendanceSummaryImpl.fromJson;

  @override
  String get status;
  @override
  String? get checkInAt;
  @override
  String? get checkOutAt;
  @override
  int get stayMinutes;

  /// Create a copy of TodayAttendanceSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodayAttendanceSummaryImplCopyWith<_$TodayAttendanceSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SeatSummary _$SeatSummaryFromJson(Map<String, dynamic> json) {
  return _SeatSummary.fromJson(json);
}

/// @nodoc
mixin _$SeatSummary {
  String get seatId => throw _privateConstructorUsedError;
  String get seatNo => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this SeatSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeatSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeatSummaryCopyWith<SeatSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeatSummaryCopyWith<$Res> {
  factory $SeatSummaryCopyWith(
    SeatSummary value,
    $Res Function(SeatSummary) then,
  ) = _$SeatSummaryCopyWithImpl<$Res, SeatSummary>;
  @useResult
  $Res call({String seatId, String seatNo, String status});
}

/// @nodoc
class _$SeatSummaryCopyWithImpl<$Res, $Val extends SeatSummary>
    implements $SeatSummaryCopyWith<$Res> {
  _$SeatSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeatSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seatId = null,
    Object? seatNo = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            seatId: null == seatId
                ? _value.seatId
                : seatId // ignore: cast_nullable_to_non_nullable
                      as String,
            seatNo: null == seatNo
                ? _value.seatNo
                : seatNo // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SeatSummaryImplCopyWith<$Res>
    implements $SeatSummaryCopyWith<$Res> {
  factory _$$SeatSummaryImplCopyWith(
    _$SeatSummaryImpl value,
    $Res Function(_$SeatSummaryImpl) then,
  ) = __$$SeatSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String seatId, String seatNo, String status});
}

/// @nodoc
class __$$SeatSummaryImplCopyWithImpl<$Res>
    extends _$SeatSummaryCopyWithImpl<$Res, _$SeatSummaryImpl>
    implements _$$SeatSummaryImplCopyWith<$Res> {
  __$$SeatSummaryImplCopyWithImpl(
    _$SeatSummaryImpl _value,
    $Res Function(_$SeatSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SeatSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seatId = null,
    Object? seatNo = null,
    Object? status = null,
  }) {
    return _then(
      _$SeatSummaryImpl(
        seatId: null == seatId
            ? _value.seatId
            : seatId // ignore: cast_nullable_to_non_nullable
                  as String,
        seatNo: null == seatNo
            ? _value.seatNo
            : seatNo // ignore: cast_nullable_to_non_nullable
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
class _$SeatSummaryImpl extends _SeatSummary {
  const _$SeatSummaryImpl({
    required this.seatId,
    required this.seatNo,
    required this.status,
  }) : super._();

  factory _$SeatSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeatSummaryImplFromJson(json);

  @override
  final String seatId;
  @override
  final String seatNo;
  @override
  final String status;

  @override
  String toString() {
    return 'SeatSummary(seatId: $seatId, seatNo: $seatNo, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeatSummaryImpl &&
            (identical(other.seatId, seatId) || other.seatId == seatId) &&
            (identical(other.seatNo, seatNo) || other.seatNo == seatNo) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, seatId, seatNo, status);

  /// Create a copy of SeatSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeatSummaryImplCopyWith<_$SeatSummaryImpl> get copyWith =>
      __$$SeatSummaryImplCopyWithImpl<_$SeatSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeatSummaryImplToJson(this);
  }
}

abstract class _SeatSummary extends SeatSummary {
  const factory _SeatSummary({
    required final String seatId,
    required final String seatNo,
    required final String status,
  }) = _$SeatSummaryImpl;
  const _SeatSummary._() : super._();

  factory _SeatSummary.fromJson(Map<String, dynamic> json) =
      _$SeatSummaryImpl.fromJson;

  @override
  String get seatId;
  @override
  String get seatNo;
  @override
  String get status;

  /// Create a copy of SeatSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeatSummaryImplCopyWith<_$SeatSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudySummary _$StudySummaryFromJson(Map<String, dynamic> json) {
  return _StudySummary.fromJson(json);
}

/// @nodoc
mixin _$StudySummary {
  String get sessionStatus => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;
  int get breakMinutes => throw _privateConstructorUsedError;

  /// Serializes this StudySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudySummaryCopyWith<StudySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudySummaryCopyWith<$Res> {
  factory $StudySummaryCopyWith(
    StudySummary value,
    $Res Function(StudySummary) then,
  ) = _$StudySummaryCopyWithImpl<$Res, StudySummary>;
  @useResult
  $Res call({String sessionStatus, int studyMinutes, int breakMinutes});
}

/// @nodoc
class _$StudySummaryCopyWithImpl<$Res, $Val extends StudySummary>
    implements $StudySummaryCopyWith<$Res> {
  _$StudySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionStatus = null,
    Object? studyMinutes = null,
    Object? breakMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            sessionStatus: null == sessionStatus
                ? _value.sessionStatus
                : sessionStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            breakMinutes: null == breakMinutes
                ? _value.breakMinutes
                : breakMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudySummaryImplCopyWith<$Res>
    implements $StudySummaryCopyWith<$Res> {
  factory _$$StudySummaryImplCopyWith(
    _$StudySummaryImpl value,
    $Res Function(_$StudySummaryImpl) then,
  ) = __$$StudySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionStatus, int studyMinutes, int breakMinutes});
}

/// @nodoc
class __$$StudySummaryImplCopyWithImpl<$Res>
    extends _$StudySummaryCopyWithImpl<$Res, _$StudySummaryImpl>
    implements _$$StudySummaryImplCopyWith<$Res> {
  __$$StudySummaryImplCopyWithImpl(
    _$StudySummaryImpl _value,
    $Res Function(_$StudySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionStatus = null,
    Object? studyMinutes = null,
    Object? breakMinutes = null,
  }) {
    return _then(
      _$StudySummaryImpl(
        sessionStatus: null == sessionStatus
            ? _value.sessionStatus
            : sessionStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        breakMinutes: null == breakMinutes
            ? _value.breakMinutes
            : breakMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudySummaryImpl extends _StudySummary {
  const _$StudySummaryImpl({
    required this.sessionStatus,
    this.studyMinutes = 0,
    this.breakMinutes = 0,
  }) : super._();

  factory _$StudySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudySummaryImplFromJson(json);

  @override
  final String sessionStatus;
  @override
  @JsonKey()
  final int studyMinutes;
  @override
  @JsonKey()
  final int breakMinutes;

  @override
  String toString() {
    return 'StudySummary(sessionStatus: $sessionStatus, studyMinutes: $studyMinutes, breakMinutes: $breakMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudySummaryImpl &&
            (identical(other.sessionStatus, sessionStatus) ||
                other.sessionStatus == sessionStatus) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes) &&
            (identical(other.breakMinutes, breakMinutes) ||
                other.breakMinutes == breakMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionStatus, studyMinutes, breakMinutes);

  /// Create a copy of StudySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudySummaryImplCopyWith<_$StudySummaryImpl> get copyWith =>
      __$$StudySummaryImplCopyWithImpl<_$StudySummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudySummaryImplToJson(this);
  }
}

abstract class _StudySummary extends StudySummary {
  const factory _StudySummary({
    required final String sessionStatus,
    final int studyMinutes,
    final int breakMinutes,
  }) = _$StudySummaryImpl;
  const _StudySummary._() : super._();

  factory _StudySummary.fromJson(Map<String, dynamic> json) =
      _$StudySummaryImpl.fromJson;

  @override
  String get sessionStatus;
  @override
  int get studyMinutes;
  @override
  int get breakMinutes;

  /// Create a copy of StudySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudySummaryImplCopyWith<_$StudySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanSummary _$PlanSummaryFromJson(Map<String, dynamic> json) {
  return _PlanSummary.fromJson(json);
}

/// @nodoc
mixin _$PlanSummary {
  int get totalCount => throw _privateConstructorUsedError;
  int get completedCount => throw _privateConstructorUsedError;
  int get targetMinutes => throw _privateConstructorUsedError;

  /// Serializes this PlanSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanSummaryCopyWith<PlanSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanSummaryCopyWith<$Res> {
  factory $PlanSummaryCopyWith(
    PlanSummary value,
    $Res Function(PlanSummary) then,
  ) = _$PlanSummaryCopyWithImpl<$Res, PlanSummary>;
  @useResult
  $Res call({int totalCount, int completedCount, int targetMinutes});
}

/// @nodoc
class _$PlanSummaryCopyWithImpl<$Res, $Val extends PlanSummary>
    implements $PlanSummaryCopyWith<$Res> {
  _$PlanSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? completedCount = null,
    Object? targetMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            completedCount: null == completedCount
                ? _value.completedCount
                : completedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            targetMinutes: null == targetMinutes
                ? _value.targetMinutes
                : targetMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanSummaryImplCopyWith<$Res>
    implements $PlanSummaryCopyWith<$Res> {
  factory _$$PlanSummaryImplCopyWith(
    _$PlanSummaryImpl value,
    $Res Function(_$PlanSummaryImpl) then,
  ) = __$$PlanSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalCount, int completedCount, int targetMinutes});
}

/// @nodoc
class __$$PlanSummaryImplCopyWithImpl<$Res>
    extends _$PlanSummaryCopyWithImpl<$Res, _$PlanSummaryImpl>
    implements _$$PlanSummaryImplCopyWith<$Res> {
  __$$PlanSummaryImplCopyWithImpl(
    _$PlanSummaryImpl _value,
    $Res Function(_$PlanSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? completedCount = null,
    Object? targetMinutes = null,
  }) {
    return _then(
      _$PlanSummaryImpl(
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        completedCount: null == completedCount
            ? _value.completedCount
            : completedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        targetMinutes: null == targetMinutes
            ? _value.targetMinutes
            : targetMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanSummaryImpl extends _PlanSummary {
  const _$PlanSummaryImpl({
    this.totalCount = 0,
    this.completedCount = 0,
    this.targetMinutes = 0,
  }) : super._();

  factory _$PlanSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanSummaryImplFromJson(json);

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int completedCount;
  @override
  @JsonKey()
  final int targetMinutes;

  @override
  String toString() {
    return 'PlanSummary(totalCount: $totalCount, completedCount: $completedCount, targetMinutes: $targetMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanSummaryImpl &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.targetMinutes, targetMinutes) ||
                other.targetMinutes == targetMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalCount, completedCount, targetMinutes);

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanSummaryImplCopyWith<_$PlanSummaryImpl> get copyWith =>
      __$$PlanSummaryImplCopyWithImpl<_$PlanSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanSummaryImplToJson(this);
  }
}

abstract class _PlanSummary extends PlanSummary {
  const factory _PlanSummary({
    final int totalCount,
    final int completedCount,
    final int targetMinutes,
  }) = _$PlanSummaryImpl;
  const _PlanSummary._() : super._();

  factory _PlanSummary.fromJson(Map<String, dynamic> json) =
      _$PlanSummaryImpl.fromJson;

  @override
  int get totalCount;
  @override
  int get completedCount;
  @override
  int get targetMinutes;

  /// Create a copy of PlanSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanSummaryImplCopyWith<_$PlanSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSummary _$NotificationSummaryFromJson(Map<String, dynamic> json) {
  return _NotificationSummary.fromJson(json);
}

/// @nodoc
mixin _$NotificationSummary {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this NotificationSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSummaryCopyWith<NotificationSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSummaryCopyWith<$Res> {
  factory $NotificationSummaryCopyWith(
    NotificationSummary value,
    $Res Function(NotificationSummary) then,
  ) = _$NotificationSummaryCopyWithImpl<$Res, NotificationSummary>;
  @useResult
  $Res call({String id, String title});
}

/// @nodoc
class _$NotificationSummaryCopyWithImpl<$Res, $Val extends NotificationSummary>
    implements $NotificationSummaryCopyWith<$Res> {
  _$NotificationSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationSummaryImplCopyWith<$Res>
    implements $NotificationSummaryCopyWith<$Res> {
  factory _$$NotificationSummaryImplCopyWith(
    _$NotificationSummaryImpl value,
    $Res Function(_$NotificationSummaryImpl) then,
  ) = __$$NotificationSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title});
}

/// @nodoc
class __$$NotificationSummaryImplCopyWithImpl<$Res>
    extends _$NotificationSummaryCopyWithImpl<$Res, _$NotificationSummaryImpl>
    implements _$$NotificationSummaryImplCopyWith<$Res> {
  __$$NotificationSummaryImplCopyWithImpl(
    _$NotificationSummaryImpl _value,
    $Res Function(_$NotificationSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _$NotificationSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSummaryImpl extends _NotificationSummary {
  const _$NotificationSummaryImpl({required this.id, required this.title})
    : super._();

  factory _$NotificationSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String title;

  @override
  String toString() {
    return 'NotificationSummary(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of NotificationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSummaryImplCopyWith<_$NotificationSummaryImpl> get copyWith =>
      __$$NotificationSummaryImplCopyWithImpl<_$NotificationSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSummaryImplToJson(this);
  }
}

abstract class _NotificationSummary extends NotificationSummary {
  const factory _NotificationSummary({
    required final String id,
    required final String title,
  }) = _$NotificationSummaryImpl;
  const _NotificationSummary._() : super._();

  factory _NotificationSummary.fromJson(Map<String, dynamic> json) =
      _$NotificationSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get title;

  /// Create a copy of NotificationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSummaryImplCopyWith<_$NotificationSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
