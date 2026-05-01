// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentLoginRequest _$StudentLoginRequestFromJson(Map<String, dynamic> json) {
  return _StudentLoginRequest.fromJson(json);
}

/// @nodoc
mixin _$StudentLoginRequest {
  String get loginId => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String? get deviceCode => throw _privateConstructorUsedError;

  /// Serializes this StudentLoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentLoginRequestCopyWith<StudentLoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentLoginRequestCopyWith<$Res> {
  factory $StudentLoginRequestCopyWith(
    StudentLoginRequest value,
    $Res Function(StudentLoginRequest) then,
  ) = _$StudentLoginRequestCopyWithImpl<$Res, StudentLoginRequest>;
  @useResult
  $Res call({String loginId, String password, String? deviceCode});
}

/// @nodoc
class _$StudentLoginRequestCopyWithImpl<$Res, $Val extends StudentLoginRequest>
    implements $StudentLoginRequestCopyWith<$Res> {
  _$StudentLoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginId = null,
    Object? password = null,
    Object? deviceCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            loginId: null == loginId
                ? _value.loginId
                : loginId // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceCode: freezed == deviceCode
                ? _value.deviceCode
                : deviceCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentLoginRequestImplCopyWith<$Res>
    implements $StudentLoginRequestCopyWith<$Res> {
  factory _$$StudentLoginRequestImplCopyWith(
    _$StudentLoginRequestImpl value,
    $Res Function(_$StudentLoginRequestImpl) then,
  ) = __$$StudentLoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String loginId, String password, String? deviceCode});
}

/// @nodoc
class __$$StudentLoginRequestImplCopyWithImpl<$Res>
    extends _$StudentLoginRequestCopyWithImpl<$Res, _$StudentLoginRequestImpl>
    implements _$$StudentLoginRequestImplCopyWith<$Res> {
  __$$StudentLoginRequestImplCopyWithImpl(
    _$StudentLoginRequestImpl _value,
    $Res Function(_$StudentLoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginId = null,
    Object? password = null,
    Object? deviceCode = freezed,
  }) {
    return _then(
      _$StudentLoginRequestImpl(
        loginId: null == loginId
            ? _value.loginId
            : loginId // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceCode: freezed == deviceCode
            ? _value.deviceCode
            : deviceCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentLoginRequestImpl extends _StudentLoginRequest {
  const _$StudentLoginRequestImpl({
    required this.loginId,
    required this.password,
    this.deviceCode,
  }) : super._();

  factory _$StudentLoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentLoginRequestImplFromJson(json);

  @override
  final String loginId;
  @override
  final String password;
  @override
  final String? deviceCode;

  @override
  String toString() {
    return 'StudentLoginRequest(loginId: $loginId, password: $password, deviceCode: $deviceCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentLoginRequestImpl &&
            (identical(other.loginId, loginId) || other.loginId == loginId) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.deviceCode, deviceCode) ||
                other.deviceCode == deviceCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, loginId, password, deviceCode);

  /// Create a copy of StudentLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentLoginRequestImplCopyWith<_$StudentLoginRequestImpl> get copyWith =>
      __$$StudentLoginRequestImplCopyWithImpl<_$StudentLoginRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentLoginRequestImplToJson(this);
  }
}

abstract class _StudentLoginRequest extends StudentLoginRequest {
  const factory _StudentLoginRequest({
    required final String loginId,
    required final String password,
    final String? deviceCode,
  }) = _$StudentLoginRequestImpl;
  const _StudentLoginRequest._() : super._();

  factory _StudentLoginRequest.fromJson(Map<String, dynamic> json) =
      _$StudentLoginRequestImpl.fromJson;

  @override
  String get loginId;
  @override
  String get password;
  @override
  String? get deviceCode;

  /// Create a copy of StudentLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentLoginRequestImplCopyWith<_$StudentLoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentSignupRequest _$StudentSignupRequestFromJson(Map<String, dynamic> json) {
  return _StudentSignupRequest.fromJson(json);
}

/// @nodoc
mixin _$StudentSignupRequest {
  String get loginId => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get studentNo => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get deviceCode => throw _privateConstructorUsedError;

  /// Serializes this StudentSignupRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentSignupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentSignupRequestCopyWith<StudentSignupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentSignupRequestCopyWith<$Res> {
  factory $StudentSignupRequestCopyWith(
    StudentSignupRequest value,
    $Res Function(StudentSignupRequest) then,
  ) = _$StudentSignupRequestCopyWithImpl<$Res, StudentSignupRequest>;
  @useResult
  $Res call({
    String loginId,
    String password,
    String studentNo,
    String name,
    String? phone,
    String? deviceCode,
  });
}

/// @nodoc
class _$StudentSignupRequestCopyWithImpl<
  $Res,
  $Val extends StudentSignupRequest
>
    implements $StudentSignupRequestCopyWith<$Res> {
  _$StudentSignupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentSignupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginId = null,
    Object? password = null,
    Object? studentNo = null,
    Object? name = null,
    Object? phone = freezed,
    Object? deviceCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            loginId: null == loginId
                ? _value.loginId
                : loginId // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            studentNo: null == studentNo
                ? _value.studentNo
                : studentNo // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceCode: freezed == deviceCode
                ? _value.deviceCode
                : deviceCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentSignupRequestImplCopyWith<$Res>
    implements $StudentSignupRequestCopyWith<$Res> {
  factory _$$StudentSignupRequestImplCopyWith(
    _$StudentSignupRequestImpl value,
    $Res Function(_$StudentSignupRequestImpl) then,
  ) = __$$StudentSignupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String loginId,
    String password,
    String studentNo,
    String name,
    String? phone,
    String? deviceCode,
  });
}

/// @nodoc
class __$$StudentSignupRequestImplCopyWithImpl<$Res>
    extends _$StudentSignupRequestCopyWithImpl<$Res, _$StudentSignupRequestImpl>
    implements _$$StudentSignupRequestImplCopyWith<$Res> {
  __$$StudentSignupRequestImplCopyWithImpl(
    _$StudentSignupRequestImpl _value,
    $Res Function(_$StudentSignupRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentSignupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginId = null,
    Object? password = null,
    Object? studentNo = null,
    Object? name = null,
    Object? phone = freezed,
    Object? deviceCode = freezed,
  }) {
    return _then(
      _$StudentSignupRequestImpl(
        loginId: null == loginId
            ? _value.loginId
            : loginId // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        studentNo: null == studentNo
            ? _value.studentNo
            : studentNo // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceCode: freezed == deviceCode
            ? _value.deviceCode
            : deviceCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentSignupRequestImpl extends _StudentSignupRequest {
  const _$StudentSignupRequestImpl({
    required this.loginId,
    required this.password,
    required this.studentNo,
    required this.name,
    this.phone,
    this.deviceCode,
  }) : super._();

  factory _$StudentSignupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentSignupRequestImplFromJson(json);

  @override
  final String loginId;
  @override
  final String password;
  @override
  final String studentNo;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? deviceCode;

  @override
  String toString() {
    return 'StudentSignupRequest(loginId: $loginId, password: $password, studentNo: $studentNo, name: $name, phone: $phone, deviceCode: $deviceCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentSignupRequestImpl &&
            (identical(other.loginId, loginId) || other.loginId == loginId) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.studentNo, studentNo) ||
                other.studentNo == studentNo) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.deviceCode, deviceCode) ||
                other.deviceCode == deviceCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    loginId,
    password,
    studentNo,
    name,
    phone,
    deviceCode,
  );

  /// Create a copy of StudentSignupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentSignupRequestImplCopyWith<_$StudentSignupRequestImpl>
  get copyWith =>
      __$$StudentSignupRequestImplCopyWithImpl<_$StudentSignupRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentSignupRequestImplToJson(this);
  }
}

abstract class _StudentSignupRequest extends StudentSignupRequest {
  const factory _StudentSignupRequest({
    required final String loginId,
    required final String password,
    required final String studentNo,
    required final String name,
    final String? phone,
    final String? deviceCode,
  }) = _$StudentSignupRequestImpl;
  const _StudentSignupRequest._() : super._();

  factory _StudentSignupRequest.fromJson(Map<String, dynamic> json) =
      _$StudentSignupRequestImpl.fromJson;

  @override
  String get loginId;
  @override
  String get password;
  @override
  String get studentNo;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get deviceCode;

  /// Create a copy of StudentSignupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentSignupRequestImplCopyWith<_$StudentSignupRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AdminLoginRequest _$AdminLoginRequestFromJson(Map<String, dynamic> json) {
  return _AdminLoginRequest.fromJson(json);
}

/// @nodoc
mixin _$AdminLoginRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this AdminLoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminLoginRequestCopyWith<AdminLoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminLoginRequestCopyWith<$Res> {
  factory $AdminLoginRequestCopyWith(
    AdminLoginRequest value,
    $Res Function(AdminLoginRequest) then,
  ) = _$AdminLoginRequestCopyWithImpl<$Res, AdminLoginRequest>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$AdminLoginRequestCopyWithImpl<$Res, $Val extends AdminLoginRequest>
    implements $AdminLoginRequestCopyWith<$Res> {
  _$AdminLoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminLoginRequestImplCopyWith<$Res>
    implements $AdminLoginRequestCopyWith<$Res> {
  factory _$$AdminLoginRequestImplCopyWith(
    _$AdminLoginRequestImpl value,
    $Res Function(_$AdminLoginRequestImpl) then,
  ) = __$$AdminLoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$AdminLoginRequestImplCopyWithImpl<$Res>
    extends _$AdminLoginRequestCopyWithImpl<$Res, _$AdminLoginRequestImpl>
    implements _$$AdminLoginRequestImplCopyWith<$Res> {
  __$$AdminLoginRequestImplCopyWithImpl(
    _$AdminLoginRequestImpl _value,
    $Res Function(_$AdminLoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _$AdminLoginRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminLoginRequestImpl extends _AdminLoginRequest {
  const _$AdminLoginRequestImpl({required this.email, required this.password})
    : super._();

  factory _$AdminLoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminLoginRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'AdminLoginRequest(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminLoginRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of AdminLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminLoginRequestImplCopyWith<_$AdminLoginRequestImpl> get copyWith =>
      __$$AdminLoginRequestImplCopyWithImpl<_$AdminLoginRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminLoginRequestImplToJson(this);
  }
}

abstract class _AdminLoginRequest extends AdminLoginRequest {
  const factory _AdminLoginRequest({
    required final String email,
    required final String password,
  }) = _$AdminLoginRequestImpl;
  const _AdminLoginRequest._() : super._();

  factory _AdminLoginRequest.fromJson(Map<String, dynamic> json) =
      _$AdminLoginRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;

  /// Create a copy of AdminLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminLoginRequestImplCopyWith<_$AdminLoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentLoginResponse _$StudentLoginResponseFromJson(Map<String, dynamic> json) {
  return _StudentLoginResponse.fromJson(json);
}

/// @nodoc
mixin _$StudentLoginResponse {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  UserSummaryData get user => throw _privateConstructorUsedError;
  StudentSummaryData get student => throw _privateConstructorUsedError;

  /// Serializes this StudentLoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentLoginResponseCopyWith<StudentLoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentLoginResponseCopyWith<$Res> {
  factory $StudentLoginResponseCopyWith(
    StudentLoginResponse value,
    $Res Function(StudentLoginResponse) then,
  ) = _$StudentLoginResponseCopyWithImpl<$Res, StudentLoginResponse>;
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    String sessionId,
    UserSummaryData user,
    StudentSummaryData student,
  });

  $UserSummaryDataCopyWith<$Res> get user;
  $StudentSummaryDataCopyWith<$Res> get student;
}

/// @nodoc
class _$StudentLoginResponseCopyWithImpl<
  $Res,
  $Val extends StudentLoginResponse
>
    implements $StudentLoginResponseCopyWith<$Res> {
  _$StudentLoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? sessionId = null,
    Object? user = null,
    Object? student = null,
  }) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserSummaryData,
            student: null == student
                ? _value.student
                : student // ignore: cast_nullable_to_non_nullable
                      as StudentSummaryData,
          )
          as $Val,
    );
  }

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryDataCopyWith<$Res> get user {
    return $UserSummaryDataCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudentSummaryDataCopyWith<$Res> get student {
    return $StudentSummaryDataCopyWith<$Res>(_value.student, (value) {
      return _then(_value.copyWith(student: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudentLoginResponseImplCopyWith<$Res>
    implements $StudentLoginResponseCopyWith<$Res> {
  factory _$$StudentLoginResponseImplCopyWith(
    _$StudentLoginResponseImpl value,
    $Res Function(_$StudentLoginResponseImpl) then,
  ) = __$$StudentLoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    String sessionId,
    UserSummaryData user,
    StudentSummaryData student,
  });

  @override
  $UserSummaryDataCopyWith<$Res> get user;
  @override
  $StudentSummaryDataCopyWith<$Res> get student;
}

/// @nodoc
class __$$StudentLoginResponseImplCopyWithImpl<$Res>
    extends _$StudentLoginResponseCopyWithImpl<$Res, _$StudentLoginResponseImpl>
    implements _$$StudentLoginResponseImplCopyWith<$Res> {
  __$$StudentLoginResponseImplCopyWithImpl(
    _$StudentLoginResponseImpl _value,
    $Res Function(_$StudentLoginResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? sessionId = null,
    Object? user = null,
    Object? student = null,
  }) {
    return _then(
      _$StudentLoginResponseImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserSummaryData,
        student: null == student
            ? _value.student
            : student // ignore: cast_nullable_to_non_nullable
                  as StudentSummaryData,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentLoginResponseImpl extends _StudentLoginResponse {
  const _$StudentLoginResponseImpl({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.user,
    required this.student,
  }) : super._();

  factory _$StudentLoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentLoginResponseImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final String sessionId;
  @override
  final UserSummaryData user;
  @override
  final StudentSummaryData student;

  @override
  String toString() {
    return 'StudentLoginResponse(accessToken: $accessToken, refreshToken: $refreshToken, sessionId: $sessionId, user: $user, student: $student)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentLoginResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.student, student) || other.student == student));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    sessionId,
    user,
    student,
  );

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentLoginResponseImplCopyWith<_$StudentLoginResponseImpl>
  get copyWith =>
      __$$StudentLoginResponseImplCopyWithImpl<_$StudentLoginResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentLoginResponseImplToJson(this);
  }
}

abstract class _StudentLoginResponse extends StudentLoginResponse {
  const factory _StudentLoginResponse({
    required final String accessToken,
    required final String refreshToken,
    required final String sessionId,
    required final UserSummaryData user,
    required final StudentSummaryData student,
  }) = _$StudentLoginResponseImpl;
  const _StudentLoginResponse._() : super._();

  factory _StudentLoginResponse.fromJson(Map<String, dynamic> json) =
      _$StudentLoginResponseImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  String get sessionId;
  @override
  UserSummaryData get user;
  @override
  StudentSummaryData get student;

  /// Create a copy of StudentLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentLoginResponseImplCopyWith<_$StudentLoginResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UserSummaryData _$UserSummaryDataFromJson(Map<String, dynamic> json) {
  return _UserSummaryData.fromJson(json);
}

/// @nodoc
mixin _$UserSummaryData {
  String get id => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this UserSummaryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSummaryDataCopyWith<UserSummaryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSummaryDataCopyWith<$Res> {
  factory $UserSummaryDataCopyWith(
    UserSummaryData value,
    $Res Function(UserSummaryData) then,
  ) = _$UserSummaryDataCopyWithImpl<$Res, UserSummaryData>;
  @useResult
  $Res call({String id, String role, String name});
}

/// @nodoc
class _$UserSummaryDataCopyWithImpl<$Res, $Val extends UserSummaryData>
    implements $UserSummaryDataCopyWith<$Res> {
  _$UserSummaryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? role = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSummaryDataImplCopyWith<$Res>
    implements $UserSummaryDataCopyWith<$Res> {
  factory _$$UserSummaryDataImplCopyWith(
    _$UserSummaryDataImpl value,
    $Res Function(_$UserSummaryDataImpl) then,
  ) = __$$UserSummaryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String role, String name});
}

/// @nodoc
class __$$UserSummaryDataImplCopyWithImpl<$Res>
    extends _$UserSummaryDataCopyWithImpl<$Res, _$UserSummaryDataImpl>
    implements _$$UserSummaryDataImplCopyWith<$Res> {
  __$$UserSummaryDataImplCopyWithImpl(
    _$UserSummaryDataImpl _value,
    $Res Function(_$UserSummaryDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? role = null, Object? name = null}) {
    return _then(
      _$UserSummaryDataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSummaryDataImpl extends _UserSummaryData {
  const _$UserSummaryDataImpl({
    required this.id,
    required this.role,
    required this.name,
  }) : super._();

  factory _$UserSummaryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSummaryDataImplFromJson(json);

  @override
  final String id;
  @override
  final String role;
  @override
  final String name;

  @override
  String toString() {
    return 'UserSummaryData(id: $id, role: $role, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSummaryDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, role, name);

  /// Create a copy of UserSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSummaryDataImplCopyWith<_$UserSummaryDataImpl> get copyWith =>
      __$$UserSummaryDataImplCopyWithImpl<_$UserSummaryDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSummaryDataImplToJson(this);
  }
}

abstract class _UserSummaryData extends UserSummaryData {
  const factory _UserSummaryData({
    required final String id,
    required final String role,
    required final String name,
  }) = _$UserSummaryDataImpl;
  const _UserSummaryData._() : super._();

  factory _UserSummaryData.fromJson(Map<String, dynamic> json) =
      _$UserSummaryDataImpl.fromJson;

  @override
  String get id;
  @override
  String get role;
  @override
  String get name;

  /// Create a copy of UserSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSummaryDataImplCopyWith<_$UserSummaryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentSummaryData _$StudentSummaryDataFromJson(Map<String, dynamic> json) {
  return _StudentSummaryData.fromJson(json);
}

/// @nodoc
mixin _$StudentSummaryData {
  String get id => throw _privateConstructorUsedError;
  String get studentNo => throw _privateConstructorUsedError;
  String? get className => throw _privateConstructorUsedError;
  String? get assignedSeatNo => throw _privateConstructorUsedError;

  /// Serializes this StudentSummaryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentSummaryDataCopyWith<StudentSummaryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentSummaryDataCopyWith<$Res> {
  factory $StudentSummaryDataCopyWith(
    StudentSummaryData value,
    $Res Function(StudentSummaryData) then,
  ) = _$StudentSummaryDataCopyWithImpl<$Res, StudentSummaryData>;
  @useResult
  $Res call({
    String id,
    String studentNo,
    String? className,
    String? assignedSeatNo,
  });
}

/// @nodoc
class _$StudentSummaryDataCopyWithImpl<$Res, $Val extends StudentSummaryData>
    implements $StudentSummaryDataCopyWith<$Res> {
  _$StudentSummaryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentNo = null,
    Object? className = freezed,
    Object? assignedSeatNo = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentNo: null == studentNo
                ? _value.studentNo
                : studentNo // ignore: cast_nullable_to_non_nullable
                      as String,
            className: freezed == className
                ? _value.className
                : className // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedSeatNo: freezed == assignedSeatNo
                ? _value.assignedSeatNo
                : assignedSeatNo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentSummaryDataImplCopyWith<$Res>
    implements $StudentSummaryDataCopyWith<$Res> {
  factory _$$StudentSummaryDataImplCopyWith(
    _$StudentSummaryDataImpl value,
    $Res Function(_$StudentSummaryDataImpl) then,
  ) = __$$StudentSummaryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentNo,
    String? className,
    String? assignedSeatNo,
  });
}

/// @nodoc
class __$$StudentSummaryDataImplCopyWithImpl<$Res>
    extends _$StudentSummaryDataCopyWithImpl<$Res, _$StudentSummaryDataImpl>
    implements _$$StudentSummaryDataImplCopyWith<$Res> {
  __$$StudentSummaryDataImplCopyWithImpl(
    _$StudentSummaryDataImpl _value,
    $Res Function(_$StudentSummaryDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentNo = null,
    Object? className = freezed,
    Object? assignedSeatNo = freezed,
  }) {
    return _then(
      _$StudentSummaryDataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentNo: null == studentNo
            ? _value.studentNo
            : studentNo // ignore: cast_nullable_to_non_nullable
                  as String,
        className: freezed == className
            ? _value.className
            : className // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedSeatNo: freezed == assignedSeatNo
            ? _value.assignedSeatNo
            : assignedSeatNo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentSummaryDataImpl extends _StudentSummaryData {
  const _$StudentSummaryDataImpl({
    required this.id,
    required this.studentNo,
    this.className,
    this.assignedSeatNo,
  }) : super._();

  factory _$StudentSummaryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentSummaryDataImplFromJson(json);

  @override
  final String id;
  @override
  final String studentNo;
  @override
  final String? className;
  @override
  final String? assignedSeatNo;

  @override
  String toString() {
    return 'StudentSummaryData(id: $id, studentNo: $studentNo, className: $className, assignedSeatNo: $assignedSeatNo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentSummaryDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentNo, studentNo) ||
                other.studentNo == studentNo) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.assignedSeatNo, assignedSeatNo) ||
                other.assignedSeatNo == assignedSeatNo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, studentNo, className, assignedSeatNo);

  /// Create a copy of StudentSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentSummaryDataImplCopyWith<_$StudentSummaryDataImpl> get copyWith =>
      __$$StudentSummaryDataImplCopyWithImpl<_$StudentSummaryDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentSummaryDataImplToJson(this);
  }
}

abstract class _StudentSummaryData extends StudentSummaryData {
  const factory _StudentSummaryData({
    required final String id,
    required final String studentNo,
    final String? className,
    final String? assignedSeatNo,
  }) = _$StudentSummaryDataImpl;
  const _StudentSummaryData._() : super._();

  factory _StudentSummaryData.fromJson(Map<String, dynamic> json) =
      _$StudentSummaryDataImpl.fromJson;

  @override
  String get id;
  @override
  String get studentNo;
  @override
  String? get className;
  @override
  String? get assignedSeatNo;

  /// Create a copy of StudentSummaryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentSummaryDataImplCopyWith<_$StudentSummaryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
