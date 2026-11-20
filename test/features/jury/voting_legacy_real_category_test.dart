import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/voting/voting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LegacyRealCategoryRepo implements JuryRepository {
  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async =>
      VotingStatusModel.fromJson({
        'fair_id': fairId,
        'fair_status': 'OPEN',
        'has_voted': false,
        'voting_window': 'OPEN',
        // Backend legacy: sin `categories` en el status.
      });

  @override
  Future<PaginatedResult<FairProjectModel>> getFairProjects(
    String fairId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async =>
      PaginatedResult(
        items: [
          FairProjectModel.fromJson({
            'id': 'proyecto-1',
            'fair_id': fairId,
            'name': 'Proyecto real',
            'description': '',
            'status': 'APPROVED',
            'category': {'id': 'cat-real', 'name': 'Categoría real'},
          }),
        ],
        total: 1,
        page: 1,
        limit: limit,
      );

  @override
  Future<PaginatedResult<JuryEvaluationSummaryModel>> getMyEvaluations({
    int page = 1,
    int limit = 50,
    String? fairId,
  }) async =>
      PaginatedResult(
        items: [
          const JuryEvaluationSummaryModel(
            id: 'eval-1',
            fairId: 'f-1',
            projectId: 'proyecto-1',
            submitted: true,
          ),
        ],
        total: 1,
        page: 1,
        limit: limit,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('el voto legacy funciona aunque el proyecto traiga category_id real',
      () async {
    final container = ProviderContainer(overrides: [
      juryRepositoryProvider.overrideWithValue(_LegacyRealCategoryRepo()),
    ]);
    addTearDown(container.dispose);

    container.read(votingFormProvider('f-1'));
    await container.read(votingFormProvider('f-1').notifier).load();

    final state = container.read(votingFormProvider('f-1'));
    expect(state.errorMessage, isNull);
    expect(state.categoryProgress.keys, ['cat-real']);
    expect(state.canVote, isTrue);
  });
}
