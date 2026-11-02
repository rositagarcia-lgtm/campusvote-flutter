// voting/widgets/vote_confirm_dialog.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/translatable_text.dart';
import '../../../../settings/presentation/settings_copy.dart';
import '../../../data/models/jury_models.dart';

/// Confirmación del voto oficial.
///
/// Muestra la selección con los datos reales del proyecto y advierte que el
/// voto es único. No revela el sentido del voto en ningún comprobante.
Future<bool> confirmVoteDialog(
  BuildContext context, {
  required String? fairName,
  required FairProjectModel project,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final copy = SettingsCopy.of(dialogContext);
      return AlertDialog(
      scrollable: true,
      title: Text(copy.t('Confirma tu voto oficial')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              copy.t(
                'Revisa la selección. Después de enviarlo, no podrás cambiar ni repetir tu voto.',
              ),
            ),
            if (fairName != null) ...[
              const SizedBox(height: AppSpacing.l),
              Text(
                copy.t('Feria'),
                style: Theme.of(dialogContext).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(fairName, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: AppSpacing.l),
            Text(
              copy.t('Proyecto'),
              style: Theme.of(dialogContext).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              project.name,
              style: Theme.of(dialogContext)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (project.description.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              TranslatableText(
                project.description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (project.categoryName != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(project.categoryName!),
            ],
            const SizedBox(height: AppSpacing.m),
            Text(
              copy.t(
                'El comprobante confirma tu participación; no revela tu selección.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(copy.t('Volver')),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          icon: const Icon(PhosphorIconsRegular.lockSimple),
          label: Text(copy.t('Confirmar voto')),
        ),
      ],
    );
    },
  );
  return confirmed == true;
}
