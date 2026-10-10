import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/network/api_interceptor.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Refresher implements AuthRefresher {
  int refreshes = 0;
  int logouts = 0;

  @override
  Future<bool> tryRefresh() async {
    refreshes++;
    return false;
  }

  @override
  Future<void> logout() async => logouts++;
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
}
