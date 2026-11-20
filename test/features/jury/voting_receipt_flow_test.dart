import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/voting/voting_provider.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_voting_status_provider.dart';
import 'package:campusvote_flutter/features/jury/presentation/voting/widgets/body/voting_body.dart';
import 'package:campusvote_flutter/features/jury/presentation/voting/widgets/voting_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _VoteRepo implements JuryRepository {
  bool firstVoted = false;
  int castCalls = 0;

  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async =>
      VotingStatusModel.fromJson({
        'fair_id': fairId,
        'fair_status': 'OPEN',
        'voting_window': 'OPEN',
        'categories': [
          {
            'category_id': 'first',
            'category_name': 'Tecnología',
            'has_voted': firstVoted
          },
          {
            'category_id': 'second',
            'category_name': 'Ciencias',
            'has_voted': false
          },
        ],
      });

  @override
  Future<PaginatedResult<FairProjectModel>> getFairProjects(String fairId,
          {int page = 1, int limit = 100, String? search}) async =>
      PaginatedResult(
        items: [
          const FairProjectModel(
              id: 'p1',
              fairId: 'f1',
              name: 'Motor eléctrico',
              description: '',
              status: 'APPROVED',
              categoryId: 'first',
              categoryName: 'Tecnología'),
          const FairProjectModel(
              id: 'p2',
              fairId: 'f1',
              name: 'Huerto',
              description: '',
              status: 'APPROVED',
              categoryId: 'second',
              categoryName: 'Ciencias'),
        ],
        total: 2,
        page: page,
        limit: limit,
      );

  @override
  Future<PaginatedResult<JuryEvaluationSummaryModel>> getMyEvaluations({
    int page = 1,
    int limit = 50,
    String? fairId,
  }) async =>
      PaginatedResult(
        items: const [
          JuryEvaluationSummaryModel(
              id: 'e1', fairId: 'f1', projectId: 'p1', submitted: true),
          JuryEvaluationSummaryModel(
              id: 'e2', fairId: 'f1', projectId: 'p2', submitted: true),
        ],
        total: 2,
        page: page,
        limit: limit,
      );

  @override
  Future<VoteReceiptModel> castVote(String fairId, String projectId) async {
    castCalls++;
    firstVoted = true;
    return const VoteReceiptModel(status: 'CAST', receiptCode: 'receipt-123');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('submit confirmado muestra comprobante antes de participación',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    final repo = _VoteRepo();
    final container = ProviderContainer(overrides: [
      localStorageProvider.overrideWithValue(storage),
      juryRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    final refreshWithoutReceipt = ValueNotifier(false);
    addTearDown(refreshWithoutReceipt.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: ValueListenableBuilder<bool>(
          valueListenable: refreshWithoutReceipt,
          builder: (context, missingReceipt, _) => Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(votingFormProvider('f1'));
              if (state.loading || state.status == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return VotingBody(
                fairName: 'Feria de Innovación',
                state:
                    missingReceipt ? state.copyWith(clearReceipt: true) : state,
                controller: ref.read(votingFormProvider('f1').notifier),
                onSubmitted: () =>
                    ref.invalidate(juryVotingStatusProvider('f1')),
              );
            },
          ),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    final controller = container.read(votingFormProvider('f1').notifier);
    expect(controller.state.canVote, isTrue);
    controller.select('p1');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revisar y confirmar voto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar voto'));
    await tester.pumpAndSettle();

    expect(repo.castCalls, 1);
    expect(controller.state.receipt?.receiptCode, 'receipt-123');
    expect(controller.state.hasVoted, isTrue);
    expect(find.byType(VoteReceiptView), findsOneWidget);
    expect(find.byType(VoteParticipationView), findsNothing);
    expect(find.text('receipt-123'), findsOneWidget);
    expect(find.text('Votar en Ciencias'), findsOneWidget);

    // Una actualización de la vista no debe ocultar el recibo ya recibido.
    refreshWithoutReceipt.value = true;
    await tester.pumpAndSettle();
    expect(find.byType(VoteReceiptView), findsOneWidget);
    expect(find.byType(VoteParticipationView), findsNothing);

    await tester.tap(find.text('Volver a la votación'));
    await tester.pumpAndSettle();
    expect(find.byType(VoteReceiptView), findsNothing);
    expect(controller.state.hasVoted, isTrue);
    expect(controller.state.canVote, isFalse);
    expect(repo.castCalls, 1);
    expect(find.text('Votar en Ciencias'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciencias'));
    await tester.pumpAndSettle();
    expect(controller.state.activeCategoryId, 'second');
    expect(controller.state.canVote, isTrue);
    expect(controller.state.receipt, isNull);

    controller.selectCategory('first');
    await tester.pumpAndSettle();
    expect(find.byType(VoteReceiptView), findsNothing);
    expect(find.byType(VoteParticipationView), findsOneWidget);
    expect(find.text('Ya has votado'), findsOneWidget);
  });
}
