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

  /// Resuelve una URL de media del backend a una URL absoluta.
  ///
  /// El backend puede devolver rutas relativas (`/uploads/avatars/...`) u
  /// URLs absolutas. `Image.network` solo funciona con absolutas.
  static String? mediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final u = url.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return '$apiBaseUrl${u.startsWith('/') ? '' : '/'}$u';
  }
}
