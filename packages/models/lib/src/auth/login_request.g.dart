// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentLoginRequestImpl _$$StudentLoginRequestImplFromJson(
  Map<String, dynamic> json,
) => _$StudentLoginRequestImpl(
  studentNo: json['studentNo'] as String,
  name: json['name'] as String,
  deviceCode: json['deviceCode'] as String?,
);

Map<String, dynamic> _$$StudentLoginRequestImplToJson(
  _$StudentLoginRequestImpl instance,
) => <String, dynamic>{
  'studentNo': instance.studentNo,
  'name': instance.name,
  'deviceCode': instance.deviceCode,
};

_$StudentSignupRequestImpl _$$StudentSignupRequestImplFromJson(
  Map<String, dynamic> json,
) => _$StudentSignupRequestImpl(
  studentNo: json['studentNo'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  deviceCode: json['deviceCode'] as String?,
);

Map<String, dynamic> _$$StudentSignupRequestImplToJson(
  _$StudentSignupRequestImpl instance,
) => <String, dynamic>{
  'studentNo': instance.studentNo,
  'name': instance.name,
  'phone': instance.phone,
  'deviceCode': instance.deviceCode,
};

_$AdminLoginRequestImpl _$$AdminLoginRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AdminLoginRequestImpl(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$AdminLoginRequestImplToJson(
  _$AdminLoginRequestImpl instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

_$StudentLoginResponseImpl _$$StudentLoginResponseImplFromJson(
  Map<String, dynamic> json,
) => _$StudentLoginResponseImpl(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  sessionId: json['sessionId'] as String,
  user: UserSummaryData.fromJson(json['user'] as Map<String, dynamic>),
  student: StudentSummaryData.fromJson(json['student'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$StudentLoginResponseImplToJson(
  _$StudentLoginResponseImpl instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'sessionId': instance.sessionId,
  'user': instance.user,
  'student': instance.student,
};

_$UserSummaryDataImpl _$$UserSummaryDataImplFromJson(
  Map<String, dynamic> json,
) => _$UserSummaryDataImpl(
  id: json['id'] as String,
  role: json['role'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$$UserSummaryDataImplToJson(
  _$UserSummaryDataImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'name': instance.name,
};

_$StudentSummaryDataImpl _$$StudentSummaryDataImplFromJson(
  Map<String, dynamic> json,
) => _$StudentSummaryDataImpl(
  id: json['id'] as String,
  studentNo: json['studentNo'] as String,
  className: json['className'] as String?,
  assignedSeatNo: json['assignedSeatNo'] as String?,
);

Map<String, dynamic> _$$StudentSummaryDataImplToJson(
  _$StudentSummaryDataImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentNo': instance.studentNo,
  'className': instance.className,
  'assignedSeatNo': instance.assignedSeatNo,
};
