import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_api_client/studyon_api_client.dart';
import 'package:studyon_models/studyon_models.dart';

import 'auth_state.dart';
import 'token_storage.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required this.tokenStorage,
    required this.authApi,
  }) : super(const AuthState());

  final TokenStorage tokenStorage;
  final AuthApi authApi;

  String? get currentAccessToken => state.accessToken;

  Future<void> tryRestore() async {
    final accessToken = await tokenStorage.accessToken;
    if (accessToken == null) {
      state = AuthState.unauthenticated;
      return;
    }
    try {
      final user = await authApi.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: accessToken,
        user: user,
      );
    } catch (_) {
      await _tryRefresh();
    }
  }

  Future<void> loginAsStudent(StudentLoginRequest request) async {
    final response = await authApi.studentLogin(request);
    await tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      sessionId: response.sessionId,
      role: 'student',
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      accessToken: response.accessToken,
      user: UserSummary(
        id: response.user.id,
        role: response.user.role,
        name: response.user.name,
      ),
    );
  }

  Future<void> signupAsStudent(StudentSignupRequest request) async {
    final response = await authApi.studentSignup(request);
    await tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      sessionId: response.sessionId,
      role: 'student',
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      accessToken: response.accessToken,
      user: UserSummary(
        id: response.user.id,
        role: response.user.role,
        name: response.user.name,
      ),
    );
  }

  Future<void> logout() async {
    try {
      final sessionId = await tokenStorage.sessionId;
      final refreshToken = await tokenStorage.refreshToken;
      if (sessionId != null && refreshToken != null) {
        await authApi.logout(
          sessionId: sessionId,
          refreshToken: refreshToken,
        );
      }
    } catch (_) {}
    await tokenStorage.clearAll();
    state = AuthState.unauthenticated;
  }

  Future<String?> refreshAccessToken() async {
    return _tryRefresh();
  }

  Future<String?> _tryRefresh() async {
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken == null) {
      state = AuthState.unauthenticated;
      return null;
    }
    try {
      final tokens = await authApi.refreshToken(refreshToken);
      await tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final user = await authApi.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: tokens.accessToken,
        user: user,
      );
      return tokens.accessToken;
    } catch (_) {
      await tokenStorage.clearAll();
      state = AuthState.unauthenticated;
      return null;
    }
  }
}
