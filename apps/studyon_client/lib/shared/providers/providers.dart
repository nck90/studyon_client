import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_models/studyon_models.dart';

import '../models/admin_models.dart';
import '../repositories/admin_repository.dart';
import 'app_providers.dart';

export '../models/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    dio: ref.watch(authenticatedApiClientProvider).dio,
  );
});

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) async {
  return ref.watch(adminRepositoryProvider).getDashboard();
});

final adminSeatsProvider = FutureProvider<List<Seat>>((ref) async {
  return ref.watch(adminRepositoryProvider).getSeats();
});

final adminStudentsProvider = FutureProvider<List<Student>>((ref) async {
  return ref.watch(adminRepositoryProvider).getStudents();
});

final studentDetailProvider =
    FutureProvider.family<Student, String>((ref, id) async {
  return ref.watch(adminRepositoryProvider).getStudentDetail(id);
});

final adminStudentDetailProvider =
    FutureProvider.family<AdminStudentDetail, String>((ref, id) async {
  return ref.watch(adminRepositoryProvider).getStudentDetailData(id);
});

final adminRankingsProvider =
    FutureProvider.family<List<RankingItem>, String>((ref, period) async {
  return ref.watch(adminRepositoryProvider).getRankings(period);
});

final adminAttendanceProvider =
    FutureProvider.family<List<AdminAttendanceRecord>, String>((ref, date) async {
  return ref.watch(adminRepositoryProvider).getAttendance(date);
});

final adminAttendanceSummaryProvider =
    FutureProvider.family<AttendanceSummary, ({String mode, String date})>(
        (ref, params) async {
  return ref
      .watch(adminRepositoryProvider)
      .getAttendanceSummary(params.mode, params.date);
});

final studyOverviewProvider =
    FutureProvider.family<StudyOverviewData, String>((ref, period) async {
  return ref.watch(adminRepositoryProvider).getStudyOverview(period);
});

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  return ref.watch(adminRepositoryProvider).getSettings();
});

final adminNotificationsProvider =
    FutureProvider<List<AdminNotification>>((ref) async {
  return ref.watch(adminRepositoryProvider).getNotifications();
});

final tvControlProvider = FutureProvider<TvDisplayData>((ref) async {
  return ref.watch(adminRepositoryProvider).getTvControl();
});

final adminFormOptionsProvider = FutureProvider<AdminFormOptions>((ref) async {
  return ref.watch(adminRepositoryProvider).getFormOptions();
});
