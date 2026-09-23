import 'package:campusvote_flutter/features/voting/data/models/election_model.dart';
import 'package:campusvote_flutter/features/voting/domain/entities/election.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElectionModel.fromJson — contrato backend Prisma camelCase', () {
    test('parsea elección OPEN con organización anidada', () {
      final m = ElectionModel.fromJson({
        'id': 'a1',
        'title': 'Elección X',
        'description': 'desc',
        'processType': 'VOTE',
        'scopeType': 'UNIVERSITY',
        'status': 'OPEN',
        'startAt': '2025-01-01T00:00:00.000Z',
        'endAt': '2025-12-31T00:00:00.000Z',
        'organizationId': 'org-1',
        'organization': {
          'id': 'org-1',
          'name': 'Tecsup',
          'logo': 'https://x/logo.png',
        },
        'isAnonymousAllowed': true,
      });

      expect(m.id, 'a1');
      expect(m.status, 'OPEN');
      expect(m.isOpen, isTrue);
      expect(m.organizationName, 'Tecsup');
      expect(m.organizationLogo, 'https://x/logo.png');
      expect(m.isAnonymousAllowed, isTrue);
    });

    test('tolera snake_case como fallback (schemas Zod de entrada)', () {
      final m = ElectionModel.fromJson({
        'id': 'a2',
        'title': 'E2',
        'process_type': 'VOTE',
        'scope_type': 'FACULTY',
        'status': 'CLOSED',
        'start_at': '2025-01-01T00:00:00.000Z',
        'end_at': '2025-12-31T00:00:00.000Z',
        'organization_id': 'org-2',
        'is_anonymous_allowed': false,
      });

      expect(m.status, 'CLOSED');
      expect(m.isClosed, isTrue);
      expect(m.processType, 'VOTE');
      expect(m.scopeType, 'FACULTY');
      expect(m.organizationId, 'org-2');
    });

    test('election cerrada → isUpcoming false', () {
      final m = ElectionModel.fromJson({
        'id': 'a3',
        'title': 'E3',
        'status': 'CERTIFIED',
        'processType': 'VOTE',
        'scopeType': 'UNIVERSITY',
        'startAt': '2024-01-01T00:00:00Z',
        'endAt': '2024-12-31T00:00:00Z',
        'organizationId': 'org',
      });
      final Election e = m.toEntity();
      expect(e.isClosed, isTrue);
      expect(e.isUpcoming, isFalse);
      expect(e.isOpen, isFalse);
    });
  });
}