import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Campo de código de un solo uso de seis dígitos.
///
/// Conserva un solo campo nativo para teclado, autofill y lectores de pantalla;
/// el modo segmentado solo cambia su presentación visual.
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.label,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = true,
    this.segmented = false,
    this.hint = '000000',
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final bool segmented;
  final String hint;

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
        if (segmented)
          _SegmentedOtpInput(
            controller: controller,
            label: label,
            enabled: enabled,
            autofocus: autofocus,
            onSubmitted: onSubmitted,
          )
        else
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
              color: theme.colorScheme.onSurface,
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

class _SegmentedOtpInput extends StatelessWidget {
  const _SegmentedOtpInput({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.autofocus,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      height: 60,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final activeIndex = value.selection.baseOffset.clamp(0, 5);
              return ExcludeSemantics(
                child: Row(
                  children: [
                    for (var index = 0;
                        index < OtpCodeField.codeLength;
                        index++) ...[
                      if (index == 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            width: 7,
                            height: 2,
                            decoration: BoxDecoration(
                              color: scheme.outlineVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: AppRadii.rSmall,
                            border: Border.all(
                              color: index == activeIndex && enabled
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                              width: index == activeIndex && enabled ? 2 : 1,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutBack,
                              ),
                              child: child,
                            ),
                            child: Text(
                              index < value.text.length
                                  ? value.text[index]
                                  : '',
                              key: ValueKey(
                                index < value.text.length
                                    ? 'd$index${value.text[index]}'
                                    : 'e$index',
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          Semantics(
            label: label,
            textField: true,
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(OtpCodeField.codeLength),
              ],
              onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
              textAlign: TextAlign.center,
              cursorColor: Colors.transparent,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
