import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

typedef TokenReader = String? Function();
typedef TokenRefresher = Future<String?> Function();
typedef OnUnauthorized = void Function();

class StudyonApiClient {
  StudyonApiClient({
    required String baseUrl,
    TokenReader? tokenReader,
    TokenRefresher? tokenRefresher,
    OnUnauthorized? onUnauthorized,
  }) : dio = Dio(BaseOptions(
          baseUrl: '$baseUrl${ApiConstants.basePath}',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    if (tokenReader != null) {
      dio.interceptors.add(AuthInterceptor(
        tokenReader: tokenReader,
        tokenRefresher: tokenRefresher,
      ));
    }
    dio.interceptors.add(ErrorInterceptor(onUnauthorized: onUnauthorized));
    if (AppEnv.enableLogging) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  final Dio dio;

  void setDeviceCode(String? deviceCode) {
    if (deviceCode != null) {
      dio.options.headers['X-Device-Code'] = deviceCode;
    } else {
      dio.options.headers.remove('X-Device-Code');
    }
  }
}
