import 'package:flutter_test/flutter_test.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_state.dart';

void main() {
  group('VotingFormState', () {
    const open = VotingStatusModel(
      fairId: 'fair-1',
      fairStatus: FairStatus.open,
      hasVoted: false,
    );

    test('permite votar solo con estado abierto confirmado', () {
      expect(const VotingFormState(status: open).canVote, isTrue);
      expect(
        const VotingFormState(
          status: VotingStatusModel(
            fairId: 'fair-1',
            fairStatus: FairStatus.closed,
            hasVoted: false,
          ),
        ).canVote,
        isFalse,
      );
    });

    test('bloquea el voto mientras se envía o reconcilia el estado', () {
      expect(const VotingFormState(status: open, submitting: true).canVote,
          isFalse);
      expect(
        const VotingFormState(status: open, requiresStatusRefresh: true)
            .canVote,
        isFalse,
      );
    });

    test('no permite emitir otro voto una vez confirmada la participación', () {
      const voted = VotingStatusModel(
        fairId: 'fair-1',
        fairStatus: FairStatus.open,
        hasVoted: true,
      );
      expect(const VotingFormState(status: voted).hasVoted, isTrue);
      expect(const VotingFormState(status: voted).canVote, isFalse);
    });
  });
}
