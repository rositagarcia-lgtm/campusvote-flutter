// voting_widgets.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_button.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/core/widgets/app_page_layout.dart';
import 'package:campusvote_flutter/core/widgets/app_status_chip.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart'
    show VotingStatusModel, VoteReceiptModel;

/// Vista del comprobante de voto (anónimo, no revela selección).
class VoteReceiptView extends StatelessWidget {
  const VoteReceiptView(
      {super.key, required this.receipt, required this.onReturn});

  final VoteReceiptModel receipt;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);

    final primary = theme.colorScheme.primary;
    return PageScrollBody(
      maxWidth: kFormMaxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.10),
                    ),
                    child: Icon(PhosphorIconsFill.checkCircle,
                        size: 48, color: primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Semantics(
                  header: true,
                  child: Text(
                    copy.t('Voto registrado'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  copy.isEnglish
                      ? 'Your vote was recorded successfully.'
                      : 'Tu voto fue registrado correctamente.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIconsRegular.clipboardText,
                              size: AppDimensions.iconMedium, color: primary),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: Text(copy.t('Comprobante'),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Semantics(
                        label: copy.receiptCode(receipt.receiptCode),
                        excludeSemantics: true,
                        child: SizedBox(
                          width: double.infinity,
                          child: SelectableText(
                            receipt.receiptCode,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Center(
                  child: StatusChip(
                    label: copy.t('Voto anónimo'),
                    tone: AppTone.primary,
                    icon: PhosphorIconsRegular.lockSimple,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  copy.t(
                      'El comprobante confirma tu participación; no revela tu selección.'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: copy.isEnglish ? 'Back to voting' : 'Volver a la votación',
            icon: PhosphorIconsRegular.arrowLeft,
            onPressed: onReturn,
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
