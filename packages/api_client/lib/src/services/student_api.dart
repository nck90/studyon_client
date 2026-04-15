import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';
import 'package:studyon_models/studyon_models.dart';

class StudentApi {
  StudentApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(ApiConstants.studentProfile);
    return response.data['data'] as Map<String, dynamic>;
  }

  // Home
  Future<StudentHome> getHome() async {
    final response = await _dio.get(ApiConstants.studentHome);
    return StudentHome.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // Attendance
  Future<Attendance?> getTodayAttendance() async {
    final response = await _dio.get(ApiConstants.studentAttendanceToday);
    final data = response.data['data'];
    if (data == null) return null;
    return Attendance.fromJson(data as Map<String, dynamic>);
  }

  Future<Attendance> checkIn({String? seatId}) async {
    final response = await _dio.post(
      ApiConstants.studentCheckIn,
      data: seatId != null ? {'seatId': seatId} : null,
    );
    return Attendance.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<Attendance> checkOut({bool forceCloseStudySession = true}) async {
    final response = await _dio.post(
      ApiConstants.studentCheckOut,
      data: {'forceCloseStudySession': forceCloseStudySession},
    );
    return Attendance.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // Seat
  Future<Seat?> getMySeat() async {
    final response = await _dio.get(ApiConstants.studentSeatMy);
    final data = response.data['data'];
    if (data == null) return null;
    return Seat.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getSeatMap({String? zone}) async {
    final response = await _dio.get(
      ApiConstants.studentSeatMap,
      queryParameters: zone != null ? {'zone': zone} : null,
    );
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getAvailableSeats({String? zone}) async {
    final response = await _dio.get(
      ApiConstants.studentSeatsAvailable,
      queryParameters: zone != null ? {'zone': zone} : null,
    );
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> requestSeatChange({
    required String toSeatId,
    String? reason,
  }) async {
    await _dio.post(
      '/student/seat-change-requests',
      data: {
        'toSeatId': toSeatId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  // Study Plans
  Future<List<StudyPlan>> getStudyPlans({String? date}) async {
    final response = await _dio.get(
      ApiConstants.studentStudyPlans,
      queryParameters: date != null ? {'date': date} : null,
    );
    final list = response.data['data'] as List;
    return list
        .map((e) => StudyPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StudyPlan> createStudyPlan(CreateStudyPlanRequest request) async {
    final response = await _dio.post(
      ApiConstants.studentStudyPlans,
      data: request.toJson(),
    );
    return StudyPlan.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<StudyPlan> updateStudyPlan(
      String planId, Map<String, dynamic> data) async {
    final response = await _dio.patch(
      '${ApiConstants.studentStudyPlans}/$planId',
      data: data,
    );
    return StudyPlan.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteStudyPlan(String planId) async {
    await _dio.delete('${ApiConstants.studentStudyPlans}/$planId');
  }

  Future<void> completePlan(String planId) async {
    await _dio.post('${ApiConstants.studentStudyPlans}/$planId/complete');
  }

  // Study Sessions
  Future<StudySession?> getActiveSession() async {
    final response = await _dio.get(ApiConstants.studentStudySessionActive);
    final data = response.data['data'];
    if (data == null) return null;
    return StudySession.fromJson(data as Map<String, dynamic>);
  }

  Future<StudySession> startSession({String? linkedPlanId}) async {
    final response = await _dio.post(
      ApiConstants.studentStudySessionStart,
      data: linkedPlanId != null ? {'linkedPlanId': linkedPlanId} : null,
    );
    return StudySession.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<StudySession> pauseSession(String sessionId) async {
    final response = await _dio.post(
      '${ApiConstants.studentStudySessionActive.replaceAll('/active', '')}/$sessionId/pause',
    );
    return StudySession.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<StudySession> resumeSession(String sessionId) async {
    final response = await _dio.post(
      '${ApiConstants.studentStudySessionActive.replaceAll('/active', '')}/$sessionId/resume',
    );
    return StudySession.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<StudySession> endSession(String sessionId) async {
    final response = await _dio.post(
      '${ApiConstants.studentStudySessionActive.replaceAll('/active', '')}/$sessionId/end',
    );
    return StudySession.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // Study Logs
  Future<StudyLog> createStudyLog(CreateStudyLogRequest request) async {
    final response = await _dio.post(
      ApiConstants.studentStudyLogs,
      data: request.toJson(),
    );
    return StudyLog.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<StudyLog>> getStudyLogs({String? date}) async {
    final response = await _dio.get(
      ApiConstants.studentStudyLogs,
      queryParameters: date != null ? {'date': date} : null,
    );
    final list = response.data['data'] as List;
    return list
        .map((e) => StudyLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Reports
  Future<DailyReport> getDailyReport({String? date}) async {
    final response = await _dio.get(
      ApiConstants.studentReportsDaily,
      queryParameters: date != null ? {'date': date} : null,
    );
    return DailyReport.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // Rankings
  Future<RankingResponse> getRankings({
    required String periodType,
    required String rankingType,
  }) async {
    final response = await _dio.get(
      ApiConstants.studentRankings,
      queryParameters: {
        'periodType': periodType,
        'rankingType': rankingType,
      },
    );
    return RankingResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _dio.get(ApiConstants.studentNotifications);
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _dio.post('/student/notifications/$notificationId/read');
  }
}
