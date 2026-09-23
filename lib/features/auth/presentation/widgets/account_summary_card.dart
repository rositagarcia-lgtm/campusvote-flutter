import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

/// Tarjeta con la información de la cuenta (avatar + nombre + email).
class AccountHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;

  const AccountHeaderCard({
    super.key,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : 'C';

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            radius: 24,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(email, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de cambio de contraseña (CTA simple).
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
              const Icon(Icons.lock_outline, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s),
              Text('Contraseña', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Mantén tu contraseña fuerte. Se requieren 8+ caracteres con '
            'mayúscula, minúscula, número y símbolo.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton.outlined(
            label: 'Cambiar contraseña',
            icon: Icons.edit_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de sesión con CTA de logout.
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
              const Icon(Icons.logout_rounded, color: AppColors.danger),
              const SizedBox(width: AppSpacing.s),
              Text('Sesión', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Cerrar la sesión invalidará los tokens guardados en este '
            'dispositivo.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton.danger(
            label: 'Cerrar sesión',
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}