import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';
import '../../../settings/presentation/settings_copy.dart';

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
          const Center(child: SuccessMark()),
          const SizedBox(height: AppSpacing.l),
          Semantics(
            header: true,
            child: Text(
              SettingsCopy.of(context).t('Voto registrado'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
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
              icon: PhosphorIconsRegular.lockSimple,
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
            PhosphorIconsRegular.sealCheck,
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
            icon: PhosphorIconsRegular.info,
          ),
        ],
      ),
    );
  }
}
