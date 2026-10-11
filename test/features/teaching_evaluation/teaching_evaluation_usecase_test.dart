import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/usecases/teaching_evaluation_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_teaching_repository.dart';

void main() {
  group('GetMyTeachingAssignmentsUseCase', () {
    test('devuelve las asignaciones del repositorio', () async {
      final repo = FakeTeachingRepository();
      final result = await GetMyTeachingAssignmentsUseCase(repo)();
      expect(repo.assignmentCalls, 1);
      final items = result.dataOrNull;
      expect(items, hasLength(1));
      expect(items!.first.teacherFullName, 'Ana Ríos');
      expect(items.first.canEvaluate, isTrue);
    });
  });

  group('SubmitTeacherEvaluationUseCase', () {
    test('rechaza calificaciones generales fuera de 1 a 5', () async {
      final repo = FakeTeachingRepository();
      final useCase = SubmitTeacherEvaluationUseCase(repo);
      final low = await useCase(responseId: 'd-1', overallRating: 0);
      final high = await useCase(responseId: 'd-1', overallRating: 6);
      expect(low.failureOrNull, isA<ValidationFailure>());
      expect(high.failureOrNull, isA<ValidationFailure>());
      expect(repo.submitCalls, 0);
    });

    test('envía la calificación general válida', () async {
      final repo = FakeTeachingRepository();
      final result = await SubmitTeacherEvaluationUseCase(repo)(
        responseId: 'd-1',
        overallRating: 4,
      );
      expect(result.isSuccess, isTrue);
      expect(repo.submittedOverall, 4);
    });
  });
}
