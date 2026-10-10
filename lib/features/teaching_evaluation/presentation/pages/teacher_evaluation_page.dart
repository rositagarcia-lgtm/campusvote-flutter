import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../state/evaluate_controller.dart';
import '../state/teaching_list_controller.dart';
import '../widgets/teacher_evaluation_views.dart';
import '../widgets/teacher_rating_selector.dart';

part 'teacher_evaluation_state.dart';

/// Formulario de calificación general y comentario opcional del estudiante.
class TeacherEvaluationPage extends ConsumerStatefulWidget {
  const TeacherEvaluationPage({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<TeacherEvaluationPage> createState() =>
      _TeacherEvaluationPageState();
}
