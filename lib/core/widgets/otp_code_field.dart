import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Campo de código de un solo uso de 6 dígitos.
///
/// Unifica la verificación por correo, el TOTP del acceso y el TOTP del
/// configuración: mismo sobretítulo, mismo formato y mismo autofill del
/// sistema en los tres casos.
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.label,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = true,
    this.hint = '000000',
  });

  /// Controller del campo; lo aporta la pantalla que dispara el envío.
  final TextEditingController controller;

  /// Sobretítulo del campo (por ejemplo "Código de verificación").
  final String label;

  /// Se dispara al enviar desde el teclado (botón "listo").
  final VoidCallback? onSubmitted;

  final bool enabled;
  final bool autofocus;
  final String hint;

  /// Longitud del código; la comparten el correo y TOTP.
  static const int codeLength = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: label,
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: appMuted(isDark),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: controller,
          autofocus: autofocus,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(codeLength),
          ],
          onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 12,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            constraints: const BoxConstraints(
              minHeight: AppDimensions.inputHeight,
            ),
          ),
        ),
      ],
    );
  }
}
