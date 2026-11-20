import 'package:campusvote_flutter/features/jury/data/datasources/jury_remote_datasource.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/voting/voting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _VotingRepo implements JuryRepository {
  bool _bothSubmitted = true;
  int evaluationsCalls = 0;
  int castCalls = 0;

  void markOnePending() => _bothSubmitted = false;

  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async =>
      VotingStatusModel.fromJson({
        'fair_id': fairId,
        'fair_status': 'OPEN',
        'voting_window': 'OPEN',
        'has_voted': false,
        'categories': [
          {
            'category_id': 'cat-1',
            'category_name': 'Tecnología',
            'has_voted': false,
          },
        ],
      });

  @override
  Future<PaginatedResult<FairProjectModel>> getFairProjects(
    String fairId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    FairProjectModel project(String id) => FairProjectModel.fromJson({
          'id': id,
          'fair_id': fairId,
          'name': 'Proyecto $id',
          'status': 'APPROVED',
          'category': {'id': 'cat-1', 'name': 'Tecnología'},
        });
    return PaginatedResult(
      items: [project('p1'), project('p2')],
      total: 2,
      page: 1,
      limit: limit,
    );
  }

  @override
  Future<PaginatedResult<JuryEvaluationSummaryModel>> getMyEvaluations({
    int page = 1,
    int limit = 50,
    String? fairId,
  }) async {
    evaluationsCalls++;
    final items = <JuryEvaluationSummaryModel>[
      JuryEvaluationSummaryModel(
        id: 'eval-1',
        fairId: fairId ?? 'f-1',
        projectId: 'p1',
        submitted: true,
      ),
      if (_bothSubmitted)
        JuryEvaluationSummaryModel(
          id: 'eval-2',
          fairId: fairId ?? 'f-1',
          projectId: 'p2',
          submitted: true,
        ),
    ];
    return PaginatedResult(
      items: items,
      total: items.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<VoteReceiptModel> castVote(String fairId, String projectId) async {
    castCalls++;
    throw const JuryApiException(
      'No puedes emitir tu voto oficial. Te faltan 1 rúbrica(s) por finalizar en esta categoría.',
      statusCode: 409,
      code: 'RUBRICS_INCOMPLETE',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('409 RUBRICS_INCOMPLETE conserva el mensaje y refresca el progreso',
      () async {
    final repo = _VotingRepo();
    final container = ProviderContainer(overrides: [
      juryRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(votingFormProvider('f-1').notifier);
    await notifier.load();
    final baselineEvaluationsCalls = repo.evaluationsCalls;
    expect(notifier.state.canVote, isTrue);

    // El servidor tiene una rúbrica pendiente aunque la pantalla todavía crea
    // que están todas completas: el LOCAL no decide, el 409 sí.
    repo.markOnePending();
    notifier.select('p1');
    expect(await notifier.submit(), isFalse);

    expect(repo.castCalls, 1);
    // La reconciliación vuelve a consultar evaluaciones, no solo el estado.
    expect(repo.evaluationsCalls, baselineEvaluationsCalls + 1);

    final state = notifier.state;
    expect(state.errorMessage, contains('Te faltan 1 rúbrica(s)'));
    expect(state.categoryProgress['cat-1']!.totalProjects, 2);
    expect(state.categoryProgress['cat-1']!.completedRubrics, 1);
    expect(state.categoryProgress['cat-1']!.pendingCount, 1);
    expect(state.canVote, isFalse);
    expect(state.requiresStatusRefresh, isFalse);
  });
}
