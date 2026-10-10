import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_button.dart';
import 'app_page_layout.dart';
import 'app_palette.dart';
import 'app_status_chip.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Estado de error con reintento.
///
/// El mensaje explica el fallo y la acción de reintento siempre está
/// disponible; el cuerpo es desplazable para que el gesto de recargar del
/// contenedor siga funcionando.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = PhosphorIconsRegular.cloudSlash,
    this.title = 'No pudimos cargar la información',
    this.overline = 'ESTADO DE ERROR',
    this.retryLabel = 'Reintentar',
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String title;

  /// Etiqueta en versalitas sobre el mensaje.
  final String overline;

  /// Texto del botón de reintento.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tone = appToneColors(AppTone.danger, isDark: isDark);
    final text = SettingsCopy.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kFormMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimensions.touchTarget,
                height: AppDimensions.touchTarget,
                decoration: BoxDecoration(
                  color: tone.bg,
                  borderRadius: AppRadii.rMedium,
                ),
                child: Icon(
                  icon,
                  // Microajuste: la ilustración necesita respirar dentro del
                  // cuadro táctil de 44.
                  size: AppDimensions.iconLarge * 1.25,
                  color: isDark ? tone.fg : AppColors.danger,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Semantics(
                header: true,
                child: Column(
                  children: [
                    Text(
                      text.t(overline),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: appMuted(isDark),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      text.t(title),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                text.error(message),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton.outlined(
                  label: text.t(retryLabel),
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
