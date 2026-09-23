import 'dart:async';

import 'package:dio/dio.dart';

import 'api_client.dart';

/// Firma mínima que el interceptor necesita del repositorio de auth
/// para evitar dependencia circular.
abstract class AuthRefresher {
  /// Intenta refrescar la sesión con el refresh token almacenado.
  /// Devuelve `true` si el refresh fue exitoso y `false` si no.
  Future<bool> tryRefresh();
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
  final List<Completer<bool>> _waiters = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Respeta un Authorization preestablecido por la capa de datos (por
    // ejemplo, un tempToken de TOTP durante login-verify).
    if (options.headers.containsKey('Authorization')) {
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
    final isRefreshCall = options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/login');

    if (response.statusCode == 401 && !alreadyRetried && !isRefreshCall) {
      final ok = await _refreshTokenSafely();
      if (ok) {
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
      } else {
        await _refresher.logout();
        _onUnauthorized?.call();
      }
    }
    handler.next(response);
  }

  Future<bool> _refreshTokenSafely() async {
    if (_refreshing) {
      final c = Completer<bool>();
      _waiters.add(c);
      return c.future;
    }
    _refreshing = true;
    bool success;
    try {
      success = await _refresher.tryRefresh();
    } finally {
      _refreshing = false;
    }
    for (final w in _waiters) {
      w.complete(success);
    }
    _waiters.clear();
    return success;
  }
}