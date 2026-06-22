import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_client/features/login/login_screen.dart';
import 'package:studyon_client/features/onboarding/onboarding_screen.dart';
import 'package:studyon_client/features/splash/splash_screen.dart';
import 'package:studyon_client/features/student/home/home_screen.dart';
import 'package:studyon_client/features/student/plan/plan_screen.dart';
import 'package:studyon_client/features/student/study_session/study_session_screen.dart';
import 'package:studyon_client/features/student/weekly_review/weekly_review_screen.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_client/main.dart';
import 'package:studyon_core/studyon_core.dart';

Widget _withRouter(Widget screen) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => screen),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const Scaffold(body: Text('onboarding')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('login')),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const Scaffold(body: Text('signup')),
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
        path: '/student/profile',
        builder: (context, state) => const Scaffold(body: Text('profile')),
      ),
      GoRoute(
        path: '/student/motivation-settings',
        builder: (context, state) => const Scaffold(body: Text('motivation')),
      ),
      GoRoute(
        path: '/student/notifications',
        builder: (context, state) =>
            const Scaffold(body: Text('notifications')),
      ),
      GoRoute(
        path: '/student/study-session',
        builder: (context, state) =>
            const Scaffold(body: Text('study-session')),
      ),
      GoRoute(
        path: '/student/plan',
        builder: (context, state) => const Scaffold(body: Text('plan')),
      ),
      GoRoute(
        path: '/student/summary',
        builder: (context, state) => const Scaffold(body: Text('summary')),
      ),
      GoRoute(
        path: '/student/weekly-review',
        builder: (context, state) =>
            const Scaffold(body: Text('weekly-review')),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const Scaffold(body: Text('dashboard')),
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
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

    testWidgets('LoginScreen shows login and signup entry points', (
      tester,
    ) async {
      await tester.pumpWidget(_withRouter(const LoginScreen()));
      await tester.pump();
      expect(find.text('로그인'), findsAtLeast(1));
      expect(find.text('처음이면 회원가입'), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders first page', (tester) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_withRouter(const OnboardingScreen()));
      await tester.pump();
      expect(find.text('학습 시간 관리'), findsOneWidget);
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
      expect(find.text('학습 계획'), findsOneWidget);
    });

    testWidgets('WeeklyReviewScreen renders summary', (tester) async {
      await tester.pumpWidget(_withRouter(const WeeklyReviewScreen()));
      await tester.pump();
      expect(find.text('주간 회고'), findsOneWidget);
      expect(find.text('다음 주 추천'), findsOneWidget);
    });
  });

  group('Student motivation home', () {
    testWidgets('shows empty target and focus setup states', (tester) async {
      tester.view.physicalSize = const Size(1194, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _withRouter(
          StudentHomeContent(
            student: const StudentState(),
            seatMapFuture: Future.value(const []),
            rpgDashboard: const AsyncData(<String, dynamic>{
              'title': '성장 퀘스트',
              'character': {'stageAssetKey': 'stage_01', 'level': 1},
              'points': 0,
              'streakDays': 0,
            }),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('목표 대학을 설정해 보세요'), findsOneWidget);
      expect(find.text('오늘 목표가 비어 있어요'), findsOneWidget);
      expect(find.text('성장 퀘스트'), findsOneWidget);
      expect(find.text('첫 배지를 향해 시작해요'), findsOneWidget);
      expect(find.text('집중모드 꺼짐'), findsOneWidget);
    });

    testWidgets('shows target, completed goal, weekly chart, and badges', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1194, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      await tester.pumpWidget(
        _withRouter(
          StudentHomeContent(
            student: StudentState(
              name: '정상민',
              targetUniversityName: '서울대학교',
              goalSubject: '수학',
              goalDetail: '미적분 오답 정리',
              goalProgress: 1,
              focusModeEnabled: true,
              badges: const [
                StudentBadgeItem(
                  code: 'GOAL_ACHIEVER',
                  name: '목표 달성',
                  description: '하루 계획 달성률 100% 달성',
                ),
              ],
              recentRecords: [
                StudyRecord(
                  date: '${now.month}월 ${now.day}일',
                  isoDate: now.toIso8601String(),
                  subject: '수학',
                  studyMinutes: 120,
                  studySeconds: 7200,
                  goalAchieved: true,
                  goalDetail: '미적분',
                ),
                StudyRecord(
                  date: '${yesterday.month}월 ${yesterday.day}일',
                  isoDate: yesterday.toIso8601String(),
                  subject: '수학',
                  studyMinutes: 60,
                  studySeconds: 3600,
                  goalAchieved: true,
                  goalDetail: '확률',
                ),
              ],
            ),
            seatMapFuture: Future.value(const [
              {'uiStatus': 'studying'},
              {'uiStatus': 'empty'},
            ]),
            rpgDashboard: const AsyncData(<String, dynamic>{
              'title': '성장 퀘스트',
              'character': {'stageAssetKey': 'stage_03', 'level': 6},
              'points': 320,
              'streakDays': 4,
            }),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('서울대학교'), findsOneWidget);
      expect(find.text('목표 달성 완료'), findsOneWidget);
      expect(find.text('3.0h'), findsOneWidget);
      expect(find.text('목표 달성'), findsWidgets);
      expect(find.text('집중모드 준비됨'), findsOneWidget);
    });
  });
}
