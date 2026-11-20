import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/network/api_interceptor.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Refresher implements AuthRefresher {
  int refreshes = 0;
  int logouts = 0;

  RefreshOutcome outcome = RefreshOutcome.invalid;
  bool shouldThrow = false;
  bool logoutThrows = false;

  @override
  Future<RefreshOutcome> tryRefresh() async {
    refreshes++;
    if (shouldThrow) throw StateError('almacenamiento seguro bloqueado');
    return outcome;
  }

  @override
  Future<void> logout() async {
    logouts++;
    if (logoutThrows) throw StateError('no se pudo borrar la sesión');
  }
}

Future<void> _respond401(
  AuthInterceptor interceptor,
  String path, {
  bool withToken = true,
}) async {
  final options = RequestOptions(
    path: path,
    headers: withToken ? {'Authorization': 'Bearer t'} : {},
  );
  await interceptor.onResponse(
    Response(requestOptions: options, statusCode: 401),
    ResponseInterceptorHandler(),
  );
}

void main() {
  late _Refresher refresher;
  late AuthInterceptor interceptor;

  setUp(() {
    refresher = _Refresher();
    interceptor = AuthInterceptor(
      client: ApiClient(storage: SecureStorage()),
      refresher: refresher,
    );
  });

  test('un 401 con sesión intenta refrescar y luego cierra sesión', () async {
    await _respond401(interceptor, '/api/fairs/my-assignments');
    expect(refresher.refreshes, 1);
    expect(refresher.logouts, 1);
  });

  test('un 401 de organizaciones con INVALID_TOKEN cierra la sesión', () async {
    await _respond401(
      interceptor,
      '/api/organizations/48b838f6-1c97-4132-827b-5f0056d1430e',
    );
    expect(refresher.refreshes, 1);
    expect(refresher.logouts, 1);
  });

  test('un 401 sin sesión no dispara refresh ni logout', () async {
    await _respond401(interceptor, '/api/projects/mine', withToken: false);
    expect(refresher.refreshes, 0);
    expect(refresher.logouts, 0);
  });

  test('el 401 del propio logout no provoca otro logout (sin bucle)', () async {
    await _respond401(interceptor, '/api/auth/logout');
    expect(refresher.refreshes, 0);
    expect(refresher.logouts, 0);
  });

  test('un fallo de red al renovar no cierra la sesión', () async {
    refresher.outcome = RefreshOutcome.unavailable;
    await _respond401(interceptor, '/api/fairs/my-assignments');
    expect(refresher.refreshes, 1);
    expect(refresher.logouts, 0);
  });

  test('una excepción al renovar no se filtra ni bloquea el siguiente 401',
      () async {
    refresher.shouldThrow = true;
    await _respond401(interceptor, '/api/fairs/my-assignments');
    expect(refresher.refreshes, 1);
    expect(refresher.logouts, 0);

    // Si los waiters no se completaran en el finally, este segundo refresh
    // nunca llegaría a ejecutarse.
    refresher.shouldThrow = false;
    await _respond401(interceptor, '/api/fairs/my-assignments');
    expect(refresher.refreshes, 2);
  });

  test('un fallo al borrar la sesión no lanza hacia la pantalla', () async {
    refresher.logoutThrows = true;
    await _respond401(interceptor, '/api/fairs/my-assignments');
    expect(refresher.refreshes, 1);
    expect(refresher.logouts, 1);
  });
}
