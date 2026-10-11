import 'dart:async';

import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teacher_evaluation_form.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teaching_assignment.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/repositories/teaching_evaluation_repository.dart';

const pendingAssignment = TeachingAssignment(
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
  siteId: 'site-1',
  careerId: 'career-1',
);

const testCriteria = [
  EvaluationCriterion(id: 'c-1', name: 'Dominio del tema'),
  EvaluationCriterion(
    id: 'c-2',
    name: 'Puntualidad',
    description: 'Llega a tiempo y respeta el horario.',
  ),
];

/// Repositorio en memoria que registra las llamadas del flujo por criterios.
class FakeTeachingRepository implements TeachingEvaluationRepository {
  List<TeachingAssignment> assignments = [pendingAssignment];
  List<EvaluationCriterion> criteria = testCriteria;
  EvaluationDraft? existingDraft;
  Result<EvaluationDraft>? createResult;
  Result<void> scoreResult = const Success(null);
  Result<void> submitResult = const Success(null);
  Completer<Result<void>>? submitCompleter;

  /// Al enviar con éxito, la lista pasa a marcar la asignación como evaluada.
  bool markEvaluatedOnSubmit = true;

  int assignmentCalls = 0;
  int createCalls = 0;
  int submitCalls = 0;
  final savedScores = <String, int>{};
  String? savedComment;
  int? submittedOverall;
  String? criteriaSiteId;
  String? criteriaCareerId;

  @override
  Future<Result<List<TeachingAssignment>>> getMyAssignments() async {
    assignmentCalls++;
    return Success(assignments);
  }

  @override
  Future<Result<List<EvaluationCriterion>>> getCriteria({
    required String siteId,
    required String careerId,
  }) async {
    criteriaSiteId = siteId;
    criteriaCareerId = careerId;
    return Success(criteria);
  }

  @override
  Future<Result<EvaluationDraft?>> findDraft(String assignmentId) async =>
      Success(existingDraft);

  @override
  Future<Result<EvaluationDraft>> createDraft(String assignmentId) async {
    createCalls++;
    await Future<void>.delayed(Duration.zero);
    return createResult ?? const Success(EvaluationDraft(id: 'draft-1'));
  }

  @override
  Future<Result<void>> saveScore({
    required String responseId,
    required String criterionId,
    required int score,
  }) async {
    if (scoreResult.isSuccess) savedScores[criterionId] = score;
    return scoreResult;
  }

  @override
  Future<Result<void>> saveComment({
    required String responseId,
    required String comment,
  }) async {
    savedComment = comment;
    return const Success(null);
  }

  @override
  Future<Result<void>> submit({
    required String responseId,
    required int overallRating,
  }) async {
    submitCalls++;
    submittedOverall = overallRating;
    final result =
        submitCompleter != null ? await submitCompleter!.future : submitResult;
    if (result.isSuccess && markEvaluatedOnSubmit) {
      assignments = [
        for (final a in assignments) a.copyWith(evaluated: true),
      ];
    }
    return result;
  }
}
