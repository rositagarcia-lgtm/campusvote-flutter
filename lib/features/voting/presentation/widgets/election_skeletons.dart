import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_skeleton.dart';

class ElectionCardSkeleton extends StatelessWidget {
  const ElectionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: AppSkeleton(width: 120, height: 12)),
              AppSkeleton(width: 60, height: 22),
            ],
          ),
          SizedBox(height: AppSpacing.s),
          AppSkeleton(width: double.infinity, height: 18),
          SizedBox(height: 6),
          AppSkeleton(width: 220, height: 18),
          SizedBox(height: AppSpacing.m),
          AppSkeleton(width: 180, height: 12),
        ],
      ),
    );
  }
}

class ElectionListSkeleton extends StatelessWidget {
  final int count;
  const ElectionListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (_, __) => const ElectionCardSkeleton(),
    );
  }
}