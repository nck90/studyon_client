import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (sessionId != null)
        _storage.write(key: _sessionIdKey, value: sessionId),
      if (role != null) _storage.write(key: _roleKey, value: role),
    ]);
  }

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);
  Future<String?> get sessionId => _storage.read(key: _sessionIdKey);
  Future<String?> get role => _storage.read(key: _roleKey);

  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _sessionIdKey),
      _storage.delete(key: _roleKey),
    ]);
  }
}
