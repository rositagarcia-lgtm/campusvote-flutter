import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/jury_voting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

FairProjectModel _project(String id, String status) =>
    FairProjectModel.fromJson({
      'id': id,
      'fair_id': 'f-1',
      'name': 'Proyecto $id',
      'description': '',
      'status': status,
    });

/// Repositorio con 2 páginas de proyectos (limit 2, total 3).
class _Repo implements JuryRepository {
  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async =>
      VotingStatusModel.fromJson({
        'fair_id': fairId,
        'fair_status': 'OPEN',
        'has_voted': false,
        'voting_window': 'OPEN',
      });

  @override
  Future<PaginatedResult<FairProjectModel>> getFairProjects(
    String fairId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async =>
      page == 1
          ? PaginatedResult(
              items: [_project('a', 'APPROVED'), _project('b', 'SUBMITTED')],
              total: 3,
              page: 1,
              limit: 2,
            )
          : PaginatedResult(
              items: [_project('c', 'APPROVED')],
              total: 3,
              page: 2,
              limit: 2,
            );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('la votación carga proyectos paginados sin error y solo aprobados',
      () async {
    final container = ProviderContainer(overrides: [
      juryRepositoryProvider.overrideWithValue(_Repo()),
    ]);
    addTearDown(container.dispose);

    container.read(votingFormProvider('f-1'));
    await container.read(votingFormProvider('f-1').notifier).load();
    final state = container.read(votingFormProvider('f-1'));

    expect(state.errorMessage, isNull);
    expect(state.projects.map((p) => p.id), ['a', 'c']);
    expect(state.canVote, isTrue);
  });
}
