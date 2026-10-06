import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Campo de formulario del sistema.
///
/// La etiqueta es un sobretítulo en mayúsculas (no un `labelText` flotante),
/// el alto mínimo es [AppDimensions.inputHeight] y el campo expone los
/// parámetros de teclado que pide cada flujo (acción, autofill, formatos).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.labelTrailing,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final Widget? labelTrailing;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  /// Sugerencias de autocompletado del sistema (por ejemplo oneTimeCode).
  final Iterable<String>? autofillHints;

  /// Filtros de entrada (dígitos, longitud máxima…).
  final List<TextInputFormatter>? inputFormatters;

  final String? Function(String? value)? validator;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
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
            ),
            if (labelTrailing != null) ...[
              const SizedBox(width: AppSpacing.s),
              labelTrailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          autofocus: autofocus,
          focusNode: focusNode,
          textInputAction: textInputAction,
          autofillHints: autofillHints?.toList(),
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: AppDimensions.iconMedium),
            suffixIcon: suffix,
            constraints: const BoxConstraints(
              minHeight: AppDimensions.inputHeight,
            ),
          ),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: appMuted(isDark),
            ),
          ),
        ],
      ],
    );
  }
}
