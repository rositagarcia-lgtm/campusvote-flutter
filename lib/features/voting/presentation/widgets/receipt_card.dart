import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/voting_receipt.dart';

class ReceiptCard extends StatelessWidget {
  final VotingReceipt receipt;
  final String electionTitle;
  final DateTime? castAt;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.electionTitle,
    this.castAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd MMM yyyy HH:mm', 'es');

    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voto registrado',
                        style: theme.textTheme.titleLarge),
                    Text('Tu comprobante oficial',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _row(context, 'Elección', electionTitle),
          _row(context, 'Fecha y hora', df.format(castAt ?? DateTime.now())),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadii.rMedium,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Código de comprobante',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  receipt.receiptCode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Conserva este comprobante. No contiene información sobre tus selecciones.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.labelMedium),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}