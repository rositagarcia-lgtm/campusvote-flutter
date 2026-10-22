import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/jury_models.dart';
import 'fair_phase_badge.dart';

class FairCardHeader extends StatelessWidget {
  const FairCardHeader({super.key, required this.fair});

  final FairAssignmentModel fair;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imageUrl = fair.imageUrl;
    final open = fair.phase == JuryPhase.live || fair.phase == JuryPhase.preview;
    if (imageUrl == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            scheme.primary.withValues(alpha: open ? 0.15 : 0.06),
            scheme.primary.withValues(alpha: open ? 0.04 : 0.02),
          ]),
        ),
        child: _StatusRow(phase: fair.phase, open: open),
      );
    }

    return SizedBox(
      height: 142,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            semanticLabel: 'Portada de ${fair.name}',
            errorBuilder: (_, __, ___) => ColoredBox(
              color: scheme.primaryContainer,
              child: Icon(PhosphorIconsRegular.imageBroken,
                  color: scheme.onPrimaryContainer),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.scrim.withValues(alpha: 0.10),
                  scheme.scrim.withValues(alpha: 0.54)
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.m,
            child: _StatusRow(phase: fair.phase, open: open, onImage: true),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(
      {required this.phase, required this.open, this.onImage = false});

  final JuryPhase phase;
  final bool open;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelColor = onImage ? scheme.surface : scheme.onSurfaceVariant;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.rLarge,
          ),
          child: Icon(
              open
                  ? PhosphorIconsRegular.calendarCheck
                  : PhosphorIconsRegular.calendarX,
              color: open ? scheme.primary : scheme.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text('FERIA ASIGNADA',
              style: theme.textTheme.labelSmall?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              )),
        ),
        FairPhaseBadge(phase: phase, onImage: onImage),
      ],
    );
  }
}
