import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';

class DisplayApi {
  DisplayApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getCurrent() async {
    final response = await _dio.get(ApiConstants.displayCurrent);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRankings({
    String? periodType,
    String? rankingType,
  }) async {
    final response = await _dio.get(
      ApiConstants.displayRankings,
      queryParameters: {
        if (periodType != null) 'periodType': periodType,
        if (rankingType != null) 'rankingType': rankingType,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _dio.get(ApiConstants.displayStatus);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMotivation() async {
    final response = await _dio.get(ApiConstants.displayMotivation);
    return response.data['data'] as Map<String, dynamic>;
  }
}
