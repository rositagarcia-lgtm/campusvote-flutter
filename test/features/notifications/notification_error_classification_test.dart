import 'dart:typed_data';

import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/features/notifications/notifications_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  const _StubAdapter(this.error);

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

class _FakeRef implements Ref {
  const _FakeRef(this.api);

  final ApiClient api;

  @override
  T read<T>(ProviderListenable<T> provider) => api as T;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Ref.noSuchMethod: ${invocation.memberName}');
}

Future<NotificationsController> _controllerWith(Object error) async {
  final api = ApiClient(storage: SecureStorage());
  api.dio.httpClientAdapter = _StubAdapter(error);
  final controller = NotificationsController(_FakeRef(api));
  await controller.load();
  return controller;
}

DioException _dioException(
  DioExceptionType type, {
  int? statusCode,
}) {
  final options = RequestOptions(path: '/api/notifications');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  test('un 401 al reanudar se describe como sesión vencida, no como red',
      () async {
    final controller = await _controllerWith(
      _dioException(DioExceptionType.badResponse, statusCode: 401),
    );

    expect(
      controller.state.error,
      'Tu sesión venció. Inicia sesión nuevamente.',
    );
    expect(controller.state.error, isNot(contains('conexión')));
  });

  test('un timeout conserva su mensaje de lentitud', () async {
    final controller = await _controllerWith(
      _dioException(DioExceptionType.receiveTimeout),
    );

    expect(
      controller.state.error,
      'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.',
    );
  });

  test('solo un fallo real de transporte sugiere revisar la conexión',
      () async {
    final controller = await _controllerWith(
      _dioException(DioExceptionType.connectionError),
    );

    expect(
      controller.state.error,
      'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
    );
  });

  test('una respuesta inesperada no se culpa a la conexión', () async {
    final controller = await _controllerWith(
      const FormatException('Respuesta de notificaciones inválida'),
    );

    expect(
      controller.state.error,
      'No se pudo completar la operación. Inténtalo de nuevo.',
    );
    expect(controller.state.error, isNot(contains('conexión')));
  });
}
