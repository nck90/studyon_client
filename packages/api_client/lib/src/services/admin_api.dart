import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';

class AdminApi {
  AdminApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getDashboard({
    String? date,
    String? classId,
  }) async {
    final response = await _dio.get(
      ApiConstants.adminDashboard,
      queryParameters: {
        if (date != null) 'date': date,
        if (classId != null) 'classId': classId,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudents({
    String? keyword,
    String? gradeId,
    String? classId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.adminStudents,
      queryParameters: {
        if (keyword != null) 'keyword': keyword,
        if (gradeId != null) 'gradeId': gradeId,
        if (classId != null) 'classId': classId,
        'page': page,
        'limit': limit,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentDetail(String studentId) async {
    final response =
        await _dio.get('${ApiConstants.adminStudents}/$studentId');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> createStudent(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.adminStudents, data: data);
  }

  Future<void> updateStudent(
      String studentId, Map<String, dynamic> data) async {
    await _dio.patch('${ApiConstants.adminStudents}/$studentId', data: data);
  }

  Future<void> deleteStudent(String studentId) async {
    await _dio.delete('${ApiConstants.adminStudents}/$studentId');
  }

  Future<List<dynamic>> getSeats({String? status}) async {
    final response = await _dio.get(
      ApiConstants.adminSeats,
      queryParameters: {if (status != null) 'status': status},
    );
    return response.data['data'] as List;
  }

  Future<void> assignSeat(String seatId, Map<String, dynamic> data) async {
    await _dio.post('${ApiConstants.adminSeats}/$seatId/assign', data: data);
  }

  Future<Map<String, dynamic>> getAttendances({
    String? date,
    String? classId,
  }) async {
    final response = await _dio.get(
      ApiConstants.adminAttendances,
      queryParameters: {
        if (date != null) 'date': date,
        if (classId != null) 'classId': classId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudyOverview({
    String? startDate,
    String? endDate,
    String? classId,
  }) async {
    final response = await _dio.get(
      ApiConstants.adminStudyOverview,
      queryParameters: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (classId != null) 'classId': classId,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.adminNotifications, data: data);
  }
}
