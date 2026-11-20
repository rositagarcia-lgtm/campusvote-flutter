import 'dart:convert';
import 'dart:typed_data';

import 'package:campusvote_flutter/core/branding/organization_branding_repository.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Envelope401Adapter implements HttpClientAdapter {
  const _Envelope401Adapter(this.body);

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

void main() {
  test('un 401 INVALID_TOKEN al cargar branding se clasifica como sesión muerta',
      () async {
    final api = ApiClient(storage: SecureStorage());
    api.dio.httpClientAdapter = const _Envelope401Adapter({
      'success': false,
      'error': {
        'code': 'INVALID_TOKEN',
        'message': 'Known API error',
      },
    });
    final repository = OrganizationBrandingRepository(api);

    final result = await repository.fetch('org-1');

    final failure = result.failureOrNull;
    expect(failure, isA<UnauthorizedFailure>());
    expect(failure?.code, 'INVALID_TOKEN');
  });
}
