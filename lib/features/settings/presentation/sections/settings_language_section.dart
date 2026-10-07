// settings_language_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/app_preferences.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../settings_copy.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_section_label.dart';
import '../../../../core/widgets/app_segmented_option.dart';

/// Bloque IDIOMA de Configuración.
///
/// Cambia `appPreferencesProvider.language`; `App` reconstruye el árbol con el
/// nuevo `AppLanguageScope` y las etiquetas se vuelven a traducir solas.
class SettingsLanguageSection extends ConsumerWidget {
  const SettingsLanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final text = SettingsCopy.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionLabel(label: text.languageSection),
        const SizedBox(height: AppSpacing.m),
        SettingsGroup(
          children: [
            SettingsGroupHeader(
              title: text.languageLabel,
              hint: text.languageHint,
            ),
            SettingsGroupBody(
              child: _LanguageOptions(
                selected: preferences.language,
                onSelected: (language) => ref
                    .read(appPreferencesProvider.notifier)
                    .setLanguage(language),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Opciones de idioma, una por locale soportado.
///
/// Se usa el relleno sólido porque son excluyentes: al elegir una, la otra
/// pierde el relieve. Cada etiqueta se limita a una línea con elipsis, así que
/// en 320 px con texto grande no desborda la tarjeta.
class _LanguageOptions extends StatelessWidget {
  const _LanguageOptions({required this.selected, required this.onSelected});

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);

    return IntrinsicHeight(
      // Iguala la altura de las dos opciones aunque una se traduzca a un texto
      // más largo; sin altura acotada, `stretch` no puede repartirla.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final language in AppLanguage.values) ...[
            if (language != AppLanguage.values.first)
              const SizedBox(width: AppSpacing.s),
            Expanded(
              child: AppSegmentOption(
                label: switch (language) {
                  AppLanguage.spanish => text.spanish,
                  AppLanguage.english => text.english,
                },
                selected: selected == language,
                onTap: () => onSelected(language),
                style: AppSegmentStyle.filled,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
