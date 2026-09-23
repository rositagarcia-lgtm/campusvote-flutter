import 'package:campusvote_flutter/features/voting/data/models/voting_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VotingSessionModel.fromJson — start (camelCase del service)', () {
    test('parsea respuesta de POST /api/voting/elections/:id/sessions', () {
      final m = VotingSessionModel.fromJson({
        'sessionId': 'sess-1',
        'electionId': 'e1',
        'status': 'STARTED',
        'message': 'ok',
      });
      expect(m.sessionId, 'sess-1');
      expect(m.electionId, 'e1');
      expect(m.status, 'STARTED');
      expect(m.isActive, isTrue);
    });
  });

  group('VotingSessionModel.fromJson — get status (Prisma)', () {
    test('deriva status desde completedAt + isSuccessful', () {
      final m = VotingSessionModel.fromJson({
        'id': 'sess-2',
        'electionId': 'e1',
        'voterId': 'u1',
        'startedAt': '2025-01-01T00:00:00Z',
        'completedAt': '2025-01-01T00:01:00Z',
        'isSuccessful': true,
      });
      expect(m.sessionId, 'sess-2');
      expect(m.status, 'CAST');
      expect(m.isCast, isTrue);
    });

    test('sin completedAt → status STARTED', () {
      final m = VotingSessionModel.fromJson({
        'id': 'sess-3',
        'electionId': 'e1',
        'startedAt': '2025-01-01T00:00:00Z',
      });
      expect(m.status, 'STARTED');
      expect(m.isActive, isTrue);
    });
  });
}