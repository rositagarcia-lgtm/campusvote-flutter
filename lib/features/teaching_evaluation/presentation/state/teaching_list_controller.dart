import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/teaching_assignment.dart';
import 'teaching_evaluation_providers.dart';

class TeachingListState {
  final bool loading;
  final List<TeachingAssignment> items;
  final String? errorMessage;

  const TeachingListState({
    this.loading = false,
    this.items = const [],
    this.errorMessage,
  });

  TeachingListState copyWith({
    bool? loading,
    List<TeachingAssignment>? items,
    String? errorMessage,
    bool clearError = false,
  }) =>
      TeachingListState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  List<TeachingAssignment> get pending =>
      items.where((a) => !a.evaluated).toList(growable: false);
  List<TeachingAssignment> get done =>
      items.where((a) => a.evaluated).toList(growable: false);
  bool get isEmpty => items.isEmpty && !loading;
}

class TeachingListController extends StateNotifier<TeachingListState> {
  TeachingListController(this._ref)
      : super(const TeachingListState(loading: true));

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final res =
        await _ref.read(getMyTeachingAssignmentsUseCaseProvider)();
    res.when(
      success: (items) {
        state = state.copyWith(loading: false, items: items);
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  Future<void> refresh() async => load();

  /// Marca una asignación como evaluada tras un submit exitoso.
  void markEvaluated(String assignmentId) {
    state = state.copyWith(
      items: [
        for (final a in state.items)
          if (a.id == assignmentId)
            TeachingAssignment(
              id: a.id,
              courseId: a.courseId,
              teacherId: a.teacherId,
              courseCode: a.courseCode,
              courseName: a.courseName,
              cycle: a.cycle,
              teacherFirstName: a.teacherFirstName,
              teacherLastName: a.teacherLastName,
              evaluated: true,
              isActive: a.isActive,
            )
          else
            a,
      ],
    );
  }
}

final teachingListControllerProvider = StateNotifierProvider<
    TeachingListController, TeachingListState>(
  (ref) => TeachingListController(ref),
);