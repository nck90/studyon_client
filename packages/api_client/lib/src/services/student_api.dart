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

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _dio.get(ApiConstants.studentPreferences);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePreferences({
    bool? notificationEnabled,
  }) async {
    final response = await _dio.patch(
      ApiConstants.studentPreferences,
      data: {
        if (notificationEnabled != null)
          'notificationEnabled': notificationEnabled,
      },
    );
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

  // Points
  Future<Map<String, dynamic>> getPointBalance() async {
    final response = await _dio.get(ApiConstants.studentPoints);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getPointHistory({int take = 50, int skip = 0}) async {
    final response = await _dio.get(
      ApiConstants.studentPointsHistory,
      queryParameters: {'take': take, 'skip': skip},
    );
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  // Character
  Future<Map<String, dynamic>> getMyCharacter() async {
    final response = await _dio.get(ApiConstants.studentCharacter);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getCharacterShop({String? category}) async {
    final response = await _dio.get(
      ApiConstants.studentCharacterShop,
      queryParameters: category != null ? {'category': category} : null,
    );
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> buyCharacterItem(String itemId) async {
    final response = await _dio.post('${ApiConstants.studentCharacter}/buy/$itemId');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> equipCharacterItems({
    String? hatItemId,
    String? glassesItemId,
    String? outfitItemId,
    String? bgItemId,
    String? expressionItemId,
  }) async {
    final response = await _dio.post(
      ApiConstants.studentCharacterEquip,
      data: {
        if (hatItemId != null) 'hatItemId': hatItemId,
        if (glassesItemId != null) 'glassesItemId': glassesItemId,
        if (outfitItemId != null) 'outfitItemId': outfitItemId,
        if (bgItemId != null) 'bgItemId': bgItemId,
        if (expressionItemId != null) 'expressionItemId': expressionItemId,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getOwnedCharacterItems() async {
    final response = await _dio.get(ApiConstants.studentCharacterItems);
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
