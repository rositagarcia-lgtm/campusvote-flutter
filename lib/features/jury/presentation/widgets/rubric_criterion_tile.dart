import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';

/// Casilla de un criterio de la rúbrica.
///
/// El backend es un CHECKLIST (`checked` booleano), no un slider. Al marcar,
/// el borde toma el color institucional y el check entra con un rebote: el
/// jurado ve de inmediato que el toque quedó registrado.
class RubricCriterionTile extends StatelessWidget {
  const RubricCriterionTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.enabled = true,
    this.position,
  });

  final String title;
  final String? description;
  final bool value;
  final int? position;

  /// `false` cuando la hoja ya se finalizó: el backend responde 409.
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration =
        AppMotion.reduced(context) ? Duration.zero : AppMotion.medium;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Semantics(
        checked: value,
        enabled: enabled,
        label: position != null ? '$position. $title' : title,
        hint: description,
        onTap: enabled ? () => onChanged(!value) : null,
        excludeSemantics: true,
        child: Pressable(
          onTap: enabled ? () => onChanged(!value) : null,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.emphasized,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: value
                  ? Color.alphaBlend(
                      scheme.primary.withValues(alpha: 0.08),
                      scheme.surface,
                    )
                  : scheme.surface,
              borderRadius: AppRadii.rLarge,
              border: Border.all(
                color: value ? scheme.primary : scheme.outlineVariant,
                width: value ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckBubble(
                  checked: value,
                  position: position,
                  enabled: enabled,
                  duration: duration,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(description!, style: theme.textTheme.bodySmall),
                      ],
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

/// Número del criterio que se convierte en check al marcarlo.
class _CheckBubble extends StatelessWidget {
  const _CheckBubble({
    required this.checked,
    required this.position,
    required this.enabled,
    required this.duration,
  });

  final bool checked;
  final int? position;
  final bool enabled;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.emphasized,
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? scheme.primary : scheme.surface,
        border: Border.all(
          color: checked
              ? scheme.primary
              : enabled
                  ? scheme.outline
                  : scheme.outlineVariant,
          width: 1.6,
        ),
      ),
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        ),
        child: checked
            ? Icon(
                PhosphorIconsBold.check,
                key: const ValueKey('on'),
                size: 16,
                color: scheme.onPrimary,
              )
            : Text(
                position?.toString() ?? '',
                key: const ValueKey('off'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
