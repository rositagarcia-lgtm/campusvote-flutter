import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../state/teaching_list_controller.dart';

/// Confirmación visible únicamente cuando las asignaciones confirman el envío.
class TeacherEvaluationSuccessPage extends ConsumerWidget {
  const TeacherEvaluationSuccessPage({
    super.key,
    required this.assignmentId,
  });

  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(teachingListControllerProvider).items;
    final confirmed = assignments.any(
      (assignment) => assignment.id == assignmentId && assignment.evaluated,
    );
    final text = SettingsCopy.of(context);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: confirmed
            ? text.t('Evaluación registrada')
            : text.t('Estado de evaluación'),
        leading: IconButton(
          tooltip: text.t('Volver a mis docentes'),
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.go('/teaching'),
        ),
      ),
      body: confirmed
          ? _ConfirmedEvaluation(onReturn: () => context.go('/teaching'))
          : AppEmptyView(
              icon: PhosphorIconsRegular.cloudArrowUp,
              title: text.t('No hay confirmación del servidor'),
              message: text.t(
                  'No podemos mostrar esta evaluación como completada. Vuelve a tus docentes y actualiza la lista para consultar el estado real.'),
              actionLabel: text.t('Volver a mis docentes'),
              onAction: () => context.go('/teaching'),
              overline: text.t('ESTADO PENDIENTE'),
            ),
    );
  }
}

class _ConfirmedEvaluation extends StatelessWidget {
  const _ConfirmedEvaluation({required this.onReturn});

  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SuccessMark(),
                const SizedBox(height: AppSpacing.xl),
                Semantics(
                  liveRegion: true,
                  header: true,
                  child: Text(
                    SettingsCopy.of(context).t('Evaluación registrada'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  SettingsCopy.of(context).t(
                      'El servidor ya muestra esta asignación como completada.'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: SettingsCopy.of(context).t('Volver a mis docentes'),
                  icon: PhosphorIconsRegular.graduationCap,
                  onPressed: onReturn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
