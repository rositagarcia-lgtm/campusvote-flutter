import 'package:campusvote_flutter/features/teaching_evaluation/data/models/teaching_assignment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lee asignación, docente, curso y estado del contrato recibido', () {
    final model = TeachingAssignmentModel.fromJson({
      'id': 'assignment-1',
      'cycle': 4,
      'isActive': true,
      'evaluated': false,
      'course': {'id': 'course-1', 'code': 'MAT104', 'name': 'Matemática'},
      'teacher': {
        'id': 'teacher-1',
        'firstName': 'Ada',
        'lastName': 'Lovelace',
      },
    });

    final assignment = model.toEntity();
    expect(assignment.id, 'assignment-1');
    expect(assignment.teacherFullName, 'Ada Lovelace');
    expect(assignment.courseName, 'Matemática');
    expect(assignment.isActive, isTrue);
    expect(assignment.evaluated, isFalse);
  });

  test('no marca como activa una asignación si falta la confirmación del API',
      () {
    final model = TeachingAssignmentModel.fromJson({
      'id': 'assignment-1',
      'evaluated': false,
    });

    expect(model.toEntity().isActive, isFalse);
    expect(model.toEntity().teacherFullName.trim(), isEmpty);
  });
}
