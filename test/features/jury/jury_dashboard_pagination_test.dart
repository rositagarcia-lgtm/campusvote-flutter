import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/fairs/jury_fair_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TwoPageAssignmentsRepo implements JuryRepository {
  @override
  Future<PaginatedResult<FairAssignmentModel>> getMyAssignments({
    int page = 1,
    int limit = 50,
  }) async {
    return PaginatedResult(
      items: [
        FairAssignmentModel.fromJson({
          'fair': {
            'id': 'f-$page',
            'organization_id': 'org-1',
            'name': 'Feria $page',
            'status': 'OPEN',
          },
        }),
      ],
      total: 51,
      page: page,
      limit: limit,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('el dashboard del jurado recorre todas las páginas', () async {
    final container = ProviderContainer(overrides: [
      juryRepositoryProvider.overrideWithValue(_TwoPageAssignmentsRepo()),
    ]);
    addTearDown(container.dispose);

    final dashboard = await container.read(juryDashboardProvider.future);
    expect(dashboard.map((f) => f.fairId), ['f-1', 'f-2']);
  });
}
