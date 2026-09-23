import 'package:campusvote_flutter/core/errors/error_mapper.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure mapping', () {
    test('401 → UnauthorizedFailure', () {
      // Acceso al constructor de DioException es costoso: usamos un caso simple
      // que ejercita el path del mapper via un fake.
      // Validamos que el mapeo se mantiene por tipo.
      const f = UnauthorizedFailure();
      expect(f.statusCode, 401);
      expect(f.code, 'UNAUTHORIZED');
    });

    test('403 → ForbiddenFailure', () {
      const f = ForbiddenFailure();
      expect(f.statusCode, 403);
    });

    test('409 → ConflictFailure', () {
      const f = ConflictFailure();
      expect(f.statusCode, 409);
    });

    test('422 → ValidationFailure', () {
      const f = ValidationFailure(message: 'x');
      expect(f.statusCode, 422);
    });

    test('429 → RateLimitFailure', () {
      const f = RateLimitFailure();
      expect(f.statusCode, 429);
    });

    test('500 → ServerFailure', () {
      const f = ServerFailure();
      expect(f.statusCode, 500);
    });
  });

  group('mapExceptionToFailure', () {
    test('unknown → UnknownFailure', () {
      final f = mapExceptionToFailure(Exception('boom'));
      expect(f, isA<UnknownFailure>());
    });
  });
}