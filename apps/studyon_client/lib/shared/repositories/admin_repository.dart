import 'package:dio/dio.dart';
import 'package:studyon_models/studyon_models.dart';

import '../models/admin_models.dart';

class AdminRepository {
  AdminRepository({required this.dio});

  final Dio dio;

  Future<AdminDashboardData> getDashboard() async {
    final today = _dateOnly(DateTime.now());
    final results = await Future.wait([
      dio.get('/admin/dashboard', queryParameters: {'date': today}),
      dio.get('/admin/seats'),
      dio.get('/admin/rankings', queryParameters: {
        'periodType': 'DAILY',
        'rankingType': 'STUDY_TIME',
      }),
      dio.get('/admin/study-overview', queryParameters: {
        'startDate': today,
        'endDate': today,
      }),
    ]);

    final dashboardData = results[0].data['data'] as Map<String, dynamic>? ?? const {};
    final seats = _mapSeatList(results[1].data['data'] as List? ?? const []);
    final rankingPayload = results[2].data['data'] as Map<String, dynamic>? ?? const {};
    final rankingItems = (rankingPayload['items'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => RankingItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final overview = _aggregateStudyOverview(results[3].data['data'] as List? ?? const []);

    return AdminDashboardData(
      checkedIn: (dashboardData['checkedInCount'] as num?)?.toInt() ?? 0,
      emptySeats: seats.where((seat) => seat.status == 'empty').length,
      totalSeats: seats.length,
      totalStudyMinutes: overview.totalStudyMinutes,
      avgStudyMinutes: overview.avgStudyMinutes.toDouble(),
      seats: seats,
      topRankings: rankingItems,
    );
  }

  Future<List<Seat>> getSeats() async {
    final response = await dio.get('/admin/seats');
    return _mapSeatList(response.data['data'] as List? ?? const []);
  }

  Future<void> createSeat(String seatNo) async {
    await dio.post('/admin/seats', data: {
      'seatNo': seatNo,
      'zone': seatNo.isNotEmpty ? seatNo.substring(0, 1) : null,
    });
  }

  Future<void> deleteSeat(String seatId) async {
    await dio.delete('/admin/seats/$seatId');
  }

  Future<List<Student>> getStudents({
    String? keyword,
  }) async {
    final today = _dateOnly(DateTime.now());
    final results = await Future.wait([
      dio.get('/admin/students', queryParameters: {
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      }),
      dio.get('/admin/attendances', queryParameters: {'date': today}),
      dio.get('/admin/seats'),
    ]);

    final studentsPayload = results[0].data['data'] as List? ?? const [];
    final attendances = results[1].data['data'] as List? ?? const [];
    final seats = results[2].data['data'] as List? ?? const [];

    final attendanceByStudentId = <String, Map<String, dynamic>>{};
    for (final item in attendances.whereType<Map>()) {
      final data = Map<String, dynamic>.from(item);
      final student = data['student'];
      if (student is Map && student['id'] is String) {
        attendanceByStudentId[student['id'] as String] = data;
      }
    }

    final activeSeatStudentIds = <String>{};
    for (final item in seats.whereType<Map>()) {
      final data = Map<String, dynamic>.from(item);
      final currentStudent = data['currentStudent'];
      if (currentStudent is Map && currentStudent['id'] is String) {
        activeSeatStudentIds.add(currentStudent['id'] as String);
      }
    }

    return studentsPayload
        .whereType<Map>()
        .map((item) => _mapStudent(
              Map<String, dynamic>.from(item),
              attendanceByStudentId[item['id'] as String? ?? ''],
              activeSeatStudentIds,
            ))
        .toList();
  }

  Future<Student> getStudentDetail(String studentId) async {
    final response = await dio.get('/admin/students/$studentId');
    final payload = response.data['data'] as Map<String, dynamic>;
    return _mapStudent(payload, null, const {});
  }

  Future<AdminStudentDetail> getStudentDetailData(String studentId) async {
    final response = await dio.get('/admin/students/$studentId');
    final payload = response.data['data'] as Map<String, dynamic>;
    final student = _mapStudent(payload, null, const {});

    final logs = (payload['studyLogs'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final attendances = (payload['attendances'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final now = DateTime.now();
    final todayKey = _dateOnly(now);
    final weekRange = _resolvePeriod('weekly');
    final monthRange = _resolvePeriod('monthly');

    int sumMinutes(Iterable<Map<String, dynamic>> items) => items.fold<int>(
          0,
          (sum, item) => sum + ((item['studyMinutes'] as num?)?.toInt() ?? 0),
        );

    bool inRange(String? raw, String start, String end) {
      if (raw == null) return false;
      final key = raw.split('T').first;
      return key.compareTo(start) >= 0 && key.compareTo(end) <= 0;
    }

    final todayStudyMinutes =
        sumMinutes(logs.where((item) => item['logDate']?.toString().split('T').first == todayKey));
    final weeklyStudyMinutes = sumMinutes(
      logs.where((item) => inRange(item['logDate']?.toString(), weekRange.$1, weekRange.$2)),
    );
    final monthlyStudyMinutes = sumMinutes(
      logs.where((item) => inRange(item['logDate']?.toString(), monthRange.$1, monthRange.$2)),
    );

    final weeklyGrouped = <String, int>{};
    for (final item in logs.where(
      (item) => inRange(item['logDate']?.toString(), weekRange.$1, weekRange.$2),
    )) {
      final key = item['logDate']?.toString().split('T').first ?? todayKey;
      weeklyGrouped[key] =
          (weeklyGrouped[key] ?? 0) + ((item['studyMinutes'] as num?)?.toInt() ?? 0);
    }
    final weeklyStats = weeklyGrouped.entries
        .map((entry) => DailyStat(date: entry.key.substring(5), minutes: entry.value, count: 1))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final subjectGrouped = <String, int>{};
    for (final item in logs) {
      final subject = item['subjectName']?.toString() ?? '기타';
      subjectGrouped[subject] =
          (subjectGrouped[subject] ?? 0) + ((item['studyMinutes'] as num?)?.toInt() ?? 0);
    }
    final subjectStats = subjectGrouped.entries
        .map((entry) => SubjectStat(subject: entry.key, minutes: entry.value))
        .toList()
      ..sort((a, b) => b.minutes.compareTo(a.minutes));

    final activityLogs = <ActivityLogItem>[
      ...attendances.take(10).expand((item) {
        final checkIn = item['checkInAt']?.toString();
        final checkOut = item['checkOutAt']?.toString();
        return [
          if (checkIn != null)
            ActivityLogItem(
              time: _clock(checkIn),
              label: '입실',
              kind: 'checkin',
            ),
          if (checkOut != null)
            ActivityLogItem(
              time: _clock(checkOut),
              label: '퇴실',
              kind: 'checkout',
            ),
        ];
      }),
      ...logs.take(10).map(
        (item) => ActivityLogItem(
          time: _clock(item['createdAt']?.toString()),
          label: '${item['subjectName']} 학습 기록',
          kind: 'study',
        ),
      ),
    ]..sort((a, b) => b.time.compareTo(a.time));

    final attended = attendances.where((item) {
      final status = item['attendanceStatus']?.toString();
      return status == 'CHECKED_IN' || status == 'CHECKED_OUT';
    }).length;

    return AdminStudentDetail(
      student: student,
      todayStudyMinutes: todayStudyMinutes,
      weeklyStudyMinutes: weeklyStudyMinutes,
      monthlyStudyMinutes: monthlyStudyMinutes,
      attendanceRate: attendances.isEmpty ? 0 : attended / attendances.length,
      weeklyStats: weeklyStats,
      subjectStats: subjectStats,
      activityLogs: activityLogs.take(12).toList(),
    );
  }

  Future<void> createStudent({
    required String name,
    required String studentNo,
    String? gradeId,
    String? classId,
    String? assignedSeatId,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'studentNo': studentNo,
    };
    if (gradeId != null) data['gradeId'] = gradeId;
    if (classId != null) data['classId'] = classId;
    if (assignedSeatId != null) data['assignedSeatId'] = assignedSeatId;
    await dio.post('/admin/students', data: data);
  }

  Future<void> updateStudent({
    required String studentId,
    required String name,
    required String studentNo,
    String? gradeId,
    String? classId,
    String? assignedSeatId,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'studentNo': studentNo,
      'assignedSeatId': assignedSeatId,
    };
    if (gradeId != null) data['gradeId'] = gradeId;
    if (classId != null) data['classId'] = classId;
    await dio.patch('/admin/students/$studentId', data: data);
  }

  Future<void> deleteStudent(String studentId) async {
    await dio.delete('/admin/students/$studentId');
  }

  Future<List<RankingItem>> getRankings(String period) async {
    final response = await dio.get('/admin/rankings', queryParameters: {
      'periodType': _periodType(period),
      'rankingType': 'STUDY_TIME',
    });
    final payload = response.data['data'] as Map<String, dynamic>? ?? const {};
    final items = payload['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => RankingItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<AdminAttendanceRecord>> getAttendance(String date) async {
    final response = await dio.get('/admin/attendances', queryParameters: {
      'date': date,
    });
    final items = response.data['data'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => _mapAttendance(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<StudyOverviewData> getStudyOverview(String period) async {
    final range = _resolvePeriod(period);
    final results = await Future.wait([
      dio.get('/admin/study-overview', queryParameters: {
        'startDate': range.$1,
        'endDate': range.$2,
      }),
      dio.get('/admin/study-overview/subjects', queryParameters: {
        'startDate': range.$1,
        'endDate': range.$2,
      }),
    ]);
    final overview = _aggregateStudyOverview(results[0].data['data'] as List? ?? const []);
    final subjects = (results[1].data['data'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => SubjectStat(
              subject: item['subjectName']?.toString() ?? '기타',
              minutes: (item['studyMinutes'] as num?)?.toInt() ?? 0,
            ))
        .toList();
    return StudyOverviewData(
      totalStudyMinutes: overview.totalStudyMinutes,
      avgStudyMinutes: overview.avgStudyMinutes,
      attendanceRate: overview.attendanceRate,
      activeStudents: overview.activeStudents,
      dailyStats: overview.dailyStats,
      subjectStats: subjects,
    );
  }

  Future<AttendanceSummary> getAttendanceSummary(String mode, String anchorDate) async {
    final date = DateTime.tryParse(anchorDate) ?? DateTime.now();
    final range = mode == 'daily'
        ? (_dateOnly(date), _dateOnly(date))
        : mode == 'monthly'
        ? (
            _dateOnly(DateTime(date.year, date.month, 1)),
            _dateOnly(DateTime(date.year, date.month + 1, 0)),
          )
        : (
            _dateOnly(DateTime(date.year, date.month, date.day - (date.weekday - 1))),
            _dateOnly(DateTime(date.year, date.month, date.day - (date.weekday - 1) + 6)),
          );
    final response = await dio.get('/admin/attendances', queryParameters: {
      'startDate': range.$1,
      'endDate': range.$2,
    });
    final items = (response.data['data'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => _mapAttendance(Map<String, dynamic>.from(item)))
        .toList();
    final present = items.where((item) => item.status != 'absent').length;
    final absent = items.where((item) => item.status == 'absent').length;
    final late = items.where((item) => item.isLate).length;
    final avgStay = items.where((item) => item.stayMinutes > 0).isEmpty
        ? 0
        : items
                .where((item) => item.stayMinutes > 0)
                .fold<int>(0, (sum, item) => sum + item.stayMinutes) ~/
            items.where((item) => item.stayMinutes > 0).length;
    return AttendanceSummary(
      periodLabel: mode == 'monthly'
          ? '${date.year}년 ${date.month}월'
          : '${range.$1.substring(5)} - ${range.$2.substring(5)}',
      attendanceRate: items.isEmpty ? 0 : present / items.length,
      avgStayMinutes: avgStay,
      lateCount: late,
      absentCount: absent,
      totalCount: items.length,
    );
  }

  Future<AppSettings> getSettings() async {
    final results = await Future.wait([
      dio.get('/admin/settings/attendance-policy'),
      dio.get('/admin/settings/tv-display'),
    ]);
    final attendance = results[0].data['data'] as Map<String, dynamic>? ?? const {};
    final tv = results[1].data['data'] as Map<String, dynamic>? ?? const {};

    return AppSettings(
      academyName: '자습ON 학원',
      openTime: attendance['lateCutoffTime'] as String? ?? '09:00',
      closeTime: attendance['earlyLeaveCutoffTime'] as String? ?? '22:00',
      lateThresholdMinutes:
          (attendance['autoCheckoutAfterMinutes'] as num?)?.toInt() ?? 15,
      autoCheckoutEnabled: attendance['autoCheckoutEnabled'] == true,
      notificationEnabled: true,
      tvDisplayEnabled: tv.isNotEmpty,
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    await Future.wait([
      dio.patch('/admin/settings/attendance-policy', data: {
        'policyName': settings.academyName,
        'lateCutoffTime': settings.openTime,
        'earlyLeaveCutoffTime': settings.closeTime,
        'autoCheckoutEnabled': settings.autoCheckoutEnabled,
        'autoCheckoutAfterMinutes': settings.lateThresholdMinutes,
      }),
      dio.patch('/admin/settings/tv-display', data: {
        'activeScreen': settings.tvDisplayEnabled ? 'RANKING' : 'STATUS',
        'rotationEnabled': settings.tvDisplayEnabled,
        'rotationIntervalSeconds': 30,
        'displayOptions': {'rankingType': 'STUDY_TIME'},
      }),
    ]);
  }

  Future<List<AdminNotification>> getNotifications() async {
    final response = await dio.get('/admin/notifications');
    final items = response.data['data'] as List? ?? const [];
    return items.whereType<Map>().map((item) {
      final data = Map<String, dynamic>.from(item);
      return AdminNotification(
        id: data['id']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        body: data['body']?.toString() ?? '',
        type: _notificationType(data['notificationType']?.toString()),
        createdAt: _timeAgo(data['createdAt']?.toString()),
        isRead: data['status']?.toString() == 'SENT',
      );
    }).toList();
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    List<String>? userIds,
  }) async {
    if (userIds != null && userIds.isNotEmpty) {
      await dio.post('/admin/notifications/direct', data: {
        'userIds': userIds,
        'title': title,
        'body': body,
      });
      return;
    }

    final created = await dio.post('/admin/notifications', data: {
      'title': title,
      'body': body,
      'targetScope': 'STUDENT',
      'notificationType': 'NOTICE',
      'channel': 'IN_APP',
    });
    final id = created.data['data']?['id'];
    if (id != null) {
      await dio.post('/admin/notifications/$id/send');
    }
  }

  Future<TvDisplayData> getTvControl() async {
    final results = await Future.wait([
      dio.get('/display/current'),
      dio.get('/display/rankings', queryParameters: {
        'periodType': 'DAILY',
        'rankingType': 'STUDY_TIME',
      }),
      dio.get('/admin/seats'),
    ]);

    final current = results[0].data['data'] as Map<String, dynamic>? ?? const {};
    final rankingPayload = results[1].data['data'] as Map<String, dynamic>? ?? const {};
    final seats = _mapSeatList(results[2].data['data'] as List? ?? const []);
    final items = rankingPayload['items'] as List? ?? const [];

    return TvDisplayData(
      isOn: current.isNotEmpty,
      displayMode: _displayModeFromApi(current['activeScreen']?.toString()),
      message: '오늘도 열심히 공부합시다!',
      rankings: items
          .whereType<Map>()
          .map((item) => RankingItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      occupiedSeats: seats.where((seat) => seat.status == 'studying').length,
      totalSeats: seats.length,
    );
  }

  Future<void> updateTvControl(String mode) async {
    await dio.post('/display/control', data: {
      'activeScreen': _displayModeToApi(mode),
    });
  }

  Future<AdminFormOptions> getFormOptions() async {
    final results = await Future.wait([
      dio.get('/admin/grades'),
      dio.get('/admin/classes'),
      dio.get('/admin/seats'),
    ]);

    final grades = (results[0].data['data'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => AdminOption(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
            ))
        .toList();
    final classes = (results[1].data['data'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => AdminOption(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
            ))
        .toList();
    final seats = _mapSeatList(results[2].data['data'] as List? ?? const [])
        .where((seat) => seat.status == 'empty' || seat.status == 'locked')
        .map((seat) => AdminOption(id: seat.id, name: seat.seatNo))
        .toList();

    return AdminFormOptions(
      grades: grades,
      classes: classes,
      seats: seats,
    );
  }

  StudyOverviewData _aggregateStudyOverview(List items) {
    final records = items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final totalStudyMinutes = records.fold<int>(
      0,
      (sum, item) => sum + ((item['studyMinutes'] as num?)?.toInt() ?? 0),
    );
    final uniqueStudents = records
        .map((item) => item['studentId']?.toString())
        .whereType<String>()
        .toSet();
    final attendedCount = records.where((item) {
      final status = item['attendanceStatus']?.toString();
      return status != null && status != 'ABSENT';
    }).length;

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in records) {
      final key = item['metricDate']?.toString().split('T').first ?? '';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final dailyStats = grouped.entries.map((entry) {
      final total = entry.value.fold<int>(
        0,
        (sum, item) => sum + ((item['studyMinutes'] as num?)?.toInt() ?? 0),
      );
      final count = entry.value.where((item) {
        final status = item['attendanceStatus']?.toString();
        return status != null && status != 'ABSENT';
      }).length;
      return DailyStat(date: entry.key, minutes: total, count: count);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return StudyOverviewData(
      totalStudyMinutes: totalStudyMinutes,
      avgStudyMinutes: uniqueStudents.isEmpty
          ? 0
          : (totalStudyMinutes / uniqueStudents.length).round(),
      attendanceRate:
          records.isEmpty ? 0 : attendedCount / records.length,
      activeStudents: uniqueStudents.length,
      dailyStats: dailyStats,
      subjectStats: const [],
    );
  }

  List<Seat> _mapSeatList(List items) {
    return items.whereType<Map>().map((item) {
      final data = Map<String, dynamic>.from(item);
      final currentStudent = data['currentStudent'];
      final currentStudentName = currentStudent is Map
          ? currentStudent['name']?.toString() ??
              (currentStudent['user'] is Map
                  ? currentStudent['user']['name']?.toString()
                  : null)
          : null;
      final apiStatus = data['uiStatus']?.toString() ?? data['status']?.toString();
      return Seat(
        id: data['id']?.toString() ?? '',
        seatNo: data['seatNo']?.toString() ?? '',
        status: _seatStatus(apiStatus, hasCurrentStudent: currentStudentName != null),
        zone: data['zone']?.toString(),
        assignedStudentId: currentStudent is Map ? currentStudent['id']?.toString() : null,
        assignedStudentName: currentStudentName,
        isLocked: data['status']?.toString() == 'LOCKED',
        isReserved: data['status']?.toString() == 'RESERVED',
      );
    }).toList();
  }

  Student _mapStudent(
    Map<String, dynamic> data,
    Map<String, dynamic>? attendance,
    Set<String> activeSeatStudentIds,
  ) {
    final user = data['user'] as Map<String, dynamic>? ?? const {};
    final grade = data['grade'] as Map<String, dynamic>?;
    final klass = data['class'] as Map<String, dynamic>?;
    final group = data['group'] as Map<String, dynamic>?;
    final seat = data['assignedSeat'] as Map<String, dynamic>?;
    final studentId = data['id']?.toString() ?? '';
    final attendanceStatus = attendance?['attendanceStatus']?.toString();

    String status = 'notCheckedIn';
    if (attendanceStatus == 'CHECKED_OUT') {
      status = 'checkedOut';
    } else if (attendanceStatus == 'CHECKED_IN') {
      status = activeSeatStudentIds.contains(studentId) ? 'studying' : 'studying';
    }

    return Student(
      id: studentId,
      studentNo: data['studentNo']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      gradeId: data['gradeId']?.toString(),
      classId: data['classId']?.toString(),
      groupId: data['groupId']?.toString(),
      gradeName: grade?['name']?.toString(),
      className: klass?['name']?.toString(),
      groupName: group?['name']?.toString(),
      assignedSeatId: data['assignedSeatId']?.toString(),
      assignedSeatNo: seat?['seatNo']?.toString(),
      status: status,
    );
  }

  AdminAttendanceRecord _mapAttendance(Map<String, dynamic> data) {
    final student = data['student'] as Map<String, dynamic>? ?? const {};
    final user = student['user'] as Map<String, dynamic>? ?? const {};
    final status = data['attendanceStatus']?.toString();
    return AdminAttendanceRecord(
      id: data['id']?.toString() ?? '',
      studentId: student['id']?.toString() ?? data['studentId']?.toString() ?? '',
      studentNo: student['studentNo']?.toString() ?? '',
      studentName: user['name']?.toString() ?? '',
      status: status == 'ABSENT' ? 'absent' : 'present',
      checkInAt: _clock(data['checkInAt']?.toString()),
      checkOutAt: _clock(data['checkOutAt']?.toString()),
      stayMinutes: (data['stayMinutes'] as num?)?.toInt() ?? 0,
      isLate: data['lateStatus']?.toString() == 'LATE',
    );
  }

  String _seatStatus(String? value, {required bool hasCurrentStudent}) {
    switch (value) {
      case 'onBreak':
        return 'onBreak';
      case 'studying':
        return 'studying';
      case 'LOCKED':
        return 'locked';
      case 'OCCUPIED':
        return hasCurrentStudent ? 'studying' : 'empty';
      case 'RESERVED':
      case 'AVAILABLE':
      default:
        return hasCurrentStudent ? 'studying' : 'empty';
    }
  }

  (String, String) _resolvePeriod(String period) {
    final now = DateTime.now();
    if (period == 'daily') {
      final date = _dateOnly(now);
      return (date, date);
    }
    if (period == 'monthly') {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      return (_dateOnly(start), _dateOnly(end));
    }
    final weekday = now.weekday;
    final start = DateTime(now.year, now.month, now.day - (weekday - 1));
    final end = start.add(const Duration(days: 6));
    return (_dateOnly(start), _dateOnly(end));
  }

  String _periodType(String period) {
    switch (period) {
      case 'monthly':
        return 'MONTHLY';
      case 'weekly':
        return 'WEEKLY';
      default:
        return 'DAILY';
    }
  }

  String _notificationType(String? value) {
    switch (value) {
      case 'CHECK_IN':
        return 'attendance';
      case 'LEAVE_TIME':
        return 'checkout';
      case 'LATE_WARNING':
        return 'late';
      case 'BADGE':
        return 'goal';
      default:
        return 'notice';
    }
  }

  String _displayModeFromApi(String? value) {
    switch (value) {
      case 'STATUS':
        return 'status';
      case 'MOTIVATION':
        return 'motivation';
      default:
        return 'ranking';
    }
  }

  String _displayModeToApi(String value) {
    switch (value) {
      case 'status':
        return 'STATUS';
      case 'motivation':
        return 'MOTIVATION';
      default:
        return 'RANKING';
    }
  }

  String _dateOnly(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  String _timeAgo(String? value) {
    if (value == null || value.isEmpty) return '';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  String _clock(String? value) {
    if (value == null || value.isEmpty) return '—';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
