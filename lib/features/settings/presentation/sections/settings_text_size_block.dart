// settings_text_size_block.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/app_preferences.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../settings_copy.dart';
import '../widgets/settings_group.dart';
import '../../../../core/widgets/app_segmented_option.dart';

/// Tarjeta de tamaño de texto.
///
/// La preferencia se guarda aquí; el escalado real lo aplica `App` sobre
/// `MediaQuery`, por eso la vista previa NO vuelve a multiplicar el factor: si
/// lo hiciera, la muestra crecería el doble que el resto de la app.
class SettingsTextSizeBlock extends ConsumerWidget {
  const SettingsTextSizeBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final text = SettingsCopy.of(context);

    return SettingsGroup(
      children: [
        SettingsGroupHeader(title: text.textSize, hint: text.textSizeHint),
        SettingsGroupBody(
          child: _TextSizeOptions(
            selected: preferences.textSize,
            onSelected: (size) => ref
                .read(appPreferencesProvider.notifier)
                .setTextSize(size),
          ),
        ),
      ],
    );
  }
}

/// Las tres opciones de tamaño, con su muestra «Aa» y su etiqueta.
class _TextSizeOptions extends StatelessWidget {
  const _TextSizeOptions({required this.selected, required this.onSelected});

  final AppTextSize selected;
  final ValueChanged<AppTextSize> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = SettingsCopy.of(context);
    final baseFontSize = theme.textTheme.titleMedium?.fontSize ?? 16;

    return IntrinsicHeight(
      // `stretch` iguala la altura de las tres cajas: si no, la opción «Grande»
      // —cuyo «Aa» es más alto— quedaría descolgada respecto a las otras dos.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final size in AppTextSize.values) ...[
            if (size != AppTextSize.values.first)
              const SizedBox(width: AppSpacing.s),
            Expanded(
              child: AppSegmentOption(
                label: switch (size) {
                  AppTextSize.small => text.small,
                  AppTextSize.normal => text.normal,
                  AppTextSize.large => text.large,
                },
                selected: selected == size,
                onTap: () => onSelected(size),
                preview: _SizeSample(
                  fontSize: baseFontSize * size.factor,
                  selected: selected == size,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Muestra «Aa» del tamaño elegido.
///
/// Se anula el escalado ambiente solo aquí: el tamaño ya viene multiplicado por
/// el factor, y heredar además el escalado global lo aplicaría dos veces.
class _SizeSample extends StatelessWidget {
  const _SizeSample({required this.fontSize, required this.selected});

  final double fontSize;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQuery.withNoTextScaling(
      child: Text(
        'Aa',
        maxLines: 1,
        style: theme.textTheme.titleMedium?.copyWith(
          color: selected ? theme.colorScheme.primary : null,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}