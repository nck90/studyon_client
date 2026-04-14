import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';

import '../api_client.dart';

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({this.onUnauthorized});

  final OnUnauthorized? onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    String? errorCode;
    String? errorMessage;

    if (data is Map<String, dynamic> && data['error'] != null) {
      final apiError = ApiError.fromJson(data['error'] as Map<String, dynamic>);
      errorCode = apiError.code;
      errorMessage = apiError.message;
    }

    switch (statusCode) {
      case 401:
        onUnauthorized?.call();
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: UnauthorizedException(
            message: errorMessage ?? '인증이 필요합니다.',
            code: errorCode ?? 'UNAUTHORIZED',
          ),
        ));
        return;
      case 403:
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: ForbiddenException(
            message: errorMessage ?? '접근 권한이 없습니다.',
            code: errorCode ?? 'FORBIDDEN',
          ),
        ));
        return;
      case 404:
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: NotFoundException(
            message: errorMessage ?? '요청한 리소스를 찾을 수 없습니다.',
            code: errorCode ?? 'NOT_FOUND',
          ),
        ));
        return;
      default:
        if (errorMessage != null) {
          handler.next(DioException(
            requestOptions: err.requestOptions,
            error: AppException(
              message: errorMessage,
              code: errorCode,
            ),
          ));
          return;
        }
    }
    handler.next(err);
  }
}
