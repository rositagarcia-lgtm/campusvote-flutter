/// Configuración de entorno de la aplicación.
///
/// Se obtiene por `--dart-define` o `String.fromEnvironment`.
class AppEnv {
  const AppEnv._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://campusvote-rg13.onrender.com',
  );

  static const String envName = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'CampusVote',
  );

  static bool get isProduction => envName == 'production';
  static bool get isDevelopment => envName == 'development';
}
