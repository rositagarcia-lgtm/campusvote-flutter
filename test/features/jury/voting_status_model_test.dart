import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:flutter_test/flutter_test.dart';

VotingStatusModel _status({String? window, bool voted = false}) =>
    VotingStatusModel.fromJson({
      'fair_id': 'f-1',
      'fair_status': 'OPEN',
      'has_voted': voted,
      if (window != null) 'voting_window': window,
      'starts_at': '2026-10-11T03:00:00.000Z',
      'ends_at': '2026-10-11T04:30:00.000Z',
    });

void main() {
  test('solo se puede votar con la ventana del servidor abierta', () {
    expect(_status(window: 'OPEN').canVote, isTrue);
    expect(_status(window: 'NOT_STARTED').canVote, isFalse);
    expect(_status(window: 'ENDED').canVote, isFalse);
    expect(_status(window: 'OPEN', voted: true).canVote, isFalse);
  });

  test('backend anterior sin ventana: decide solo por el estado', () {
    expect(_status().canVote, isTrue);
  });

  test('lee el horario de la feria', () {
    final s = _status(window: 'NOT_STARTED');
    expect(s.notStarted, isTrue);
    expect(s.startsAt!.isAtSameMomentAs(DateTime.utc(2026, 10, 11, 3)), isTrue);
  });
}
