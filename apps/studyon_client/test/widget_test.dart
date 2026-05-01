import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_client/features/login/login_screen.dart';
import 'package:studyon_client/features/onboarding/onboarding_screen.dart';
import 'package:studyon_client/features/splash/splash_screen.dart';
import 'package:studyon_client/features/student/plan/plan_screen.dart';
import 'package:studyon_client/features/student/study_session/study_session_screen.dart';
import 'package:studyon_client/main.dart';
import 'package:studyon_core/studyon_core.dart';

Widget _withRouter(Widget screen) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => screen),
      GoRoute(path: '/onboarding', builder: (context, state) => const Scaffold(body: Text('onboarding'))),
      GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('login'))),
      GoRoute(path: '/signup', builder: (context, state) => const Scaffold(body: Text('signup'))),
      GoRoute(path: '/student/checkin', builder: (context, state) => const Scaffold(body: Text('checkin'))),
      GoRoute(path: '/student/home', builder: (context, state) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/student/summary', builder: (context, state) => const Scaffold(body: Text('summary'))),
      GoRoute(path: '/admin/dashboard', builder: (context, state) => const Scaffold(body: Text('dashboard'))),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppEnv.init(
    apiBaseUrl: 'http://127.0.0.1:3000',
    environment: AppEnvironment.dev,
    enableLogging: false,
    deviceCode: 'test-device',
  );

  group('App smoke tests', () {
    testWidgets('app launches', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: StudyOnApp()));
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Screen smoke tests', () {
    testWidgets('SplashScreen shows app title', (tester) async {
      await tester.pumpWidget(_withRouter(const SplashScreen()));
      await tester.pump();
      expect(find.text('자습ON'), findsOneWidget);
    });

    testWidgets('LoginScreen shows login and signup entry points', (tester) async {
      await tester.pumpWidget(_withRouter(const LoginScreen()));
      await tester.pump();
      expect(find.text('로그인'), findsAtLeast(1));
      expect(find.text('처음이면 회원가입'), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders first page', (tester) async {
      await tester.pumpWidget(_withRouter(const OnboardingScreen()));
      await tester.pump();
      expect(find.text('학습 관리'), findsOneWidget);
      expect(find.text('건너뛰기'), findsOneWidget);
    });

    testWidgets('StudySessionScreen renders start action', (tester) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_withRouter(const StudySessionScreen()));
      await tester.pump();
      expect(find.text('시작'), findsOneWidget);
    });

    testWidgets('PlanScreen renders title', (tester) async {
      await tester.pumpWidget(_withRouter(const PlanScreen()));
      await tester.pump();
      expect(find.text('오늘의 학습 계획'), findsOneWidget);
    });
  });
}
