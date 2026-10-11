import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/pages/teacher_evaluation_page.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_evaluation_providers.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teacher_evaluation_form.dart';

import 'fake_teaching_repository.dart';

class _FixedTeachingListController extends TeachingListController {
  _FixedTeachingListController(super.ref) {
    state = const TeachingListState(items: [pendingAssignment]);
  }

  @override
  Future<void> load() async {}
}

Future<void> _tapStar(WidgetTester tester, String label, int index) async {
  final star = find.bySemanticsLabel(label).at(index);
  await tester.ensureVisible(star);
  await tester.pumpAndSettle();
  await tester.tap(star);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0, 430.0, 768.0]) {
    testWidgets('rúbrica adaptable a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_page(width, FakeTeachingRepository()));
      await tester.pumpAndSettle();

      expect(find.text('1. Dominio del tema'), findsOneWidget);
      expect(find.text('2. Puntualidad'), findsOneWidget);
      expect(find.text('Llega a tiempo y respeta el horario.'), findsOneWidget);
      expect(find.text('0 de 2 criterios'), findsOneWidget);
      expect(find.text('Calificación general'), findsOneWidget);
      expect(find.text('Revisar y enviar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('exige todos los criterios antes de revisar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    final repository = FakeTeachingRepository();
    await tester.pumpWidget(_page(390, repository));
    await tester.pumpAndSettle();

    await _tapStar(tester, '4 de 5 estrellas', 0);
    expect(find.text('1 de 2 criterios'), findsOneWidget);
    expect(repository.savedScores, {'c-1': 4});

    await _tapText(tester, 'Revisar y enviar');
    expect(find.text('Califica todos los criterios antes de enviar.'),
        findsOneWidget);
    expect(find.text('Revisa tu evaluación'), findsNothing);
  });

  testWidgets('revisa la evaluación completa antes de enviar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    final repository = FakeTeachingRepository();
    await tester.pumpWidget(_page(390, repository));
    await tester.pumpAndSettle();

    await _tapStar(tester, '4 de 5 estrellas', 0);
    await _tapStar(tester, '5 de 5 estrellas', 1);
    await _tapStar(tester, '3 de 5 estrellas', 2);
    await _tapText(tester, 'Revisar y enviar');

    expect(find.text('Revisa tu evaluación'), findsOneWidget);
    expect(find.text('2 de 2 calificados'), findsOneWidget);
    expect(find.text('3 de 5'), findsOneWidget);
    await tester.tap(find.text('Seguir editando'));
    await tester.pumpAndSettle();
    expect(repository.submitCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('agrupa los criterios generales de la sede y los de la carrera',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    final repository = FakeTeachingRepository()
      ..criteria = const [
        EvaluationCriterion(
            id: 'c-3', name: 'Uso del laboratorio', careerId: 'career-1'),
        EvaluationCriterion(id: 'c-1', name: 'Puntualidad'),
      ];
    await tester.pumpWidget(_page(390, repository));
    await tester.pumpAndSettle();

    expect(find.text('GENERALES DE LA SEDE'), findsOneWidget);
    expect(find.text('DE TU CARRERA'), findsOneWidget);
    // Los generales van primero.
    expect(find.text('1. Puntualidad'), findsOneWidget);
    expect(find.text('2. Uso del laboratorio'), findsOneWidget);
  });
}

Widget _page(double width, FakeTeachingRepository repository) => MediaQuery(
      data: MediaQueryData(
        size: Size(width, 720),
        textScaler: const TextScaler.linear(1.35),
      ),
      child: ProviderScope(
        overrides: [
          teachingEvaluationRepositoryProvider.overrideWithValue(repository),
          teachingListControllerProvider.overrideWith(
            _FixedTeachingListController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const TeacherEvaluationPage(assignmentId: 'assignment-1'),
        ),
      ),
    );
