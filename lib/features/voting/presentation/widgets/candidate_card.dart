import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/ballot.dart';

class CandidateCard extends StatelessWidget {
  final BallotOption option;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const CandidateCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = option.list;

    return Semantics(
      label: list?.name ?? option.label,
      selected: selected,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: AppRadii.rLarge,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          bordered: true,
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : null,
          child: Row(
            children: [
              if (list?.logoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    list!.logoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _avatarFallback(theme, list.name),
                  ),
                )
              else
                _avatarFallback(theme, list?.name ?? option.label),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list?.name ?? option.label,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((list?.acronym ?? '').isNotEmpty)
                      Text(
                        list!.acronym!,
                        style: theme.textTheme.labelMedium,
                      ),
                    if ((list?.motto ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        list!.motto!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme, String label) {
    final initials = label.trim().isEmpty
        ? '?'
        : label.trim()[0].toUpperCase();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}