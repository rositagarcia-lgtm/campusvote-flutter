import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/pages/jury_project_detail_page.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra proyecto asignado, rúbrica y estado anónimo del voto',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1100));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        juryRepositoryProvider.overrideWithValue(_Repository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const JuryProjectDetailPage(fairId: 'f1', projectId: 'p1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Robot solar'), findsOneWidget);
    expect(find.text('Stand A-01'), findsOneWidget);
    expect(find.text('Tu rúbrica'), findsOneWidget);
    expect(find.text('Voto de tu categoría'), findsOneWidget);
    expect(find.text('Emitido'), findsOneWidget);
    expect(find.textContaining('El voto es anónimo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Repository implements JuryRepository {
  @override
  Future<PaginatedResult<FairProjectModel>> getFairProjects(
    String fairId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async =>
      const PaginatedResult(
        items: [FairProjectModel(
          id: 'p1',
          fairId: 'f1',
          name: 'Robot solar',
          description: 'Convierte luz en energía.',
          status: 'APPROVED',
          categoryId: 'c1',
          categoryName: 'Robótica',
          standCode: 'A-01',
        )],
        total: 1,
        page: 1,
        limit: 100,
      );

  @override
  Future<PaginatedResult<JuryEvaluationSummaryModel>> getMyEvaluations({
    int page = 1,
    int limit = 50,
    String? fairId,
  }) async =>
      const PaginatedResult(
        items: [JuryEvaluationSummaryModel(
          id: 'e1',
          fairId: 'f1',
          projectId: 'p1',
          submitted: true,
          checkedCount: 3,
          criteriaCount: 4,
        )],
        total: 1,
        page: 1,
        limit: 50,
      );

  @override
  Future<JuryProgressModel> getMyProgress(String fairId) async =>
      const JuryProgressModel(
        fairId: 'f1',
        totalProjects: 1,
        completedProjects: 1,
        pendingProjects: 0,
        progressPercentage: 100,
        hasVoted: true,
        fairStatus: FairStatus.open,
        declaration: JuryDeclarationModel(
          id: 'd1',
          fairId: 'f1',
          statement: 'Declaro imparcialidad',
        ),
      );

  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async =>
      const VotingStatusModel(
        fairId: 'f1',
        fairStatus: FairStatus.open,
        hasVoted: true,
        categories: [VotingCategory(id: 'c1', name: 'Robótica', hasVoted: true)],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
