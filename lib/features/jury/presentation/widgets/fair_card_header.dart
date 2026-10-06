import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';

class FairCardHeader extends StatelessWidget {
  const FairCardHeader({super.key, required this.fair, required this.status});

  final FairAssignmentModel fair;
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imageUrl = fair.imageUrl;
    final open = fair.isOpen;
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
        child: _StatusRow(status: status, open: open),
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
              child: Icon(Icons.image_not_supported_outlined,
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
            child: _StatusRow(status: status, open: open, onImage: true),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(
      {required this.status, required this.open, this.onImage = false});

  final String status;
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
              open ? Icons.event_available_outlined : Icons.event_busy_outlined,
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
        StatusChip(
          label: status,
          tone: open ? AppTone.primary : AppTone.neutral,
          icon: open
              ? Icons.radio_button_checked_rounded
              : Icons.lock_outline_rounded,
        ),
      ],
    );
  }
}
