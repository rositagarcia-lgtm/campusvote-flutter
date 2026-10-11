import 'dart:async';

import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teacher_evaluation_form.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/domain/entities/teaching_assignment.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/evaluate_controller.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_evaluation_providers.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/state/teaching_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_teaching_repository.dart';

class _SeededTeachingListController extends TeachingListController {
  _SeededTeachingListController(super.ref, List<TeachingAssignment> items) {
    state = TeachingListState(items: items);
  }

  @override
  Future<void> load() async {}
}

ProviderContainer _container(FakeTeachingRepository repository) =>
    ProviderContainer(
      overrides: [
        teachingEvaluationRepositoryProvider.overrideWithValue(repository),
        teachingListControllerProvider.overrideWith(
          (ref) => _SeededTeachingListController(ref, [pendingAssignment]),
        ),
      ],
    );

Future<EvaluateTeacherController> _loaded(ProviderContainer container) async {
  final controller = container
      .read(evaluateTeacherControllerProvider('assignment-1').notifier);
  await controller.load(pendingAssignment);
  return controller;
}

void main() {
  test('carga las asignaciones al abrir el proveedor por primera vez',
      () async {
    final repository = FakeTeachingRepository();
    final container = ProviderContainer(overrides: [
      teachingEvaluationRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    container.listen(teachingListControllerProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    expect(repository.assignmentCalls, 1);
    expect(container.read(teachingListControllerProvider).items, hasLength(1));
  });

  test('pide la rúbrica de la sede y carrera del curso y restaura el borrador',
      () async {
    final repository = FakeTeachingRepository()
      ..existingDraft = const EvaluationDraft(
        id: 'draft-9',
        scores: {'c-1': 4},
        comment: 'Muy clara',
      );
    final container = _container(repository);
    addTearDown(container.dispose);

    final controller = await _loaded(container);

    expect(repository.criteriaSiteId, 'site-1');
    expect(repository.criteriaCareerId, 'career-1');
    expect(controller.state.criteria, hasLength(2));
    expect(controller.state.scores, {'c-1': 4});
    expect(controller.state.draftId, 'draft-9');
    expect(controller.state.initialComment, 'Muy clara');
    expect(controller.state.answered, 1);
  });

  test('crea un solo borrador aunque se califiquen dos criterios a la vez',
      () async {
    final repository = FakeTeachingRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);

    await Future.wait([
      controller.setScore('c-1', 5),
      controller.setScore('c-2', 3),
    ]);

    expect(repository.createCalls, 1);
    expect(repository.savedScores, {'c-1': 5, 'c-2': 3});
    expect(controller.state.complete, isTrue);
    expect(controller.state.saving, isEmpty);
  });

  test('si el borrador ya existía (409) lo reutiliza', () async {
    final repository = FakeTeachingRepository()
      ..createResult = const FailureResult(
        ConflictFailure(message: 'Ya existe'),
      );
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);
    repository.existingDraft = const EvaluationDraft(id: 'draft-old');

    await controller.setScore('c-1', 4);

    expect(controller.state.draftId, 'draft-old');
    expect(repository.savedScores['c-1'], 4);
  });

  test('revierte el puntaje si no se pudo guardar', () async {
    final repository = FakeTeachingRepository()
      ..scoreResult = const FailureResult(
        NetworkFailure(message: 'sin red'),
      );
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);

    await controller.setScore('c-1', 4);

    expect(controller.state.scores, isEmpty);
    expect(controller.state.errorMessage, contains('no se guardó'));
  });

  test('no envía sin todos los criterios ni la calificación general', () async {
    final repository = FakeTeachingRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);

    await controller.setScore('c-1', 4);
    expect(await controller.submit(), isFalse);
    expect(controller.state.errorMessage, contains('todos los criterios'));

    await controller.setScore('c-2', 5);
    expect(await controller.submit(), isFalse);
    expect(controller.state.errorMessage, contains('calificación general'));
    expect(repository.submitCalls, 0);
  });

  test('envía comentario y calificación general y confirma con el servidor',
      () async {
    final repository = FakeTeachingRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);
    await controller.setScore('c-1', 4);
    await controller.setScore('c-2', 5);
    controller.setOverall(4);

    expect(await controller.submit(comment: '  Gracias  '), isTrue);

    expect(repository.savedComment, '  Gracias  ');
    expect(repository.submittedOverall, 4);
    expect(controller.state.confirmed, isTrue);
    expect(
      container.read(teachingListControllerProvider).items.single.evaluated,
      isTrue,
    );
  });

  test('bloquea un segundo toque mientras el primer envío está en curso',
      () async {
    final repository = FakeTeachingRepository()
      ..submitCompleter = Completer<Result<void>>();
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);
    await controller.setScore('c-1', 4);
    await controller.setScore('c-2', 5);
    controller.setOverall(5);

    final first = controller.submit();
    await Future<void>.delayed(Duration.zero);
    expect(await controller.submit(), isFalse);

    repository.submitCompleter!.complete(const Success(null));
    expect(await first, isTrue);
    expect(repository.submitCalls, 1);
  });

  test('sin respuesta del envío consulta el estado antes de permitir otro',
      () async {
    final repository = FakeTeachingRepository()
      ..markEvaluatedOnSubmit = false
      ..submitResult =
          const FailureResult(TimeoutFailure(message: 'tiempo agotado'));
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = await _loaded(container);
    await controller.setScore('c-1', 4);
    await controller.setScore('c-2', 5);
    controller.setOverall(3);

    expect(await controller.submit(), isFalse);

    // El servidor confirma que sigue pendiente: se permite reenviar.
    expect(controller.state.statusConfirmedPending, isTrue);
    expect(controller.state.locked, isFalse);
  });
}
