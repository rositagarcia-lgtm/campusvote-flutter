import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';
import 'voting_countdown.dart';

/// Tarjeta de feria: franja de estado, datos, cuenta regresiva y acción.
class FairCard extends StatelessWidget {
  const FairCard({super.key, required this.fair});

  final FairAssignmentModel fair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final muted = appMuted(isDark);
    final enabled = fair.isOpen;
    final stripe = appToneColors(
      enabled ? AppTone.success : AppTone.neutral,
      isDark: isDark,
      primary: accent,
    ).fg;
    final status = switch (fair.status) {
      FairStatus.open => 'Abierta',
      FairStatus.draft => 'En preparación',
      FairStatus.closed => 'Cerrada',
      FairStatus.unknown => 'Sin estado',
    };
    final site = fair.siteName;

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: enabled
          ? '${fair.name}. $status. Ver proyectos de tu categoría'
          : '${fair.name}. $status. Esta feria no está disponible',
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: appBorder(isDark)),
        ),
        child: InkWell(
          onTap:
              enabled ? () => context.push('/jury/fair/${fair.fairId}') : null,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: stripe),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fair.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (site != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(Icons.place_outlined,
                                  size: AppDimensions.iconSmall, color: muted),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  site,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: muted),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.m),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: [
                            StatusChip(
                              label: status,
                              tone: enabled ? AppTone.success : AppTone.neutral,
                              showDot: true,
                            ),
                            if (enabled)
                              const StatusChip(
                                label: 'Votación y rúbrica',
                                tone: AppTone.info,
                                icon: Icons.how_to_vote_outlined,
                              ),
                          ],
                        ),
                        // `endsAt`/`startsAt` vienen de la asignación; si la
                        // feria no trae fechas, el contador se oculta en vez
                        // de inventar una.
                        if (enabled) ...[
                          const SizedBox(height: AppSpacing.m),
                          VotingCountdown(
                            startsAt: fair.startsAt,
                            endsAt: fair.endsAt,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.m),
                        Divider(
                            height: 1, thickness: 1, color: appBorder(isDark)),
                        const SizedBox(height: AppSpacing.m),
                        if (enabled)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Ver proyectos de tu categoría',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: AppDimensions.iconMedium,
                                color: accent,
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: AppDimensions.iconMedium,
                                color: muted,
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Text(
                                  'Esta feria no está disponible',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
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
