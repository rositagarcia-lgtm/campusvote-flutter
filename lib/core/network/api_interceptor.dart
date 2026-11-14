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
        options.path.contains('/auth/logout');
    final hadSession = options.headers.containsKey('Authorization');

    if (response.statusCode == 401 &&
        !alreadyRetried &&
        !isAuthCall &&
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
        await _refresher.logout();
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
    RefreshOutcome outcome;
    try {
      outcome = await _refresher.tryRefresh();
    } finally {
      _refreshing = false;
    }
    for (final w in _waiters) {
      w.complete(outcome);
    }
    _waiters.clear();
    return outcome;
  }
}
