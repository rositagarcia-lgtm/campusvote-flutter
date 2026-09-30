import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';

/// Confirmación de evaluación enviada.
class TeacherEvaluationSuccessPage extends ConsumerWidget {
  final String assignmentId;
  const TeacherEvaluationSuccessPage({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Evaluación enviada',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/teaching'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.brandPrimarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: context.brandPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Gracias por tu evaluación',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Tu respuesta fue registrada de forma anónima y no puede '
                'ser modificada. La institución la usará como insumo para '
                'mejorar la enseñanza.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              AppButton(
                label: 'Volver a mis docentes',
                icon: Icons.school_rounded,
                onPressed: () => context.go('/teaching'),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'No puedes evaluar dos veces al mismo docente y curso.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkFaint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
