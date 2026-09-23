import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/ballot.dart';

class VoteSummary extends StatelessWidget {
  final List<BallotPosition> positions;
  final Map<String, List<String>> selections;

  List<BallotOption> options(BallotPosition p) =>
      p.options.where((o) => (selections[p.id] ?? const []).contains(o.id)).toList();

  const VoteSummary({super.key, required this.positions, required this.selections});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd MMM yyyy HH:mm', 'es');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: Row(
            children: [
              const Icon(Icons.fact_check_outlined,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Resumen de tu voto',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                df.format(DateTime.now()),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        for (final p in positions) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.position.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s),
                if (options(p).isEmpty)
                  Text(
                    'Sin selección',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  )
                else
                  for (final o in options(p)) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              o.list?.name ?? o.label,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}