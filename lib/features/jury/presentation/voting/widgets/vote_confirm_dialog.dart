// voting/widgets/vote_confirm_dialog.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_card.dart';
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
      final primary = Theme.of(dialogContext).colorScheme.primary;
      return AlertDialog(
        scrollable: true,
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rXLarge),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(PhosphorIconsFill.checkCircle, size: 40, color: primary),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(copy.t('Confirma tu voto oficial'),
                textAlign: TextAlign.center),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                copy.t(
                  'Revisa la selección. Después de enviarlo, no podrás cambiar ni repetir tu voto.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fairName != null) ...[
                      _DetailRow(
                        icon: PhosphorIconsRegular.calendarCheck,
                        label: copy.t('Feria'),
                        child: TranslatableText(fairName),
                      ),
                      const Divider(height: AppSpacing.xl),
                    ],
                    _DetailRow(
                      icon: PhosphorIconsRegular.folderOpen,
                      label: copy.t('Proyecto'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ),
                    if (project.categoryName != null) ...[
                      const Divider(height: AppSpacing.xl),
                      _DetailRow(
                        icon: PhosphorIconsRegular.squaresFour,
                        label: copy.isEnglish ? 'Category' : 'Categoría',
                        child: Text(project.categoryName!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(PhosphorIconsRegular.info,
                      size: AppDimensions.iconMedium,
                      color: Theme.of(dialogContext).colorScheme.primary),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(copy.t(
                      'El comprobante confirma tu participación; no revela tu selección.',
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(copy.t('Volver')),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  flex: 3,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(copy.t('Confirmar voto'),
                        maxLines: 2, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.child});

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: AppDimensions.iconMedium, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: AppSpacing.xs),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
