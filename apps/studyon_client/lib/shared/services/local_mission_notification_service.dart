import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../router/app_router.dart';

class LocalMissionNotificationService {
  LocalMissionNotificationService._();

  static final instance = LocalMissionNotificationService._();
  static const _dailyMissionNotificationId = 2100;
  static const _focusReturnNotificationId = 2101;
  static const _payload = 'daily_mission';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool openedFromNotification = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    await _setLocalTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse?.payload == _payload) {
      openedFromNotification = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openDailyMission());
    }
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    return androidGranted && iosGranted;
  }

  Future<void> scheduleDailyMission({
    required bool enabled,
    required String reminderTime,
    String title = '오늘 미션',
    String body = '오늘 미션을 확인하고 공부 루틴을 이어가세요.',
  }) async {
    await initialize();
    await _plugin.cancel(id: _dailyMissionNotificationId);
    if (!enabled) return;
    final granted = await requestPermission();
    if (!granted) return;
    final scheduledAt = _nextTime(reminderTime);
    await _plugin.zonedSchedule(
      id: _dailyMissionNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledAt,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_mission',
          '오늘 미션',
          channelDescription: '매일 오늘 미션 확인 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payload,
    );
  }

  Future<void> cancelDailyMission() {
    return _plugin.cancel(id: _dailyMissionNotificationId);
  }

  Future<void> showFocusReturnReminder() async {
    await initialize();
    final granted = await requestPermission();
    if (!granted) return;
    await _plugin.show(
      id: _focusReturnNotificationId,
      title: '집중 시간이 진행 중이에요',
      body: '다른 앱은 잠시 내려두고 자습ON으로 돌아와 주세요.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_return',
          '집중 복귀 알림',
          channelDescription: '집중모드 중 앱을 벗어났을 때 복귀를 돕는 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelFocusReturnReminder() {
    return _plugin.cancel(id: _focusReturnNotificationId);
  }

  void consumeNotificationOpenFlag() {
    openedFromNotification = false;
  }

  Future<void> _setLocalTimezone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime _nextTime(String reminderTime) {
    final parts = reminderTime.split(':');
    final hour = int.tryParse(parts.first) ?? 20;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != _payload) return;
    openedFromNotification = true;
    _openDailyMission();
  }

  void _openDailyMission() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    context.push('/student/daily-mission');
  }
}
