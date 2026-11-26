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

  test('antes de que empiece la feria no se muestra un conflicto genérico', () {
    const early = JuryApiException(
      'Las evaluaciones empiezan cuando inicia la feria',
      statusCode: 409,
      code: 'CONFLICT',
    );

    expect(
      describeJuryError(early),
      'Aún no es el momento. Espera a que la feria empiece.',
    );
  });

  test('RUBRICS_INCOMPLETE conserva el mensaje claro del backend', () {
    const incomplete = JuryApiException(
      'No puedes emitir tu voto oficial. Te faltan 2 rúbrica(s) por finalizar en esta categoría.',
      statusCode: 409,
      code: 'RUBRICS_INCOMPLETE',
    );

    expect(
      describeJuryError(incomplete),
      'No puedes emitir tu voto oficial. Te faltan 2 rúbrica(s) por finalizar en esta categoría.',
    );
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

  test('un timeout no se describe como falta de conexión', () {
    const timeout = JuryApiException(
      'Error de red',
      statusCode: null,
      code: 'receivetimeout',
    );

    expect(describeJuryError(timeout), contains('tardó demasiado'));
    expect(describeJuryError(timeout), isNot(contains('Revisa tu conexión')));
  });

  test('un error de transporte desconocido no inventa una causa de red', () {
    const unknown = JuryApiException('Algo falló', statusCode: null);

    expect(
      describeJuryError(unknown),
      'No se pudo completar la operación. Inténtalo de nuevo.',
    );
  });

  test('un fallo real de conexión conserva su mensaje', () {
    const offline = JuryApiException(
      'Sin conexión con el servidor',
      statusCode: null,
      code: 'connectionerror',
    );

    expect(
      describeJuryError(offline),
      'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
    );
  });
}
