import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'studyon_access_token';
  static const _refreshTokenKey = 'studyon_refresh_token';
  static const _sessionIdKey = 'studyon_session_id';
  static const _roleKey = 'studyon_role';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? sessionId,
    String? role,
  }) async {
    final values = <String, String>{
      _accessTokenKey: accessToken,
      _refreshTokenKey: refreshToken,
      if (sessionId != null) _sessionIdKey: sessionId,
      if (role != null) _roleKey: role,
    };
    await _runWithFallback(
      secure: () => Future.wait([
        for (final entry in values.entries)
          _storage.write(key: entry.key, value: entry.value),
      ]),
      fallback: () async {
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          for (final entry in values.entries)
            prefs.setString(entry.key, entry.value),
        ]);
      },
    );
  }

  Future<String?> get accessToken => _read(_accessTokenKey);
  Future<String?> get refreshToken => _read(_refreshTokenKey);
  Future<String?> get sessionId => _read(_sessionIdKey);
  Future<String?> get role => _read(_roleKey);

  Future<void> clearAll() async {
    const keys = [
      _accessTokenKey,
      _refreshTokenKey,
      _sessionIdKey,
      _roleKey,
    ];
    await _runWithFallback(
      secure: () => Future.wait([
        for (final key in keys) _storage.delete(key: key),
      ]),
      fallback: () async {
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          for (final key in keys) prefs.remove(key),
        ]);
      },
    );
  }

  Future<String?> _read(String key) {
    return _runWithFallback(
      secure: () => _storage.read(key: key),
      fallback: () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      },
    );
  }

  Future<T> _runWithFallback<T>({
    required Future<T> Function() secure,
    required Future<T> Function() fallback,
  }) async {
    try {
      return await secure();
    } on MissingPluginException {
      return fallback();
    } on PlatformException {
      return fallback();
    }
  }
}
