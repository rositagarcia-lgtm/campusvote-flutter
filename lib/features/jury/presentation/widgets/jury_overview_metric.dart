import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_motion.dart';

/// Cifra del resumen del jurado: ícono, valor y etiqueta.
class JuryOverviewMetric extends StatelessWidget {
  const JuryOverviewMetric({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: colors.primary.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: colors.primary),
          const SizedBox(height: AppSpacing.s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _countable(
              value,
              theme.textTheme.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cifras enteras ("3", "40%") cuentan al aparecer; textos como "Cargando"
/// se muestran tal cual.
Widget _countable(String value, TextStyle? style) {
  final match = RegExp(r'^(\d+)(%?)$').firstMatch(value);
  if (match == null) return Text(value, style: style);
  return CountUpText(
    value: int.parse(match.group(1)!),
    suffix: match.group(2)!,
    style: style,
  );
}
