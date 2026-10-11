import 'package:campusvote_flutter/features/teaching_evaluation/data/models/teaching_assignment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lee asignación, docente, curso, rúbrica y jornada del contrato', () {
    final assignment = TeachingAssignmentModel.fromJson({
      'id': 'assignment-1',
      'cycle': 4,
      'careerId': 'career-1',
      'isActive': true,
      'evaluated': false,
      'evaluationOpen': true,
      'course': {
        'id': 'course-1',
        'code': 'MAT104',
        'name': 'Matemática',
        'siteId': 'site-1',
      },
      'teacher': {
        'id': 'teacher-1',
        'firstName': 'Ada',
        'lastName': 'Lovelace'
      },
      'academicPeriod': {
        'startDate': '2026-10-15T00:00:00.000Z',
        'endDate': '2026-10-15T00:00:00.000Z',
      },
    }).toEntity();

    expect(assignment.teacherFullName, 'Ada Lovelace');
    expect(assignment.siteId, 'site-1');
    expect(assignment.careerId, 'career-1');
    expect(assignment.canEvaluate, isTrue);
    // Día de calendario, sin correrse por la zona horaria.
    expect(assignment.opensAt, DateTime(2026, 10, 15));
  });

  test('sin confirmación del API no está activa ni abierta', () {
    final assignment =
        TeachingAssignmentModel.fromJson({'id': 'assignment-1'}).toEntity();

    expect(assignment.isActive, isFalse);
    expect(assignment.evaluationOpen, isFalse);
    expect(assignment.canEvaluate, isFalse);
  });

  test('jornada futura: no se puede evaluar todavía', () {
    final tomorrow = DateTime.now().add(const Duration(days: 2));
    final day =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    final assignment = TeachingAssignmentModel.fromJson({
      'id': 'assignment-1',
      'isActive': true,
      'evaluationOpen': false,
      'academicPeriod': {'startDate': '${day}T00:00:00.000Z'},
    }).toEntity();

    expect(assignment.opensLater, isTrue);
    expect(assignment.canEvaluate, isFalse);
  });
}
