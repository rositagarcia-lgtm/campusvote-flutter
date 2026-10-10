// settings_appearance_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/settings/app_preferences.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../settings_copy.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section_label.dart';
import 'settings_text_size_block.dart';

/// Bloque APARIENCIA de Configuración: tema y tamaño de texto.
///
/// Los dos controles viven bajo el mismo encabezado porque se eligen juntos y
/// ninguno depende del otro. Cada uno escribe una preferencia real y persistente
/// (`appPreferencesProvider`); no hay filas decorativas que no hagan nada.
class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final theme = Theme.of(context);
    final text = SettingsCopy.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // `darkMode == null` significa "seguir al sistema": el interruptor refleja
    // el tema efectivo y la primera pulsación ya guarda una elección.
    final followsSystem = preferences.darkMode == null;
    final isDarkEnabled = preferences.darkMode ?? isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionLabel(label: text.appearance),
        const SizedBox(height: AppSpacing.m),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: isDark ? PhosphorIconsRegular.moon : PhosphorIconsRegular.sun,
              title: text.darkMode,
              subtitle: followsSystem
                  ? text.darkModeSystemHint
                  : isDarkEnabled
                      ? text.darkModeHint
                      : text.lightModeHint,
              trailing: Switch.adaptive(
                value: isDarkEnabled,
                onChanged: (value) => ref
                    .read(appPreferencesProvider.notifier)
                    .setDarkMode(value),
                activeTrackColor: theme.colorScheme.primary,
                activeThumbColor: theme.colorScheme.onPrimary,
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                inactiveThumbColor: theme.colorScheme.onSurface.withValues(
                  alpha: isDark ? 0.78 : 0.58,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        const SettingsTextSizeBlock(),
      ],
    );
  }
}
