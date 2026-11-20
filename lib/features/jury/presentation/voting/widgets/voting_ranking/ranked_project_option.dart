// ranked_project_option.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart'
    show AppRadii, AppSpacing;
import 'package:campusvote_flutter/core/widgets/app_motion.dart'
    show AppMotion;
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart'
    show FairProjectModel;

/// Opción de proyecto en el ranking de votación.
class RankedProjectOption extends StatelessWidget {
  const RankedProjectOption({
    super.key,
    required this.project,
    required this.rank,
    required this.score,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FairProjectModel project;
  final int? rank;
  final double? score;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration =
        AppMotion.reduced(context) ? Duration.zero : AppMotion.medium;
    final copy = SettingsCopy.of(context);

    final label = [
      if (rank != null) copy.rank(rank, false),
      project.name,
      if (score != null)
        copy.isEnglish
            ? '${score!.toStringAsFixed(1)} out of 20'
            : '${score!.toStringAsFixed(1)} de 20'
      else
        copy.t('Sin evaluar'),
      copy.t(selected ? 'Seleccionado' : 'No seleccionado'),
    ].join('. ');

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppRadii.rLarge,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.08), scheme.surface)
                : scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _RankBadge(rank: rank),
              const SizedBox(width: AppSpacing.m),
              _Thumb(
                  url: project.coverUrl ?? project.logoUrl, name: project.name),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (project.categoryName != null)
                      Text(project.categoryName!,
                          style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.s),
                    _ScoreBar(score: score),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale:
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: Icon(
                  selected
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsRegular.circle,
                  key: ValueKey(selected),
                  size: 26,
                  color: selected ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int? rank;

  // Oro, plata y bronce para el podio; el resto en tono neutro.
  static const _podium = [
    Color(0xFFC9A227),
    Color(0xFF8E9AA6),
    Color(0xFFB0703C)
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final podium = rank != null && rank! <= 3;
    final color = podium ? _podium[rank! - 1] : scheme.onSurfaceVariant;
    return SizedBox(
      width: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (podium) Icon(PhosphorIconsFill.medal, size: 18, color: color),
          Text(
            rank == null ? '—' : '$rank°',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    final placeholder = Center(
      child: Text(
        initial,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final src = url;

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AppRadii.rMedium,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: (src == null || src.isEmpty)
          ? placeholder
          : Image.network(
              src,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});

  final double? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);

    if (score == null) {
      return Text(
        copy.t('Sin evaluar'),
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    final value = (score! / 20).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          '${score!.toStringAsFixed(1)}/20',
          style: theme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}