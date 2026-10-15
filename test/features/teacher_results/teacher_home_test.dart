import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_providers.dart';
import 'package:campusvote_flutter/features/teacher_results/data/teacher_results_repository.dart';
import 'package:campusvote_flutter/features/teacher_results/domain/teacher_results.dart';
import 'package:campusvote_flutter/features/teacher_results/presentation/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoSessionRepository implements AuthRepository {
  @override
  Future<bool> hasSession() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('El test no usa operaciones de sesión');
}

class _Fairs extends JuryDashboardNotifier {
  _Fairs(this.items);
  final List<FairAssignmentModel> items;

  @override
  Future<List<FairAssignmentModel>> build() async => items;
}

const _fair = FairAssignmentModel(
  fairId: 'f1',
  organizationId: 'org',
  name: 'Feria de innovación',
  description: '',
  status: FairStatus.open,
);

Widget _page(List<FairAssignmentModel> fairs) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_NoSessionRepository()),
        juryDashboardProvider.overrideWith(() => _Fairs(fairs)),
        teacherResultsProvider.overrideWith(
          (ref) async => const TeacherResults(
            status: TeacherResultsStatus.available,
            totalResponses: 12,
            overallAverage: 4.25,
          ),
        ),
      ],
      child:
          MaterialApp(theme: AppTheme.light(), home: const TeacherHomePage()),
    );

void main() {
  testWidgets('docente sin ferias: ve su evaluación y nada de jurado',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_page(const []));
    await tester.pumpAndSettle();

    expect(find.text('Mi evaluación docente'), findsOneWidget);
    expect(find.textContaining('Promedio 4.3 de 5'), findsOneWidget);
    // Sin asignación como jurado no aparece nada de jurado.
    expect(find.text('Jurado de ferias'), findsNothing);
    expect(find.textContaining('jurado', findRichText: true), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feria abierta: la tarjeta de jurado va primero con su botón',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_page(const [_fair]));
    await tester.pumpAndSettle();

    expect(find.text('HOY ERES JURADO'), findsOneWidget);
    expect(find.text('Feria de innovación'), findsOneWidget);
    expect(find.text('Entrar como jurado'), findsOneWidget);
    final juryY = tester.getTopLeft(find.text('HOY ERES JURADO')).dy;
    final evaluationY =
        tester.getTopLeft(find.text('Mi evaluación docente')).dy;
    expect(juryY, lessThan(evaluationY));
    expect(tester.takeException(), isNull);
  });

  testWidgets('feria por abrir: solo avisa la fecha', (tester) async {
    await tester.pumpWidget(_page([
      FairAssignmentModel(
        fairId: 'f2',
        organizationId: 'org',
        name: 'Feria de ciencias',
        description: '',
        status: FairStatus.draft,
        startsAt: DateTime(2026, 11, 20, 9),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Serás jurado'), findsOneWidget);
    expect(find.textContaining('el 20 de noviembre'), findsOneWidget);
    expect(find.text('Entrar como jurado'), findsNothing);
  });

  testWidgets('feria cerrada: queda como historial', (tester) async {
    await tester.pumpWidget(_page(const [
      FairAssignmentModel(
        fairId: 'f3',
        organizationId: 'org',
        name: 'Feria 2025',
        description: '',
        status: FairStatus.closed,
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Historial de jurado'), findsOneWidget);
    expect(find.text('Entrar como jurado'), findsNothing);
  });
}
