import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';
import '../../../settings/presentation/settings_copy.dart';

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
    final accessibleLabel = [
      project.name,
      if (project.categoryName != null) project.categoryName!,
      SettingsCopy.of(context).t(selected ? 'Seleccionado' : 'No seleccionado'),
    ].join('. ');

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      label: accessibleLabel,
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
                  if (selected) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      SettingsCopy.of(context).t('Seleccionado'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
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
              SettingsCopy.of(context).t('Voto registrado'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            SettingsCopy.of(context).t(
                'Guarda este comprobante. No muestra por quién votaste, solo que participaste.'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          AppCard(
            child: Column(
              children: [
                Text(SettingsCopy.of(context).t('Comprobante'),
                    style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Semantics(
                  label:
                      SettingsCopy.of(context).receiptCode(receipt.receiptCode),
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
          Center(
            child: StatusChip(
              label: SettingsCopy.of(context).t('Voto anónimo'),
              tone: AppTone.success,
              icon: Icons.lock_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

/// La consulta de estado confirma participación cuando el POST tuvo una
/// respuesta ambigua. No se inventa ni se vuelve a mostrar un comprobante.
class VoteParticipationView extends StatelessWidget {
  const VoteParticipationView({super.key, required this.status});

  final VotingStatusModel status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final votedAt = status.votedAt;
    final text = SettingsCopy.of(context);

    return PageScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Icon(
            Icons.verified_outlined,
            size: AppDimensions.iconLarge * 2,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.l),
          Semantics(
            header: true,
            child: Text(
              text.t('Participación confirmada'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            text.t(
                'El servidor confirma que ya emitiste tu voto en esta feria. No es posible volver a votar.'),
            textAlign: TextAlign.center,
          ),
          if (votedAt != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              text.votedOn(votedAt),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          NoticeBanner(
            message: text.t(
                'No se recibió un comprobante para esta respuesta. Tu selección permanece anónima y no se puede recuperar desde la app.'),
            tone: AppTone.info,
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }
}
