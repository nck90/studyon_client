import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_core/studyon_core.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'router/app_router.dart';
import 'capture/capture_showcase_app.dart';
import 'shared/providers/student_providers.dart';
import 'shared/services/local_mission_notification_service.dart';

String _resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (override.isNotEmpty) {
    return override;
  }

  const productionApi = 'https://studyon-server.hyphen.it.com';

  if (kIsWeb) {
    return productionApi;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return productionApi;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const captureMode = bool.fromEnvironment('DEMO_CAPTURE');
  if (captureMode) {
    runApp(const CaptureShowcaseApp());
    return;
  }
  const environmentValue = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  const loggingValue = String.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: 'true',
  );
  AppEnv.init(
    apiBaseUrl: _resolveApiBaseUrl(),
    environment: switch (environmentValue) {
      'prod' => AppEnvironment.prod,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    },
    enableLogging: loggingValue.toLowerCase() == 'true',
    deviceCode: const String.fromEnvironment(
      'DEVICE_CODE',
      defaultValue: 'studyon_client',
    ),
  );
  await LocalMissionNotificationService.instance.initialize();
  runApp(const ProviderScope(child: StudyOnApp()));
}

class StudyOnApp extends ConsumerWidget {
  const StudyOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    return MaterialApp.router(
      title: '자습ON',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.byPreset(
        preset: student.themePreset,
        darkMode: student.isDarkMode,
      ),
      routerConfig: appRouter,
    );
  }
}
