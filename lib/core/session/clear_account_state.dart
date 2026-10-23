import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/state/two_factor_controller.dart';
import '../../features/certificates/data/certificates_repository.dart';
import '../../features/jury/presentation/providers/fairs/jury_fair_providers.dart';
import '../../features/jury/presentation/providers/forms/jury_declaration_provider.dart';
import '../../features/jury/presentation/providers/forms/jury_rubric_provider.dart';
import '../../features/jury/presentation/providers/forms/jury_voting_provider.dart';
import '../../features/jury/presentation/providers/jury_dashboard_progress.dart';
import '../../features/jury/presentation/providers/jury_voting_status_provider.dart';
import '../../features/jury/presentation/providers/progress/jury_progress_provider.dart';
import '../../features/student_projects/data/student_projects_repository.dart';
import '../../features/teacher_results/data/adviser_projects_repository.dart';
import '../../features/teacher_results/data/teacher_results_repository.dart';
import '../../features/teaching_evaluation/presentation/state/evaluate_controller.dart';
import '../../features/teaching_evaluation/presentation/state/teaching_list_controller.dart';

/// Invalida datos y formularios vinculados a la cuenta anterior.
void clearAccountState(Ref ref) {
  ref.invalidate(juryDashboardProvider);
  ref.invalidate(juryDashboardProgressProvider);
  ref.invalidate(juryFairAssignmentProvider);
  ref.invalidate(juryFairInPreviewProvider);
  ref.invalidate(fairProjectsProvider);
  ref.invalidate(myEvaluationsProvider);
  ref.invalidate(juryProgressProvider);
  ref.invalidate(juryVotingStatusProvider);
  ref.invalidate(declarationFormProvider);
  ref.invalidate(rubricFormProvider);
  ref.invalidate(votingFormProvider);
  ref.invalidate(teachingListControllerProvider);
  ref.invalidate(evaluateTeacherControllerProvider);
  ref.invalidate(teacherResultsProvider);
  ref.invalidate(teacherEvaluationProgressProvider);
  ref.invalidate(adviserProjectsProvider);
  ref.invalidate(studentProjectsProvider);
  ref.invalidate(myCertificatesProvider);
  ref.invalidate(twoFactorControllerProvider);

  final images = PaintingBinding.instance.imageCache;
  images.clear();
  images.clearLiveImages();
}
