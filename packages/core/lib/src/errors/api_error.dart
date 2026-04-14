class ApiError {
  const ApiError({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? '알 수 없는 오류가 발생했습니다.',
    );
  }

  @override
  String toString() => 'ApiError($code): $message';
}
