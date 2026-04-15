import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';
import 'package:studyon_models/studyon_models.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<StudentLoginResponse> studentSignup(StudentSignupRequest request) async {
    final response = await _dio.post(
      '/auth/student/signup',
      data: request.toJson(),
    );
    return StudentLoginResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<StudentLoginResponse> studentLogin(StudentLoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.studentLogin,
      data: request.toJson(),
    );
    return StudentLoginResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> adminLogin(AdminLoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.adminLogin,
      data: request.toJson(),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
    );
    return AuthTokens.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> logout({
    required String sessionId,
    required String refreshToken,
  }) async {
    await _dio.post(
      ApiConstants.logout,
      data: {
        'sessionId': sessionId,
        'refreshToken': refreshToken,
      },
    );
  }

  Future<UserSummary> me() async {
    final response = await _dio.get(ApiConstants.me);
    return UserSummary.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
