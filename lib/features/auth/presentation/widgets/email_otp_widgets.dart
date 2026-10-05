import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_action_tile.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_qr_image.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Fila que confirma a qué correo se envió el código de un solo uso.
///
/// Evita que el usuario revise el código en una bandeja que no es la suya.
class SentToEmailRow extends StatelessWidget {
  const SentToEmailRow({super.key, required this.email, required this.accent});

  final String email;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: '${SettingsCopy.of(context).t('Código enviado a')} $email',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
          borderRadius: AppRadii.rMedium,
        ),
        child: Row(
          children: [
            Icon(Icons.mail_outline_rounded,
                size: AppDimensions.iconMedium, color: accent),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SettingsCopy.of(context).t('Código enviado a'),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: appMuted(isDark)),
                  ),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segunda vía de verificación: el código QR que envía el backend.
///
/// Se ubica debajo de «Reenviar código» y nace plegado para no competir con el
/// formulario principal. Solo se construye cuando la respuesta del backend
/// trajo un QR: si no lo trajo, la pantalla no ofrece una opción vacía.
class EmailOtpQrOption extends StatefulWidget {
  const EmailOtpQrOption({super.key, required this.dataUrl, this.accent});

  /// QR en formato data URL del paso de verificación por correo.
  final String dataUrl;

  final Color? accent;

  @override
  State<EmailOtpQrOption> createState() => _EmailOtpQrOptionState();
}

class _EmailOtpQrOptionState extends State<EmailOtpQrOption> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionTile(
          icon: Icons.qr_code_2_rounded,
          title: SettingsCopy.of(context).t('Verificar con código QR'),
          subtitle: SettingsCopy.of(context)
              .t('Segunda opción: escanea el código sin abrir el correo'),
          accent: widget.accent,
          trailingIcon:
              _open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          onTap: () => setState(() => _open = !_open),
        ),
        if (_open) ...[
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadii.rLarge,
              border: Border.all(color: appBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  SettingsCopy.of(context).t('SEGUNDA OPCIÓN'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  SettingsCopy.of(context)
                      .t('Escanea el código con la aplicación institucional'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  SettingsCopy.of(context).t(
                      'Si no tienes el correo a la vista, apunta con la cámara o con la app de la institución. El QR sirve para el mismo código de 6 dígitos.'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Center(
                  child: AppQrImage(
                    dataUrl: widget.dataUrl,
                    size: 200,
                    semanticsLabel: SettingsCopy.of(context)
                        .t('Código QR de verificación de correo'),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  SettingsCopy.of(context)
                      .t('El QR caduca junto con el código enviado al correo.'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: appFaint(isDark)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
