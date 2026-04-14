import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'router/app_router.dart';
import 'shared/providers/student_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: StudyOnApp()));
}

class StudyOnApp extends ConsumerWidget {
  const StudyOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(studentProvider).isDarkMode;
    return MaterialApp.router(
      title: '자습ON',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.dark : AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
