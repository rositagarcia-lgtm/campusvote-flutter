import 'dart:convert';

import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/network/api_interceptor.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _storageChannel =
    MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

class _FakePersister implements AuthUserPersister {
  @override
  Future<void> persistUser(AuthUser user) async {}

  @override
  Future<AuthUser?> readUser() async => null;

  @override
  Future<void> clearUser() async {}
}

class _EnvelopeAdapter implements HttpClientAdapter {
  const _EnvelopeAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode(body),
        401,
        headers: {'content-type': ['application/json']},
      );

  @override
  void close({bool force = false}) {}
}

class _ThrowingAdapter implements HttpClientAdapter {
  const _ThrowingAdapter(this.error);

  final Object error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      throw error;

  @override
  void close({bool force = false}) {}
}

Future<AuthRepositoryImpl> _repositoryWith(HttpClientAdapter adapter) async {
  final api = ApiClient(storage: SecureStorage());
  api.dio.httpClientAdapter = adapter;
  return AuthRepositoryImpl(client: api, persister: _FakePersister());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_storageChannel, (call) async {
      return switch (call.method) {
        'read' => 'refresh-token',
        _ => null,
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_storageChannel, null);
  });

  test('un refresh rechazado por expiración cierra la sesión', () async {
    final repo = await _repositoryWith(const _EnvelopeAdapter({
      'success': false,
      'error': {
        'code': 'REFRESH_TOKEN_EXPIRED',
        'message': 'El refresh token expiró',
      },
    }));

    expect(await repo.tryRefresh(), RefreshOutcome.invalid);
  });

  test('un refresh token inválido también cierra la sesión', () async {
    final repo = await _repositoryWith(const _EnvelopeAdapter({
      'success': false,
      'error': {
        'code': 'INVALID_REFRESH_TOKEN',
        'message': 'Refresh token inválido',
      },
    }));

    expect(await repo.tryRefresh(), RefreshOutcome.invalid);
  });

  test('INVALID_TOKEN, el código real del backend, cierra la sesión', () async {
    final repo = await _repositoryWith(const _EnvelopeAdapter({
      'success': false,
      'error': {
        'code': 'INVALID_TOKEN',
        'message': 'Known API error',
      },
    }));

    expect(await repo.tryRefresh(), RefreshOutcome.invalid);
  });

  test('un fallo de red al refrescar conserva la sesión', () async {
    final repo = await _repositoryWith(_ThrowingAdapter(DioException(
      requestOptions: RequestOptions(path: '/api/auth/refresh'),
      type: DioExceptionType.connectionError,
    )));

    expect(await repo.tryRefresh(), RefreshOutcome.unavailable);
  });
}
