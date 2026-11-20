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

    const completedProgress = CategoryRubricProgress(
      categoryId: 'cat-1',
      totalProjects: 2,
      completedRubrics: 2,
      pendingRubricProjectIds: [],
    );

    const baseState = VotingFormState(
      status: open,
      evaluationsLoading: false,
      categoryProgress: {'cat-1': completedProgress},
      activeCategoryId: 'cat-1',
    );

    test('permite votar solo con estado abierto confirmado y rúbricas completadas', () {
      expect(baseState.canVote, isTrue);
      expect(
        baseState.copyWith(
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
      expect(baseState.copyWith(submitting: true).canVote, isFalse);
      expect(
        baseState.copyWith(requiresStatusRefresh: true).canVote,
        isFalse,
      );
    });

    test('bloquea el voto mientras se cargan evaluaciones', () {
      expect(baseState.copyWith(evaluationsLoading: true).canVote, isFalse);
    });

    test('bloquea el voto si faltan rúbricas por completar', () {
      const pendingProgress = CategoryRubricProgress(
        categoryId: 'cat-1',
        totalProjects: 2,
        completedRubrics: 1,
        pendingRubricProjectIds: ['proj-2'],
      );
      expect(
        baseState.copyWith(categoryProgress: {'cat-1': pendingProgress}).canVote,
        isFalse,
      );
    });

    test('no permite emitir otro voto una vez confirmada la participación', () {
      const voted = VotingStatusModel(
        fairId: 'fair-1',
        fairStatus: FairStatus.open,
        hasVoted: true,
      );
      expect(baseState.copyWith(status: voted).hasVoted, isTrue);
      expect(baseState.copyWith(status: voted).canVote, isFalse);
    });

    test('bloquea el voto si hay receipt', () {
      expect(
        baseState.copyWith(receipt: const VoteReceiptModel(status: 'CAST', receiptCode: 'ABC')).canVote,
        isFalse,
      );
    });
  });
}