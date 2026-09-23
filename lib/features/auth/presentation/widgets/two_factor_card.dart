import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/totp.dart';

class TwoFactorCard extends StatelessWidget {
  final TotpStatus status;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSetup;
  final VoidCallback onDisable;

  const TwoFactorCard({
    super.key,
    required this.status,
    required this.loading,
    required this.errorMessage,
    required this.onSetup,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Verificación en dos pasos (2FA)',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (status.enabled)
                const AppBadge(
                  label: 'Activo',
                  icon: Icons.verified_user_rounded,
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                )
              else
                const AppBadge(
                  label: 'Inactivo',
                  icon: Icons.lock_open_rounded,
                  background: Color(0xFFEAEAF2),
                  foreground: AppColors.inkMuted,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (errorMessage != null && !status.enabled)
            AppErrorView(message: errorMessage!),
          Text(
            status.enabled
                ? '2FA está activo. Al iniciar sesión, además de tu contraseña '
                    'deberás ingresar un código de 6 dígitos de tu aplicación '
                    'autenticadora.'
                : 'Agrega una capa extra de seguridad. Al iniciar sesión, '
                    'además de tu contraseña deberás ingresar un código de '
                    'tu aplicación autenticadora.',
            style: theme.textTheme.bodySmall,
          ),
          if (status.enabled) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Códigos de respaldo restantes: '
              '${status.backupCodesRemaining}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          if (status.enabled)
            AppButton.danger(
              label: 'Deshabilitar 2FA',
              icon: Icons.lock_open_rounded,
              onPressed: onDisable,
            )
          else
            AppButton(
              label: 'Configurar 2FA',
              icon: Icons.qr_code_2_rounded,
              onPressed: onSetup,
            ),
        ],
      ),
    );
  }
}