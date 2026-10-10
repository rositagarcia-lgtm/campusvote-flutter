import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../data/models/jury_models.dart';
import 'fair_card_header.dart';
import 'voting_countdown.dart';

/// Asignación de feria. La única acción navegable corresponde a una feria
/// abierta; las asignaciones cerradas o en preparación se presentan como
/// información para evitar sugerir una acción que no está disponible.
class FairCard extends StatelessWidget {
  const FairCard({super.key, required this.fair});

  final FairAssignmentModel fair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final muted = appMuted(isDark);
    final open = fair.isOpen;
    final status = switch (fair.status) {
      FairStatus.open => 'Abierta',
      FairStatus.draft => 'En preparación',
      FairStatus.closed => 'Cerrada',
      FairStatus.unknown => 'Estado sin confirmar',
    };

    return Semantics(
      container: true,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: open ? 1 : 0,
        shadowColor: accent.withValues(alpha: 0.14),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rXLarge,
          side: BorderSide(color: appBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FairCardHeader(fair: fair, status: status),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fair.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (fair.siteName case final site?) ...[
                    const SizedBox(height: AppSpacing.s),
                    _FairMetadata(
                      icon: PhosphorIconsRegular.mapPin,
                      text: site,
                    ),
                  ],
                  if (fair.description.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      fair.description.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                  if (open && fair.endsAt != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    VotingCountdown(
                      startsAt: fair.startsAt,
                      endsAt: fair.endsAt,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.m),
                  Divider(height: 1, color: appBorder(isDark)),
                  const SizedBox(height: AppSpacing.m),
                  if (open)
                    AppButton(
                      label: 'Abrir feria',
                      icon: PhosphorIconsRegular.arrowRight,
                      dense: true,
                      onPressed: () =>
                          context.push('/jury/fair/${fair.fairId}'),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.info,
                          size: AppDimensions.iconMedium,
                          color: muted,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            fair.status == FairStatus.closed
                                ? 'La participación en esta feria terminó.'
                                : 'Esta feria todavía no está disponible.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FairMetadata extends StatelessWidget {
  const _FairMetadata({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSmall, color: muted),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}
