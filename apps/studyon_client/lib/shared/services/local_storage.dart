import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyDarkMode = 'dark_mode';
  static const _keyLastLoginId = 'last_login_id';

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  static Future<String?> getLastLoginId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastLoginId);
  }

  static Future<void> setLastLoginId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLoginId, id);
  }
}
