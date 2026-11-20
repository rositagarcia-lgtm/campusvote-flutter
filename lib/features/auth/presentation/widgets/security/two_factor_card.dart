import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_notice.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../domain/entities/totp.dart';
import '../../../../settings/presentation/settings_copy.dart';

/// Estado de la verificación en dos pasos. Solo informa si está activa.
class TwoFactorCard extends StatelessWidget {
  final TotpStatus status;
  final bool loading;
  final String? errorMessage;

  const TwoFactorCard({
    super.key,
    required this.status,
    required this.loading,
    required this.errorMessage,
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
                : 'La verificación en dos pasos está desactivada en esta cuenta.'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: appMuted(isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
