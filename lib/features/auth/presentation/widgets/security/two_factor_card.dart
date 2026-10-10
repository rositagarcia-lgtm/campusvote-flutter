import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_notice.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../domain/entities/totp.dart';
import '../../../../settings/presentation/settings_copy.dart';

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
    final text = SettingsCopy.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.shieldCheck,
                color: theme.colorScheme.primary,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  text.t('Verificación en dos pasos (2FA)'),
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
                  label: status.enabled ? text.t('Activo') : text.t('Inactivo'),
                  icon: status.enabled
                      ? PhosphorIconsFill.shieldCheck
                      : PhosphorIconsRegular.lockSimpleOpen,
                  tone: status.enabled ? AppTone.success : AppTone.neutral,
                ),
            ],
          ),
          if (errorMessage != null && !status.enabled) ...[
            const SizedBox(height: AppSpacing.m),
            NoticeBanner(
              tone: AppTone.danger,
              message: text.error(errorMessage!),
              liveRegion: true,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Text(
            text.t(status.enabled
                ? '2FA está activo. Al iniciar sesión, además de tu contraseña '
                    'deberás ingresar un código de 6 dígitos de tu aplicación '
                    'autenticadora.'
                : 'Agrega una capa extra de seguridad. Al iniciar sesión, '
                    'además de tu contraseña deberás ingresar un código de '
                    'tu aplicación autenticadora.'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: appMuted(isDark),
              height: 1.5,
            ),
          ),
          if (status.enabled) ...[
            const SizedBox(height: AppSpacing.m),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: (isDark ? Colors.orange : Colors.orange)
                    .withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: AppRadii.rMedium,
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.key,
                      size: AppDimensions.iconMedium,
                      color: isDark ? Colors.orange[300] : Colors.orange[800]),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      text.isEnglish
                          ? 'Backup codes remaining: ${status.backupCodesRemaining}'
                          : 'Códigos de respaldo restantes: ${status.backupCodesRemaining}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.orange[200] : Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          if (status.enabled)
            AppButton.danger(
              label: text.t('Deshabilitar 2FA'),
              icon: PhosphorIconsRegular.lockSimpleOpen,
              onPressed: onDisable,
            )
          else
            AppButton(
              label: text.t('Configurar 2FA'),
              icon: PhosphorIconsRegular.qrCode,
              onPressed: onSetup,
            ),
        ],
      ),
    );
  }
}
