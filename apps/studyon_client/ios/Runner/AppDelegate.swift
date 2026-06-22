import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "studyon/focus_mode",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "getCapability":
          result([
            "platform": "ios",
            "mode": "SOFT_GUARD",
            "canHardBlock": false,
            "permissionGranted": true,
            "reason": "iOS는 앱 심사 안전을 위해 복귀 알림과 이탈 기록 중심으로 동작해요."
          ])
        case "requestPermission", "startFocus", "stopFocus":
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
