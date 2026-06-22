package com.studyon.studyon_client

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "studyon/focus_mode"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCapability" -> result.success(focusCapability())
                "requestPermission" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }
                "startFocus" -> {
                    if (isLockTaskPermitted()) {
                        startLockTask()
                    }
                    result.success(null)
                }
                "stopFocus" -> {
                    stopLockTask()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun focusCapability(): Map<String, Any> {
        val lockTaskPermitted = isLockTaskPermitted()
        return mapOf(
            "platform" to "android",
            "canHardBlock" to lockTaskPermitted,
            "permissionGranted" to lockTaskPermitted,
            "reason" to if (lockTaskPermitted) {
                "Android Lock Task 권한이 있어 강한 차단을 사용할 수 있어요."
            } else {
                "Device Owner/Lock Task 권한이 없어 소프트락으로 동작해요."
            }
        )
    }

    private fun isLockTaskPermitted(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val policyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE ||
            policyManager.isLockTaskPermitted(packageName)
    }
}
