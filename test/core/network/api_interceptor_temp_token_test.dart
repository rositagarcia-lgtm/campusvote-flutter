import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/network/api_interceptor.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Refresher implements AuthRefresher {
  int refreshes = 0;
  int logouts = 0;

  @override
  Future<RefreshOutcome> tryRefresh() async {
    refreshes++;
    return RefreshOutcome.refreshed;
  }

  @override
  Future<void> logout() async {
    logouts++;
  }
}

void main() {
  for (final path in [
    '/api/auth/totp/login-verify',
    '/api/auth/email/login-verify',
    '/api/auth/email/resend',
  ]) {
    test('un 401 de $path no toca la sesión definitiva', () async {
      final refresher = _Refresher();
      final interceptor = AuthInterceptor(
        client: ApiClient(storage: SecureStorage()),
        refresher: refresher,
      );
      final options = RequestOptions(
        path: path,
        headers: {'Authorization': 'Bearer temp-token'},
      );

      await interceptor.onResponse(
        Response(requestOptions: options, statusCode: 401),
        ResponseInterceptorHandler(),
      );

      expect(refresher.refreshes, 0);
      expect(refresher.logouts, 0);
    });
  }

  test('un 401 con skipAuthRefresh no reintenta ni cierra sesión', () async {
    final refresher = _Refresher();
    final interceptor = AuthInterceptor(
      client: ApiClient(storage: SecureStorage()),
      refresher: refresher,
    );
    final options = RequestOptions(
      path: '/api/notifications/devices/on-logout',
      headers: {'Authorization': 'Bearer expired-token'},
      extra: const {'skipAuthRefresh': true},
    );

    await interceptor.onResponse(
      Response(requestOptions: options, statusCode: 401),
      ResponseInterceptorHandler(),
    );

    expect(refresher.refreshes, 0);
    expect(refresher.logouts, 0);
    expect(options.headers['Authorization'], 'Bearer expired-token');
  });
}
