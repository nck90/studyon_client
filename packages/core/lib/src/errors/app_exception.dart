class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.stackTrace});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = '인증이 필요합니다.',
    super.code = 'UNAUTHORIZED',
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = '접근 권한이 없습니다.',
    super.code = 'FORBIDDEN',
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = '요청한 리소스를 찾을 수 없습니다.',
    super.code = 'NOT_FOUND',
  });
}
