import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Nota informativa sobre la verificación de seguridad en dos pasos del jurado.
///
/// El jurado no tiene cuenta autogestionada: el administrador crea la cuenta y
/// le envía las credenciales por correo. Antes de entrar, el sistema pide un
/// código enviado a ese mismo correo.
class JurySecurityNote extends StatelessWidget {
  const JurySecurityNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkWarningSoft : AppColors.warningSoft,
        borderRadius: AppRadii.rMedium,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: AppDimensions.iconMedium,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SettingsCopy.of(context).t('Verificaci\u00f3n de acceso'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  SettingsCopy.of(context).t(
                    'La verificaci\u00f3n adicional depende de la configuraci\u00f3n de tu cuenta.',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
