abstract final class ApiConstants {
  static const String apiVersion = 'v1';
  static const String basePath = '/api/v1';

  // Auth
  static const String studentLogin = '/auth/student/login';
  static const String studentQrLogin = '/auth/student/qr-login';
  static const String adminLogin = '/auth/admin/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Student
  static const String studentHome = '/student/home';
  static const String studentAttendanceToday = '/student/attendances/today';
  static const String studentAttendances = '/student/attendances';
  static const String studentCheckIn = '/student/attendances/check-in';
  static const String studentCheckOut = '/student/attendances/check-out';
  static const String studentSeatMy = '/student/seats/my';
  static const String studentSeatMap = '/student/seats/map';
  static const String studentSeatsAvailable = '/student/seats/available';
  static const String studentStudyPlans = '/student/study-plans';
  static const String studentStudySessionActive =
      '/student/study-sessions/active';
  static const String studentStudySessionStart =
      '/student/study-sessions/start';
  static const String studentStudyLogs = '/student/study-logs';
  static const String studentReportsDaily = '/student/reports/daily';
  static const String studentReportsWeekly = '/student/reports/weekly';
  static const String studentReportsMonthly = '/student/reports/monthly';
  static const String studentRankings = '/student/rankings';
  static const String studentBadges = '/student/badges';
  static const String studentProfile = '/student/profile';
  static const String studentNotifications = '/student/notifications';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStudents = '/admin/students';
  static const String adminSeats = '/admin/seats';
  static const String adminAttendances = '/admin/attendances';
  static const String adminAttendanceStats = '/admin/attendance-stats';
  static const String adminStudyOverview = '/admin/study-overview';
  static const String adminRankings = '/admin/rankings';
  static const String adminNotifications = '/admin/notifications';
  static const String adminGrades = '/admin/grades';
  static const String adminClasses = '/admin/classes';
  static const String adminGroups = '/admin/groups';

  // Director
  static const String directorOverview = '/director/overview';
  static const String directorReports = '/director/reports/operations';
  static const String directorAnalytics = '/director/analytics/performance';

  // Display
  static const String displayCurrent = '/display/current';
  static const String displayRankings = '/display/rankings';
  static const String displayStatus = '/display/status';
  static const String displayMotivation = '/display/motivation';
  static const String displayControl = '/display/control';

  // Common
  static const String commonSubjects = '/common/subjects';
  static const String commonCodes = '/common/codes';

  // SSE
  static const String eventsPublic = '/events/public';
  static const String eventsMe = '/events/me';
}
