import 'dart:async';

import 'package:dio/dio.dart';

import 'api_client.dart';

/// Firma mínima que el interceptor necesita del repositorio de auth
/// para evitar dependencia circular.
/// Resultado de intentar renovar la sesión.
enum RefreshOutcome {
  /// Hay una pareja nueva de tokens guardada.
  refreshed,

  /// El servidor rechazó el refresh. La sesión ya no sirve.
  invalid,

  /// Red, cupo o una renovación que todavía no terminó. La sesión se conserva.
  unavailable,
}

abstract class AuthRefresher {
  /// Intenta refrescar la sesión con el refresh token almacenado.
  Future<RefreshOutcome> tryRefresh();
  Future<void> logout();
}

typedef OnUnauthorized = void Function();

/// Interceptor: añade Bearer, maneja 401 con refresh, evita stampede.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required ApiClient client,
    required AuthRefresher refresher,
    OnUnauthorized? onUnauthorized,
  })  : _client = client,
        _refresher = refresher,
        _onUnauthorized = onUnauthorized;

  final ApiClient _client;
  final AuthRefresher _refresher;
  final OnUnauthorized? _onUnauthorized;

  bool _refreshing = false;
  final List<Completer<RefreshOutcome>> _waiters = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Rutas públicas (aceptar invitación, crear cuenta): un token viejo en el
    // navegador no debe convertirlas en una sesión caducada.
    if (options.extra['skipAuth'] == true) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }
    // Respeta un Authorization preestablecido por la capa de datos (por
    // ejemplo, un tempToken de TOTP durante login-verify).
    if (options.path.contains('/auth/refresh') ||
        options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }
    final token = await _client.storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    final alreadyRetried = options.extra['retry'] == true;
    // Sin sesión no hay nada que refrescar ni cerrar. Y el propio logout no
    // puede disparar otro logout: un 401 suyo (token ya borrado) provocaba un
    // bucle de POST /auth/logout varias veces por segundo.
    final isAuthCall = options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/login') ||
        options.path.contains('/auth/logout') ||
        // Estos desafíos usan un `tempToken` en Authorization, no la sesión
        // definitiva. Un 401 por código expirado no debe renovar ni cerrar la
        // sesión almacenada (y menos reintentar con el access token nuevo).
        options.path.contains('/auth/totp/login-verify') ||
        options.path.contains('/auth/email/login-verify') ||
        options.path.contains('/auth/email/resend');
    final hadSession = options.headers.containsKey('Authorization');

    if (response.statusCode == 401 &&
        !alreadyRetried &&
        !isAuthCall &&
        options.extra['skipAuth'] != true &&
        options.extra['skipAuthRefresh'] != true &&
        hadSession) {
      final outcome = await _refreshTokenSafely();
      if (outcome == RefreshOutcome.refreshed) {
        final retryOptions = options..extra['retry'] = true;
        final newToken = await _client.storage.readAccessToken();
        if (newToken != null) {
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
        }
        try {
          final retry = await _client.dio.fetch(retryOptions);
          return handler.resolve(retry);
        } catch (_) {
          // Fall-through.
        }
      } else if (outcome == RefreshOutcome.invalid) {
        // Un fallo al borrar la sesión no debe tapar el 401 original ni
        // lanzarse hacia la pantalla como si fuera un error de red.
        try {
          await _refresher.logout();
        } catch (_) {
          // La sesión se considera cerrada de todos modos.
        }
        _onUnauthorized?.call();
      }
    }
    handler.next(response);
  }

  Future<RefreshOutcome> _refreshTokenSafely() async {
    if (_refreshing) {
      final c = Completer<RefreshOutcome>();
      _waiters.add(c);
      return c.future;
    }
    _refreshing = true;
    late final RefreshOutcome outcome;
    try {
      outcome = await _refresher.tryRefresh();
    } catch (_) {
      // Si no pudimos siquiera leer el refresh token (storage bloqueado,
      // clave corrupta, plugin no disponible) no hay forma de recuperar la
      // sesión. Conservarla deja al cliente enviando el mismo token muerto
      // cada 5 segundos: por eso aquí se fuerza logout. Los fallos de red
      // del POST sí se clasifican como `unavailable` dentro de tryRefresh().
      outcome = RefreshOutcome.invalid;
    } finally {
      _refreshing = false;
      // Sin esto, una excepción dejaba a los 401 concurrentes esperando para
      // siempre en sus Completer y la app parecía congelada al reanudar.
      for (final w in _waiters) {
        w.complete(outcome);
      }
      _waiters.clear();
    }
    return outcome;
  }
}
