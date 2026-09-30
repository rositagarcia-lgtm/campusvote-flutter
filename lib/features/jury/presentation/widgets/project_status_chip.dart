import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Estado del proyecto dentro de la feria (`APPROVED`, `SUBMITTED`, …).
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status.toUpperCase()) {
      'APPROVED' => ('Aprobado', AppColors.successSoft, AppColors.success),
      'SUBMITTED' => ('En revisión', AppColors.warningSoft, AppColors.warning),
      'IN_REVIEW' => ('En revisión', AppColors.warningSoft, AppColors.warning),
      'REJECTED' => ('Rechazado', AppColors.dangerSoft, AppColors.danger),
      'DRAFT' => ('Borrador', AppColors.background, AppColors.inkFaint),
      _ => (status, AppColors.background, AppColors.inkFaint),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.rSmall),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
