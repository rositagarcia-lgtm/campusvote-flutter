import 'dart:async';

import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teaching_assignment.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/repositories/teaching_evaluation_repository.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/evaluate_controller.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_evaluation_providers.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository implements TeachingEvaluationRepository {
  List<TeachingAssignment> assignments = [_pendingAssignment];
  Completer<Result<TeacherEvaluationResult>>? evaluationResponse;
  Result<TeacherEvaluationResult>? immediateResponse;
  int submitCalls = 0;
  int assignmentCalls = 0;

  @override
  Future<Result<List<TeachingAssignment>>> getMyAssignments() async {
    assignmentCalls++;
    return Success(assignments);
  }

  @override
  Future<Result<TeacherEvaluationResult>> evaluateTeacher({
    required String assignmentId,
    required int score,
    String? comment,
  }) {
    submitCalls++;
    if (evaluationResponse != null) return evaluationResponse!.future;
    return Future.value(immediateResponse!);
  }
}

class _SeededTeachingListController extends TeachingListController {
  _SeededTeachingListController(super.ref, List<TeachingAssignment> items) {
    state = TeachingListState(items: items);
  }

  @override
  Future<void> load() async {}
}

const _pendingAssignment = TeachingAssignment(
  id: 'assignment-1',
  courseId: 'course-1',
  teacherId: 'teacher-1',
  courseCode: 'MAT101',
  courseName: 'Matemática',
  cycle: 3,
  teacherFirstName: 'Ada',
  teacherLastName: 'Lovelace',
  evaluated: false,
  isActive: true,
);

const _completedAssignment = TeachingAssignment(
  id: 'assignment-1',
  courseId: 'course-1',
  teacherId: 'teacher-1',
  courseCode: 'MAT101',
  courseName: 'Matemática',
  cycle: 3,
  teacherFirstName: 'Ada',
  teacherLastName: 'Lovelace',
  evaluated: true,
  isActive: true,
);

ProviderContainer _container(_Repository repository) => ProviderContainer(
      overrides: [
        teachingEvaluationRepositoryProvider.overrideWithValue(repository),
        teachingListControllerProvider.overrideWith(
          (ref) => _SeededTeachingListController(ref, [_pendingAssignment]),
        ),
      ],
    );

void main() {
  test('carga las asignaciones al abrir el proveedor por primera vez',
      () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        teachingEvaluationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.listen(teachingListControllerProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    expect(repository.assignmentCalls, 1);
    expect(container.read(teachingListControllerProvider).items, hasLength(1));
    expect(container.read(teachingListControllerProvider).loading, isFalse);
  });

  test('bloquea un segundo toque mientras el primer envío está en curso',
      () async {
    final repository = _Repository()
      ..evaluationResponse = Completer<Result<TeacherEvaluationResult>>()
      ..assignments = [_completedAssignment];
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(
      evaluateTeacherControllerProvider('assignment-1').notifier,
    );

    final firstSubmit = controller.submit(score: 4);
    expect(repository.submitCalls, 1);
    expect(await controller.submit(score: 4), isFalse);
    expect(repository.submitCalls, 1);

    repository.evaluationResponse!.complete(
      const Success(TeacherEvaluationResult(id: 'evaluation-1', score: 4)),
    );
    expect(await firstSubmit, isTrue);
    expect(controller.state.confirmed, isTrue);
    expect(container.read(teachingListControllerProvider).done, hasLength(1));
    expect(repository.assignmentCalls, 1);
  });

  test('POST exitoso no confirma hasta que la lista reporte evaluated',
      () async {
    final repository = _Repository()
      ..immediateResponse = const Success(
        TeacherEvaluationResult(id: 'evaluation-1', score: 4),
      );
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(
      evaluateTeacherControllerProvider('assignment-1').notifier,
    );

    expect(await controller.submit(score: 4), isFalse);
    expect(repository.submitCalls, 1);
    expect(repository.assignmentCalls, 1);
    expect(controller.state.confirmed, isFalse);
    expect(controller.state.statusConfirmedPending, isTrue);
    expect(container.read(teachingListControllerProvider).done, isEmpty);
  });

  test('timeout se reconcilia con el endpoint de asignaciones', () async {
    final repository = _Repository()
      ..immediateResponse = const FailureResult(TimeoutFailure())
      ..assignments = [_completedAssignment];
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(
      evaluateTeacherControllerProvider('assignment-1').notifier,
    );

    expect(await controller.submit(score: 5), isTrue);
    expect(controller.state.confirmed, isTrue);
    expect(controller.state.needsStatusCheck, isFalse);
    expect(repository.submitCalls, 1);
  });

  test('solo permite un envío manual nuevo tras confirmar que sigue pendiente',
      () async {
    final repository = _Repository()
      ..immediateResponse = const FailureResult(TimeoutFailure());
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(
      evaluateTeacherControllerProvider('assignment-1').notifier,
    );

    expect(await controller.submit(score: 3), isFalse);
    expect(controller.state.needsStatusCheck, isFalse);
    expect(controller.state.statusConfirmedPending, isTrue);
    expect(repository.submitCalls, 1);

    repository.immediateResponse = const Success(
      TeacherEvaluationResult(id: 'evaluation-1', score: 3),
    );
    repository.assignments = [_completedAssignment];
    expect(await controller.submit(score: 3), isTrue);
    expect(repository.submitCalls, 2);
  });
}
