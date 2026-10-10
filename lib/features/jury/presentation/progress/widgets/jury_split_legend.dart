import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../../settings/presentation/settings_copy.dart';

/// Indicador de proyectos evaluados frente a pendientes, con los dos conteos
/// reales del modelo. Si la feria no tiene proyectos evaluables, no inventa un
/// 0 %: lo dice con palabras.
class JurySplitLegend extends StatelessWidget {
  const JurySplitLegend({
    super.key,
    required this.evaluated,
    required this.pending,
  });

  final int evaluated;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = SettingsCopy.of(context);

    if (evaluated + pending == 0) {
      return Text(
        text.t('Esta feria aún no tiene proyectos evaluables'),
        style: theme.textTheme.bodySmall?.copyWith(color: appMuted(isDark)),
      );
    }

    return Semantics(
      label: text.isEnglish
          ? '$evaluated evaluated, $pending pending'
          : '$evaluated evaluados, $pending pendientes',
      excludeSemantics: true,
      child: Wrap(
        spacing: AppSpacing.m,
        runSpacing: AppSpacing.s,
        children: [
          _LegendItem(
            icon: PhosphorIconsFill.checkCircle,
            tone: AppTone.success,
            label: text.t('Evaluados'),
            value: evaluated,
          ),
          _LegendItem(
            icon: PhosphorIconsRegular.circle,
            tone: pending > 0 ? AppTone.warning : AppTone.neutral,
            label: text.t('Pendientes'),
            value: pending,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.tone,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final AppTone tone;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = appToneColors(
      tone,
      isDark: isDark,
      primary: theme.colorScheme.primary,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSmall, color: colors.fg),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: appMuted(isDark)),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$value',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.fg,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
