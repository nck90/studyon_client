import 'package:dio/dio.dart';

import '../api_client.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenReader,
    this.tokenRefresher,
  });

  final TokenReader tokenReader;
  final TokenRefresher? tokenRefresher;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenReader();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && tokenRefresher != null) {
      final newToken = await tokenRefresher!();
      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    handler.next(err);
  }
}
