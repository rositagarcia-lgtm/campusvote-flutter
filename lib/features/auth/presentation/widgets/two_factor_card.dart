import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/totp.dart';

/// Estado de la verificación en dos pasos con su acción principal.
///
/// Activo o inactivo se lee de un vistazo por el chip de tono; el error se
/// muestra en línea con [AppNotice] para no anidar un bloque desplazable
/// dentro del scroll de la pantalla.
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
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: theme.colorScheme.primary,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Verificación en dos pasos (2FA)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: AppSpacing.l,
                  height: AppSpacing.l,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                StatusChip(
                  label: status.enabled ? 'Activo' : 'Inactivo',
                  icon: status.enabled
                      ? Icons.verified_user_rounded
                      : Icons.lock_open_rounded,
                  tone: status.enabled ? AppTone.success : AppTone.neutral,
                ),
            ],
          ),
          if (errorMessage != null && !status.enabled) ...[
            const SizedBox(height: AppSpacing.m),
            NoticeBanner(
              tone: AppTone.danger,
              message: errorMessage!,
              liveRegion: true,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Text(
            status.enabled
                ? '2FA está activo. Al iniciar sesión, además de tu contraseña '
                    'deberás ingresar un código de 6 dígitos de tu aplicación '
                    'autenticadora.'
                : 'Agrega una capa extra de seguridad. Al iniciar sesión, '
                    'además de tu contraseña deberás ingresar un código de '
                    'tu aplicación autenticadora.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: appMuted(isDark),
              height: 1.5,
            ),
          ),
          if (status.enabled) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Códigos de respaldo restantes: '
              '${status.backupCodesRemaining}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
