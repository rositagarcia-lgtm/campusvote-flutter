import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

class AppTextField extends StatelessWidget {
  final String label;
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
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? Function(String? value)? validator;
  final int maxLines;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.label,
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
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: AppDimensions.iconMedium)
                : null,
            suffix: suffix,
          ),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(helperText!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}