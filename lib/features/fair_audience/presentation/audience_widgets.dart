import 'package:flutter/material.dart';

import '../../../core/config/app_env.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/app_motion.dart';
import '../domain/audience_models.dart';

/// Portada o inicial del proyecto, con el degradado de la organización.
class AudienceThumb extends StatelessWidget {
  const AudienceThumb({super.key, required this.project, this.size = 64});

  final AudienceProject project;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = AppEnv.mediaUrl(project.coverUrl ?? project.logoUrl);
    final name = project.name.trim();
    final fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: context.brandGradient),
      child: Center(
        child: Text(
          name.isEmpty ? '?' : name[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.inkInverse,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: AppRadii.rMedium,
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? fallback
            : Image.network(url,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}

/// Estrellas pequeñas de solo lectura.
class MiniStars extends StatelessWidget {
  const MiniStars({super.key, required this.value, this.size = 14});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i - 0.25
                ? PhosphorIconsFill.star
                : PhosphorIconsRegular.star,
            size: size,
            color: color,
          ),
      ],
    );
  }
}

/// Tarjeta de un proyecto de la feria para el público.
class AudienceProjectCard extends StatelessWidget {
  const AudienceProjectCard({
    super.key,
    required this.project,
    required this.minVotes,
    required this.canRate,
    required this.onTap,
    this.isFavorite = false,
  });

  final AudienceProject project;
  final int minVotes;
  final bool canRate;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meta = [
      if (project.category != null) project.category!,
      if (project.stand != null) 'Stand ${project.stand}',
    ].join(' · ');
    final average = project.average;
    final status = project.isMine
        ? 'Tu proyecto'
        : project.myScore != null
            ? 'Tu voto: ${project.myScore} ★'
            : canRate
                ? 'Calificar'
                : 'Sin voto';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Semantics(
        button: true,
        label: '${project.name}. $status',
        child: Pressable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadii.rLarge,
              border: Border.all(
                color: isFavorite ? AppColors.accent : scheme.outlineVariant,
                width: isFavorite ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AudienceThumb(project: project),
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
                      if (meta.isNotEmpty)
                        Text(meta, style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      if (average != null)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.xs,
                          children: [
                            MiniStars(value: average),
                            Text(
                              '${average.toStringAsFixed(1)} · ${project.votes} votos',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        )
                      else
                        Text(
                          project.votes == 0
                              ? 'Aún sin votos'
                              : 'Promedio desde $minVotes votos',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      // Debajo y no a la derecha: en 320 px las estrellas
                      // necesitan todo el ancho de la columna.
                      Text(
                        status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: project.isMine || project.myScore == null
                              ? scheme.onSurfaceVariant
                              : scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Favorito del público al cerrar la feria (no es el resultado oficial).
class FavoriteBanner extends StatelessWidget {
  const FavoriteBanner({super.key, required this.project});

  final AudienceProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.medal,
              color: AppColors.accent, size: 32),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAVORITO DEL PÚBLICO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  project.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Elegido por los alumnos. No reemplaza el resultado del jurado.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
