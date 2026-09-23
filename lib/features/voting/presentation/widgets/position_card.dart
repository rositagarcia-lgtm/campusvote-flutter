import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';

class PositionCard extends StatelessWidget {
  final String name;
  final String? description;
  final int seats;
  final Widget child;

  const PositionCard({
    super.key,
    required this.name,
    required this.description,
    required this.seats,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: theme.textTheme.titleLarge),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$seats plaza${seats == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if ((description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.m),
          child,
        ],
      ),
    );
  }
}