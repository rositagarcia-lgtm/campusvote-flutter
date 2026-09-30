import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';

/// Opción de proyecto en la votación: fila seleccionable con indicador de
/// selección, nombre y categoría.
///
/// El indicador es un ícono y no un `Radio` porque la pantalla solo necesita
/// saber qué opción está elegida; la fila completa es el área táctil.
class VotingProjectOption extends StatelessWidget {
  const VotingProjectOption({
    super.key,
    required this.project,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FairProjectModel project;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: enabled,
      label: project.categoryName == null
          ? project.name
          : '${project.name}. ${project.categoryName}',
      excludeSemantics: true,
      child: AppCard(
        color: selected ? theme.colorScheme.primaryContainer : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? accent : theme.disabledColor,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (project.categoryName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      project.categoryName!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Comprobante del voto: confirma que quedó registrado y muestra el código
/// para copiarlo.
class VoteReceiptView extends StatelessWidget {
  const VoteReceiptView({super.key, required this.receipt});

  final VoteReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Icon(
            Icons.verified_rounded,
            size: AppDimensions.iconLarge * 2.5,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.l),
          Semantics(
            header: true,
            child: Text(
              'Voto registrado',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Guarda este comprobante. No muestra por quién votaste, '
            'solo que participaste.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          AppCard(
            child: Column(
              children: [
                Text('Comprobante', style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Semantics(
                  label: 'Código de comprobante ${receipt.receiptCode}',
                  excludeSemantics: true,
                  child: SelectableText(
                    receipt.receiptCode,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const Center(
            child: StatusChip(
              label: 'Voto anónimo',
              tone: AppTone.success,
              icon: Icons.lock_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
