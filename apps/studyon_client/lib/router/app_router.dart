import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/login/login_screen.dart';
import '../features/login/signup_screen.dart';
import '../features/student/checkin/checkin_screen.dart';
import '../features/student/shell/student_shell.dart';
import '../features/student/home/home_screen.dart';
import '../features/student/records/records_screen.dart';
import '../features/student/rankings/rankings_screen.dart';
import '../features/student/profile/profile_screen.dart';
import '../features/student/study_session/study_session_screen.dart';
import '../features/student/study_session/study_summary_screen.dart';
import '../features/student/plan/plan_screen.dart';
import '../features/student/seats/seats_screen.dart';
import '../features/student/notifications/notifications_screen.dart';
import '../features/student/points/points_screen.dart';
import '../features/student/character/character_screen.dart';
import '../features/admin/shell/admin_shell.dart';
import '../features/admin/dashboard/dashboard_screen.dart';
import '../features/admin/seats/seats_screen.dart';
import '../features/admin/students/students_screen.dart';
import '../features/admin/students/student_detail_screen.dart';
import '../features/admin/students/student_form_screen.dart';
import '../features/admin/rankings/admin_rankings_screen.dart';
import '../features/admin/study_overview/study_overview_screen.dart';
import '../features/admin/settings/settings_screen.dart';
import '../features/admin/attendance/admin_attendance_screen.dart';
import '../features/admin/notifications/notifications_screen.dart';
import '../features/admin/tv_control/tv_control_screen.dart';

// Instant transition - no animation
CustomTransitionPage<void> _noTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    transitionDuration: Duration.zero,
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', pageBuilder: (context, state) => _noTransition(const SplashScreen(), state)),
    GoRoute(path: '/onboarding', pageBuilder: (context, state) => _noTransition(const OnboardingScreen(), state)),
    GoRoute(path: '/login', pageBuilder: (context, state) => _noTransition(const LoginScreen(), state)),
    GoRoute(path: '/signup', pageBuilder: (context, state) => _noTransition(const SignupScreen(), state)),
    GoRoute(path: '/student/checkin', pageBuilder: (context, state) => _noTransition(const CheckInScreen(), state)),

    // ── Student ──
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(path: '/student/home', pageBuilder: (context, state) => _noTransition(const HomeScreen(), state)),
        GoRoute(path: '/student/records', pageBuilder: (context, state) => _noTransition(const RecordsScreen(), state)),
        GoRoute(path: '/student/rankings', pageBuilder: (context, state) => _noTransition(const RankingsScreen(), state)),
        GoRoute(path: '/student/profile', pageBuilder: (context, state) => _noTransition(const ProfileScreen(), state)),
      ],
    ),
    GoRoute(path: '/student/study-session', pageBuilder: (context, state) => _noTransition(const StudySessionScreen(), state)),
    GoRoute(path: '/student/summary', pageBuilder: (context, state) => _noTransition(const StudySummaryScreen(), state)),
    GoRoute(path: '/student/plan', pageBuilder: (context, state) => _noTransition(const PlanScreen(), state)),
    GoRoute(path: '/student/seats', pageBuilder: (context, state) => _noTransition(const StudentSeatsScreen(), state)),
    GoRoute(path: '/student/notifications', pageBuilder: (context, state) => _noTransition(const StudentNotificationsScreen(), state)),
    GoRoute(path: '/student/points', pageBuilder: (context, state) => _noTransition(const PointsScreen(), state)),
    GoRoute(path: '/student/character', pageBuilder: (context, state) => _noTransition(const CharacterScreen(), state)),

    // ── Admin ──
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(path: '/admin/dashboard', pageBuilder: (context, state) => _noTransition(const DashboardScreen(), state)),
        GoRoute(path: '/admin/seats', pageBuilder: (context, state) => _noTransition(const SeatsScreen(), state)),
        GoRoute(path: '/admin/students', pageBuilder: (context, state) => _noTransition(const StudentsScreen(), state)),
        GoRoute(
          path: '/admin/students/:id',
          pageBuilder: (context, state) => _noTransition(
            StudentDetailScreen(studentId: state.pathParameters['id']!), state,
          ),
        ),
        GoRoute(path: '/admin/students/new', pageBuilder: (context, state) => _noTransition(const StudentFormScreen(), state)),
        GoRoute(
          path: '/admin/students/:id/edit',
          pageBuilder: (context, state) => _noTransition(
            StudentFormScreen(studentId: state.pathParameters['id']!), state,
          ),
        ),
        GoRoute(path: '/admin/rankings', pageBuilder: (context, state) => _noTransition(const AdminRankingsScreen(), state)),
        GoRoute(path: '/admin/study-overview', pageBuilder: (context, state) => _noTransition(const StudyOverviewScreen(), state)),
        GoRoute(path: '/admin/attendance', pageBuilder: (context, state) => _noTransition(const AdminAttendanceScreen(), state)),
        GoRoute(path: '/admin/notifications', pageBuilder: (context, state) => _noTransition(const NotificationsScreen(), state)),
        GoRoute(path: '/admin/tv', pageBuilder: (context, state) => _noTransition(const TvControlScreen(), state)),
        GoRoute(path: '/admin/settings', pageBuilder: (context, state) => _noTransition(const SettingsScreen(), state)),
      ],
    ),
  ],
);
