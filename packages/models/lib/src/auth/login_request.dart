import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

@freezed
class StudentLoginRequest with _$StudentLoginRequest {
  const StudentLoginRequest._();
  const factory StudentLoginRequest({
    required String studentNo,
    required String name,
    String? deviceCode,
  }) = _StudentLoginRequest;

  factory StudentLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$StudentLoginRequestFromJson(json);
}

@freezed
class StudentSignupRequest with _$StudentSignupRequest {
  const StudentSignupRequest._();
  const factory StudentSignupRequest({
    required String studentNo,
    required String name,
    String? phone,
    String? deviceCode,
  }) = _StudentSignupRequest;

  factory StudentSignupRequest.fromJson(Map<String, dynamic> json) =>
      _$StudentSignupRequestFromJson(json);
}

@freezed
class AdminLoginRequest with _$AdminLoginRequest {
  const AdminLoginRequest._();
  const factory AdminLoginRequest({
    required String email,
    required String password,
  }) = _AdminLoginRequest;

  factory AdminLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminLoginRequestFromJson(json);
}

@freezed
class StudentLoginResponse with _$StudentLoginResponse {
  const StudentLoginResponse._();
  const factory StudentLoginResponse({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    required UserSummaryData user,
    required StudentSummaryData student,
  }) = _StudentLoginResponse;

  factory StudentLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentLoginResponseFromJson(json);
}

@freezed
class UserSummaryData with _$UserSummaryData {
  const UserSummaryData._();
  const factory UserSummaryData({
    required String id,
    required String role,
    required String name,
  }) = _UserSummaryData;

  factory UserSummaryData.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryDataFromJson(json);
}

@freezed
class StudentSummaryData with _$StudentSummaryData {
  const StudentSummaryData._();
  const factory StudentSummaryData({
    required String id,
    required String studentNo,
    String? className,
    String? assignedSeatNo,
  }) = _StudentSummaryData;

  factory StudentSummaryData.fromJson(Map<String, dynamic> json) =>
      _$StudentSummaryDataFromJson(json);
}
