import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_palette.dart';
import 'account_identity.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Identidad de la cuenta: avatar, nombre y correo.
///
/// No repite el título de la sección que la envuelve: el encabezado ya dice de
/// qué bloque se trata.
class AccountHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;

  const AccountHeaderCard({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      child: Row(
        children: [
          AccountAvatar(
            avatarUrl: avatarUrl,
            displayName: displayName,
            accent: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appMuted(isDark),
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
              Icon(Icons.lock_outline, color: theme.colorScheme.primary),
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
            icon: Icons.edit_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

/// Estado de la sesión y acción de cierre.
class SessionCard extends StatelessWidget {
  final VoidCallback onLogout;
  const SessionCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  SettingsCopy.of(context).t('Sesión activa'),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            SettingsCopy.of(context).t(
                'Cerrar la sesión invalidará los tokens guardados en este dispositivo.'),
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton.danger(
            label: SettingsCopy.of(context).t('Cerrar sesión'),
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
