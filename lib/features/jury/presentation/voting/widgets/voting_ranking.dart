import 'package:flutter/material.dart';

import '../../../../../core/branding/organization_branding.dart';
import '../../../../../core/config/app_env.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/brand_colors.dart';
import '../../../../../core/widgets/app_logo.dart';
import '../../../../../core/widgets/app_motion.dart';
import '../../../data/models/jury_models.dart';
import '../../widgets/voting_countdown.dart';

/// Cabecera de la votación con la identidad de la organización: se siente
/// como el momento oficial de la feria, no como un formulario más.
class VotingHero extends StatelessWidget {
  const VotingHero({
    super.key,
    required this.branding,
    required this.fairName,
    required this.status,
  });

  final OrganizationBranding branding;
  final String? fairName;
  final VotingStatusModel status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBrand = BrandContrast.onColor(theme.colorScheme.primary);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: AppRadii.rXLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.rMedium,
                ),
                child: AppLogo.organization(
                  logoUrl: branding.logoUrl,
                  organizationCode: branding.name,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  'VOTACIÓN OFICIAL · ${branding.name.toUpperCase()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onBrand.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            fairName ?? 'Votación de la feria',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: onBrand,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Un voto por jurado. Es anónimo y no se puede cambiar.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onBrand.withValues(alpha: 0.85),
            ),
          ),
          if (status.endsAt != null || status.startsAt != null) ...[
            const SizedBox(height: AppSpacing.m),
            DefaultTextStyle.merge(
              style: TextStyle(color: onBrand),
              child: VotingCountdown(
                endsAt: status.endsAt,
                startsAt: status.startsAt,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Explica el orden: es el propio criterio del jurado, no el ranking oficial.
class VotingRankingHeader extends StatelessWidget {
  const VotingRankingHeader(
      {super.key, required this.scored, required this.total});

  final int scored;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(PhosphorIconsRegular.trendUp, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu ranking por rúbrica',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                scored == 0
                    ? 'Aún no finalizas rúbricas en esta feria. Puedes votar igual.'
                    : 'Ordenado de mayor a menor según las $scored de $total rúbricas '
                        'que finalizaste. Solo tú lo ves.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de proyecto votable con posición, portada y puntaje propio.
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
    final label = [
      if (rank != null) 'Puesto $rank',
      project.name,
      if (score != null)
        '${score!.toStringAsFixed(1)} de 20'
      else
        'Sin evaluar',
      selected ? 'Seleccionado' : 'No seleccionado',
    ].join('. ');

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: enabled ? onTap : null,
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
    final resolved = AppEnv.mediaUrl(url);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: context.brandGradient),
      child: Center(
        child: Text(
          name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
          style: const TextStyle(
              color: AppColors.inkInverse, fontWeight: FontWeight.w800),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: AppRadii.rMedium,
      child: SizedBox(
        width: 52,
        height: 52,
        child: resolved == null
            ? fallback
            : Image.network(resolved,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}

/// Barra del puntaje propio (sobre 20) que se llena al aparecer.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});

  final double? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (score == null) {
      return Text(
        'Sin evaluar',
        style: theme.textTheme.labelSmall
            ?.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (score! / 20).clamp(0, 1)),
              duration:
                  AppMotion.reduced(context) ? Duration.zero : AppMotion.slow,
              curve: AppMotion.emphasized,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                color: scheme.primary,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
              ),
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
