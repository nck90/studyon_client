import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_api_client/studyon_api_client.dart';
import 'package:studyon_auth/studyon_auth.dart';
import 'package:studyon_core/studyon_core.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final unauthenticatedApiClientProvider = Provider<StudyonApiClient>((ref) {
  return StudyonApiClient(
    baseUrl: AppEnv.apiBaseUrl,
  )..setDeviceCode(AppEnv.deviceCode);
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(unauthenticatedApiClientProvider).dio);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    tokenStorage: ref.watch(tokenStorageProvider),
    authApi: ref.watch(authApiProvider),
  );
});

final authenticatedApiClientProvider = Provider<StudyonApiClient>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);
  return StudyonApiClient(
    baseUrl: AppEnv.apiBaseUrl,
    tokenReader: () => authNotifier.currentAccessToken,
    tokenRefresher: authNotifier.refreshAccessToken,
    onUnauthorized: () {
      ref.read(authNotifierProvider.notifier).logout();
    },
  )..setDeviceCode(AppEnv.deviceCode);
});

final studentApiProvider = Provider<StudentApi>((ref) {
  return StudentApi(ref.watch(authenticatedApiClientProvider).dio);
});

final adminApiProvider = Provider<AdminApi>((ref) {
  return AdminApi(ref.watch(authenticatedApiClientProvider).dio);
});
