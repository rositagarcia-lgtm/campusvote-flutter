import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/election.dart';
import 'election_status_badge.dart';

class ElectionCard extends StatelessWidget {
  final Election election;
  final VoidCallback onTap;

  const ElectionCard({
    super.key,
    required this.election,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd MMM y', 'es');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  election.organizationName ?? 'Organización',
                  style: theme.textTheme.labelMedium,
                ),
              ),
              ElectionStatusBadge(election: election),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            election.title,
            style: theme.textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (election.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              election.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: AppDimensions.iconSmall),
              const SizedBox(width: 6),
              Text(
                '${df.format(election.startAt)} → ${df.format(election.endAt)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}