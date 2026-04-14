abstract final class AppConstants {
  static const String appName = 'STUDYON';

  // Session
  static const Duration autoLogoutDuration = Duration(minutes: 30);
  static const Duration tokenRefreshBuffer = Duration(minutes: 1);

  // Pagination
  static const int defaultPageSize = 20;

  // Timer
  static const Duration timerTickInterval = Duration(seconds: 1);

  // Attendance
  static const Duration inactivityThreshold = Duration(minutes: 30);
}
