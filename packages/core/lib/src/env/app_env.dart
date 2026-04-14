enum AppEnvironment { dev, staging, prod }

class AppEnv {
  const AppEnv._();

  static late String apiBaseUrl;
  static late AppEnvironment environment;
  static late bool enableLogging;
  static String? deviceCode;

  static void init({
    required String apiBaseUrl,
    required AppEnvironment environment,
    bool enableLogging = true,
    String? deviceCode,
  }) {
    AppEnv.apiBaseUrl = apiBaseUrl;
    AppEnv.environment = environment;
    AppEnv.enableLogging = enableLogging;
    AppEnv.deviceCode = deviceCode;
  }

  static bool get isDev => environment == AppEnvironment.dev;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProd => environment == AppEnvironment.prod;
}
