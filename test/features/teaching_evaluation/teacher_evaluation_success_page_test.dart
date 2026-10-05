import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teaching_assignment.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/pages/teacher_evaluation_success_page.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedTeachingListController extends TeachingListController {
  _FixedTeachingListController(super.ref, List<TeachingAssignment> items) {
    state = TeachingListState(items: items);
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
  testWidgets('no afirma éxito si el estado del backend sigue pendiente',
      (tester) async {
    await tester.pumpWidget(_page([_assignment]));

    expect(find.text('Evaluación registrada'), findsNothing);
    expect(find.text('No hay confirmación del servidor'), findsOneWidget);
  });

  testWidgets('muestra confirmación solo con la asignación completada',
      (tester) async {
    const completed = TeachingAssignment(
      id: 'assignment-1',
      courseId: 'course-1',
      teacherId: 'teacher-1',
      courseCode: 'MAT101',
      courseName: 'Matemática',
      cycle: 2,
      teacherFirstName: 'Ana',
      teacherLastName: 'Ríos',
      evaluated: true,
      isActive: true,
    );
    await tester.pumpWidget(_page([completed]));

    expect(find.text('El servidor ya muestra esta asignación como completada.'),
        findsOneWidget);
  });
}

Widget _page(List<TeachingAssignment> items) => ProviderScope(
      overrides: [
        teachingListControllerProvider.overrideWith(
          (ref) => _FixedTeachingListController(ref, items),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const TeacherEvaluationSuccessPage(
          assignmentId: 'assignment-1',
        ),
      ),
    );
