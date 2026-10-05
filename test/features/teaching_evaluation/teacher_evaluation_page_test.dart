import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teaching_assignment.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/pages/teacher_evaluation_page.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedTeachingListController extends TeachingListController {
  _FixedTeachingListController(super.ref) {
    state = const TeachingListState(items: [_assignment]);
  }

  @override
  Future<void> load() async {}
}

const _assignment = TeachingAssignment(
  id: 'assignment-1',
  courseId: 'course-1',
  teacherId: 'teacher-1',
  courseCode: 'MAT101',
  courseName: 'Matemática',
  cycle: 2,
  teacherFirstName: 'Ana',
  teacherLastName: 'Ríos',
  evaluated: false,
  isActive: true,
);

void main() {
  for (final width in [320.0, 390.0, 430.0, 768.0]) {
    testWidgets('formulario docente adaptable a ${width.toInt()} px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_page(width));
      await tester.pumpAndSettle();

      expect(find.text('Calificación general'), findsOneWidget);
      expect(find.text('COMENTARIO DE MEJORA (OPCIONAL)'), findsOneWidget);
      expect(find.text('Revisar y confirmar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('exige calificación antes de permitir la revisión',
      (tester) async {
    const width = 390.0;
    await tester.binding.setSurfaceSize(const Size(width, 720));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_page(width));
    await tester.pumpAndSettle();

    final submitButton = find.text('Revisar y confirmar');
    await tester.dragUntilVisible(
      submitButton,
      find.byType(Scrollable).first,
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('teacher-score-error')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('revisa la selección antes de enviar y conserva el borrador',
      (tester) async {
    const width = 390.0;
    await tester.binding.setSurfaceSize(const Size(width, 720));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_page(width));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('4 de 5 estrellas'));
    await tester.pumpAndSettle();
    final submitButton = find.text('Revisar y confirmar');
    await tester.dragUntilVisible(
      submitButton,
      find.byType(Scrollable).first,
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Revisa tu evaluación'), findsOneWidget);
    expect(find.text('4 de 5'), findsOneWidget);
    await tester.tap(find.text('Seguir editando'));
    await tester.pumpAndSettle();
    expect(find.text('Seleccionaste 4 de 5.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _page(double width) => MediaQuery(
      data: MediaQueryData(
        size: Size(width, 720),
        textScaler: const TextScaler.linear(1.35),
      ),
      child: ProviderScope(
        overrides: [
          teachingListControllerProvider.overrideWith(
            _FixedTeachingListController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const TeacherEvaluationPage(
            assignmentId: 'assignment-1',
          ),
        ),
      ),
    );
