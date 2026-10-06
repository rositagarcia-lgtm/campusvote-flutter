import 'package:campusvote_flutter/features/jury/data/datasources/jury_remote_datasource.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los errores del API se presentan sin exponer su mensaje interno', () {
    const internalError = JuryApiException(
      'Prisma TypeError at /api/fairs/vote: duplicate constraint',
      statusCode: 409,
      code: 'INTERNAL_DUPLICATE_VOTE',
    );

    final message = describeJuryError(internalError);

    expect(message, contains('esta acción ya se registró'));
    expect(message, isNot(contains('Prisma')));
    expect(message, isNot(contains('/api/')));
    expect(message, isNot(contains('INTERNAL_DUPLICATE_VOTE')));
  });

  test('errores de autorización no revelan el código de respuesta', () {
    const forbidden = JuryApiException(
      'Role JURY is forbidden on this endpoint',
      statusCode: 403,
      code: 'FORBIDDEN',
    );

    expect(
      describeJuryError(forbidden),
      'No tienes permisos para realizar esta acción.',
    );
  });
}
