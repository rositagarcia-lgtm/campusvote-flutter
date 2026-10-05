import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teaching_assignment.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/repositories/teaching_evaluation_repository.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/usecases/teaching_evaluation_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements TeachingEvaluationRepository {
  String? evaluatedAssignmentId;
  int? evaluatedScore;
  String? evaluatedComment;
  bool listCalled = false;

  @override
  Future<Result<List<TeachingAssignment>>> getMyAssignments() async {
    listCalled = true;
    return const Success([
      TeachingAssignment(
        id: 'a-1',
        courseId: 'c-1',
        teacherId: 't-1',
        courseCode: 'MAT101',
        courseName: 'Cálculo I',
        cycle: 4,
        teacherFirstName: 'Ana',
        teacherLastName: 'López',
        evaluated: false,
        isActive: true,
      ),
    ]);
  }

  @override
  Future<Result<TeacherEvaluationResult>> evaluateTeacher({
    required String assignmentId,
    required int score,
    String? comment,
  }) async {
    evaluatedAssignmentId = assignmentId;
    evaluatedScore = score;
    evaluatedComment = comment;
    return Success(TeacherEvaluationResult(id: 'e-1', score: score));
  }
}

void main() {
  group('GetMyTeachingAssignmentsUseCase', () {
    test('returns assignments from repository', () async {
      final repo = _Repo();
      final result = await GetMyTeachingAssignmentsUseCase(repo)();
      expect(result.isSuccess, isTrue);
      expect(repo.listCalled, isTrue);
      final items = result.dataOrNull;
      expect(items, hasLength(1));
      expect(items!.first.courseName, 'Cálculo I');
      expect(items.first.teacherFullName, 'Ana López');
      expect(items.first.evaluated, isFalse);
      expect(items.first.isActive, isTrue);
    });
  });

  group('EvaluateTeacherUseCase', () {
    test('rejects scores below 1 and above 5', () async {
      final repo = _Repo();
      final low = await EvaluateTeacherUseCase(repo)(
        assignmentId: 'a-1',
        score: 0,
      );
      expect(low.failureOrNull, isA<ValidationFailure>());
      final high = await EvaluateTeacherUseCase(repo)(
        assignmentId: 'a-1',
        score: 6,
      );
      expect(high.failureOrNull, isA<ValidationFailure>());
      expect(repo.evaluatedAssignmentId, isNull);
    });

    test('rejects comments over 2000 characters', () async {
      final repo = _Repo();
      final result = await EvaluateTeacherUseCase(repo)(
        assignmentId: 'a-1',
        score: 5,
        comment: 'a' * 2001,
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repo.evaluatedAssignmentId, isNull);
    });

    test('accepts a 2000-character comment', () async {
      final repo = _Repo();
      final result = await EvaluateTeacherUseCase(repo)(
        assignmentId: 'a-1',
        score: 4,
        comment: 'b' * 2000,
      );
      expect(result.isSuccess, isTrue);
      expect(repo.evaluatedAssignmentId, 'a-1');
      expect(repo.evaluatedComment, 'b' * 2000);
    });

    test('forwards score and trims comment', () async {
      final repo = _Repo();
      final result = await EvaluateTeacherUseCase(repo)(
        assignmentId: 'a-1',
        score: 3,
        comment: '   Buena clase   ',
      );
      expect(result.isSuccess, isTrue);
      expect(repo.evaluatedScore, 3);
      expect(repo.evaluatedComment, 'Buena clase');
    });

    test('omits empty comment forwarding', () async {
      final repo = _Repo();
      await EvaluateTeacherUseCase(repo)(
        assignmentId: 'a-1',
        score: 5,
        comment: '   ',
      );
      expect(repo.evaluatedComment, isNull);
    });
  });
}
