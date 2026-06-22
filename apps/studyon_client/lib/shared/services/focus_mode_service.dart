import 'package:flutter/services.dart';

class FocusModeCapability {
  const FocusModeCapability({
    required this.platform,
    required this.mode,
    required this.canHardBlock,
    required this.permissionGranted,
    required this.reason,
  });

  final String platform;
  final String mode;
  final bool canHardBlock;
  final bool permissionGranted;
  final String reason;

  factory FocusModeCapability.fromMap(Map<dynamic, dynamic> map) {
    return FocusModeCapability(
      platform: map['platform']?.toString() ?? 'unknown',
      mode: map['mode']?.toString() ?? 'SOFT_GUARD',
      canHardBlock: map['canHardBlock'] == true,
      permissionGranted: map['permissionGranted'] == true,
      reason: map['reason']?.toString() ?? '',
    );
  }
}

class FocusModeService {
  static const _channel = MethodChannel('studyon/focus_mode');

  Future<FocusModeCapability> getCapability() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getCapability',
      );
      return FocusModeCapability.fromMap(result ?? const {});
    } on MissingPluginException {
      return const FocusModeCapability(
        platform: 'unsupported',
        mode: 'SOFT_GUARD',
        canHardBlock: false,
        permissionGranted: false,
        reason: '이 기기에서는 집중모드 차단을 지원하지 않아요.',
      );
    }
  }

  Future<void> requestPermission() {
    return _channel.invokeMethod<void>('requestPermission');
  }

  Future<void> startFocus() {
    return _channel.invokeMethod<void>('startFocus');
  }

  Future<void> stopFocus() {
    return _channel.invokeMethod<void>('stopFocus');
  }
}
