import 'package:studyon_models/studyon_models.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.accessToken,
    this.user,
  });

  final AuthStatus status;
  final String? accessToken;
  final UserSummary? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    UserSummary? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
    );
  }

  static const initial = AuthState();

  static const unauthenticated =
      AuthState(status: AuthStatus.unauthenticated);
}
