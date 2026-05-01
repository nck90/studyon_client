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

    final parsedError = _parseError(data);
    final errorCode = parsedError?.code;
    final errorMessage = parsedError?.message;

    switch (statusCode) {
      case 400:
      case 409:
      case 422:
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: AppException(
            message: errorMessage ?? '요청을 처리할 수 없습니다.',
            code: errorCode ?? 'REQUEST_FAILED',
          ),
        ));
        return;
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

  ApiError? _parseError(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return ApiError(
          code: (data['code'] as String?) ?? 'API_ERROR',
          message: message,
        );
      }
      if (message is List && message.isNotEmpty) {
        final joined = message.whereType<String>().join('\n');
        if (joined.isNotEmpty) {
          return ApiError(
            code: (data['code'] as String?) ?? 'API_ERROR',
            message: joined,
          );
        }
      }

      final nestedError = data['error'];
      if (nestedError is Map<String, dynamic>) {
        return ApiError.fromJson(nestedError);
      }
      if (nestedError is String && nestedError.isNotEmpty) {
        return ApiError(code: 'API_ERROR', message: nestedError);
      }
    }

    if (data is String && data.isNotEmpty) {
      return ApiError(code: 'API_ERROR', message: data);
    }

    return null;
  }
}
