import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../settings/presentation/settings_copy.dart';

const _ratingTapTarget = 48.0;

/// Calificación general de 1 a 5, expuesta como cinco controles accesibles.
class TeacherRatingSelector extends StatelessWidget {
  const TeacherRatingSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = context.brandPrimary;
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.48);
    final text = SettingsCopy.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            text.t('Calificación general'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value == 0
              ? text.t('Selecciona una calificación de 1 a 5.')
              : text.selectedRating(value),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            for (var score = 1; score <= 5; score++)
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    selected: value == score,
                    enabled: enabled,
                    label: text.ratingStars(score),
                    onTap: enabled ? () => onChanged(score) : null,
                    child: ExcludeSemantics(
                      child: InkResponse(
                        onTap: enabled ? () => onChanged(score) : null,
                        containedInkWell: true,
                        radius: 28,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: _ratingTapTarget,
                            minHeight: _ratingTapTarget,
                          ),
                          child: Center(
                            child: Icon(
                              score <= value
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 34,
                              color: score <= value
                                  ? selectedColor
                                  : unselectedColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
