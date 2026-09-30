import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/repositories/teaching_evaluation_repository_impl.dart';
import '../../domain/repositories/teaching_evaluation_repository.dart';
import '../../domain/usecases/teaching_evaluation_usecases.dart';

final teachingEvaluationRepositoryProvider =
    Provider<TeachingEvaluationRepository>((ref) {
  return TeachingEvaluationRepositoryImpl(ref.watch(apiClientProvider));
});

final getMyTeachingAssignmentsUseCaseProvider = Provider(
  (ref) => GetMyTeachingAssignmentsUseCase(
      ref.watch(teachingEvaluationRepositoryProvider)),
);

final evaluateTeacherUseCaseProvider = Provider(
  (ref) => EvaluateTeacherUseCase(ref.watch(teachingEvaluationRepositoryProvider)),
);