import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';

class BallotProgress extends StatelessWidget {
  final int current;
  final int total;
  final String label;

  const BallotProgress({
    super.key,
    required this.current,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total == 0 ? 0.0 : (current / total).clamp(0, 1).toDouble();
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: theme.textTheme.titleSmall),
              ),
              Text('$current / $total',
                  style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: theme.dividerColor,
              valueColor:
                  AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}