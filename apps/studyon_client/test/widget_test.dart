import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_client/main.dart';
import 'package:studyon_client/features/splash/splash_screen.dart';
import 'package:studyon_client/features/login/login_screen.dart';
import 'package:studyon_client/features/onboarding/onboarding_screen.dart';
import 'package:studyon_client/features/student/checkin/checkin_screen.dart';
import 'package:studyon_client/features/student/study_session/study_session_screen.dart';
import 'package:studyon_client/features/student/plan/plan_screen.dart';

/// Wraps a widget in a GoRouter so screens that call context.go() don't crash.
Widget _withRouter(Widget screen) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => screen,
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const Scaffold(body: Text('onboarding')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('login')),
      ),
      GoRoute(
        path: '/student/checkin',
        builder: (context, state) => const Scaffold(body: Text('checkin')),
      ),
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const Scaffold(body: Text('dashboard')),
      ),
      GoRoute(
        path: '/student/study-session',
        builder: (context, state) => const Scaffold(body: Text('study-session')),
      ),
      GoRoute(
        path: '/student/plan',
        builder: (context, state) => const Scaffold(body: Text('plan')),
      ),
      GoRoute(
        path: '/student/summary',
        builder: (context, state) => const Scaffold(body: Text('summary')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('App smoke tests', () {
    testWidgets('App launches without error', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: StudyOnApp()));
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
      // Advance past SplashScreen timer (2200ms) to avoid pending timer error.
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('SplashScreen', () {
    testWidgets('shows app name', (tester) async {
      await tester.pumpWidget(_withRouter(const SplashScreen()));
      await tester.pump();
      expect(find.text('자습ON'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('shows subtitle', (tester) async {
      await tester.pumpWidget(_withRouter(const SplashScreen()));
      await tester.pump();
      expect(find.text('자습실 관리 시스템'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('LoginScreen', () {
    testWidgets('shows login button', (tester) async {
      await tester.pumpWidget(_withRouter(const LoginScreen()));
      await tester.pump();
      expect(find.text('로그인'), findsAtLeast(1));
    });

    testWidgets('has ID and password fields', (tester) async {
      await tester.pumpWidget(_withRouter(const LoginScreen()));
      await tester.pump();
      expect(find.byType(TextField), findsAtLeast(2));
    });
  });

  group('OnboardingScreen', () {
    testWidgets('shows first page', (tester) async {
      await tester.pumpWidget(_withRouter(const OnboardingScreen()));
      await tester.pump();
      expect(find.text('학습 관리'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(_withRouter(const OnboardingScreen()));
      await tester.pump();
      expect(find.text('건너뛰기'), findsOneWidget);
    });
  });

  group('CheckInScreen', () {
    testWidgets('shows check-in button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: _withRouter(const CheckInScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('입실하기'), findsOneWidget);
    });
  });

  group('StudySessionScreen', () {
    testWidgets('shows start button', (tester) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(child: _withRouter(const StudySessionScreen())),
      );
      await tester.pump();
      expect(find.text('시작'), findsOneWidget);
    });
  });

  group('PlanScreen', () {
    testWidgets('shows plan screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: _withRouter(const PlanScreen())),
      );
      await tester.pump();
      // Should show at least one plan item or empty state
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
