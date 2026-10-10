import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../settings/presentation/settings_copy.dart';

/// Aviso de contraseña y acción para actualizarla.
class PasswordCard extends StatelessWidget {
  final VoidCallback onPressed;
  const PasswordCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.lockSimple,
                  color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  SettingsCopy.of(context).t('Tu contraseña'),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            SettingsCopy.of(context).t(
                'Mantén tu contraseña fuerte. Se requieren 8+ caracteres con mayúscula, minúscula, número y símbolo.'),
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton.outlined(
            label: SettingsCopy.of(context).t('Cambiar contraseña'),
            icon: PhosphorIconsRegular.pencilSimple,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
