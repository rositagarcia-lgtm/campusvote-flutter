import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Lista viva de los requisitos de contraseña.
///
/// Marca cada regla según la contraseña escrita; los íconos llevan el color del
/// acento cuando se cumplen y el tono secundario cuando faltan.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({
    super.key,
    required this.password,
    required this.accent,
  });

  final String password;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);
    final text = SettingsCopy.of(context);

    final rules = <(String, bool)>[
      (text.t('Mínimo 8 caracteres'), password.length >= 8),
      (text.t('Una minúscula'), RegExp(r'[a-z]').hasMatch(password)),
      (text.t('Una mayúscula'), RegExp(r'[A-Z]').hasMatch(password)),
      (text.t('Un número'), RegExp(r'\d').hasMatch(password)),
      (text.t('Un símbolo'), RegExp(r'[^A-Za-z0-9]').hasMatch(password)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.t('REQUISITOS'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.l,
          runSpacing: AppSpacing.s,
          children: [
            for (final (label, met) in rules)
              Semantics(
                label:
                    '$label: ${met ? text.t('cumplido') : text.t('pendiente')}',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      met
                          ? PhosphorIconsFill.checkCircle
                          : PhosphorIconsRegular.circle,
                      size: AppDimensions.iconSmall,
                      color: met ? accent : muted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: met ? accent : muted,
                        fontWeight: met ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
