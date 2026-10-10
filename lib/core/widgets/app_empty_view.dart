import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_dimensions.dart';
import 'app_button.dart';
import 'app_page_layout.dart';
import 'app_palette.dart';

/// Estado vacío: explica por qué no hay contenido y ofrece la acción que
/// corresponde, sin inventar datos.
///
/// El cuerpo es desplazable para que el gesto de recargar del contenedor
/// siga funcionando aunque el mensaje sea largo.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = PhosphorIconsRegular.tray,
    this.onAction,
    this.actionLabel,
    this.title,
    this.overline = 'SIN RESULTADOS',
  });

  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  /// Título opcional; si falta, solo se muestra el sobretítulo y el mensaje.
  final String? title;

  /// Etiqueta en versalitas sobre el mensaje; permite ajustar el estado sin
  /// duplicar el texto del título.
  final String overline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);

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
              Icon(
                icon,
                size: AppDimensions.iconLarge * 1.5,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.l),
              Semantics(
                header: true,
                child: Column(
                  children: [
                    Text(
                      overline,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    if (title != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton.outlined(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
