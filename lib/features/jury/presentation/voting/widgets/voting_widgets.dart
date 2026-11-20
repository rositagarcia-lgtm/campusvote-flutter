// voting_widgets.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart'
    show VotingStatusModel, VoteReceiptModel;

/// Vista del comprobante de voto (anónimo, no revela selección).
class VoteReceiptView extends StatelessWidget {
  const VoteReceiptView({super.key, required this.receipt});

  final VoteReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.lockSimple, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.s),
              Text(
                copy.t('Voto registrado'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            copy.t(
              'Tu voto ha sido emitido y registrado de forma anónima. '
              'El comprobante confirma tu participación; no revela tu selección.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            copy.t('Código de comprobante'),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            receipt.receiptCode,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            copy.t('Estado: ${receipt.status}'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista de participación: ya votó en esta categoría/feria.
class VoteParticipationView extends StatelessWidget {
  const VoteParticipationView({super.key, required this.status});

  final VotingStatusModel status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);
    final votedAt = status.votedAt;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.checkCircle, color: theme.colorScheme.tertiary),
              const SizedBox(width: AppSpacing.s),
              Text(
                copy.t('Ya has votado'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            copy.t('Tu voto oficial ya fue emitido en esta categoría.'),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (votedAt != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              copy.t('Votaste el ${_formatDate(votedAt)}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}