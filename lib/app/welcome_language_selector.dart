import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_icons.dart';
import '../core/settings/app_preferences.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_palette.dart';
import '../features/settings/presentation/settings_copy.dart';

/// Selector compacto para elegir el idioma antes de iniciar sesión.
class WelcomeLanguageSelector extends ConsumerStatefulWidget {
  const WelcomeLanguageSelector({super.key});

  @override
  ConsumerState<WelcomeLanguageSelector> createState() =>
      _WelcomeLanguageSelectorState();
}

class _WelcomeLanguageSelectorState
    extends ConsumerState<WelcomeLanguageSelector> {
  final MenuController _menuController = MenuController();

  Future<void> _select(AppLanguage language) async {
    await ref.read(appPreferencesProvider.notifier).setLanguage(language);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) _menuController.close();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(
      appPreferencesProvider.select((preferences) => preferences.language),
    );
    final copy = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, AppSpacing.s),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(5),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AppRadii.rXLarge,
            side: BorderSide(color: appBorder(isDark)),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(AppSpacing.m)),
      ),
      menuChildren: [
        SizedBox(
          key: const ValueKey('language-panel'),
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s,
                  AppSpacing.xs,
                  AppSpacing.s,
                  AppSpacing.m,
                ),
                child: Text(
                  copy.languageLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: appMuted(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _LanguageOption(
                language: AppLanguage.spanish,
                label: copy.spanish,
                selected: language == AppLanguage.spanish,
                onTap: () => _select(AppLanguage.spanish),
              ),
              const SizedBox(height: AppSpacing.xs),
              _LanguageOption(
                language: AppLanguage.english,
                label: copy.english,
                selected: language == AppLanguage.english,
                onTap: () => _select(AppLanguage.english),
              ),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) => Semantics(
        key: const ValueKey('welcome-language-button'),
        button: true,
        label: copy.languageLabel,
        excludeSemantics: true,
        child: Tooltip(
          message: copy.languageLabel,
          child: Material(
            color: primary.withValues(alpha: isDark ? 0.16 : 0.08),
            shape: CircleBorder(
              side: BorderSide(color: primary.withValues(alpha: 0.22)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: primary.withValues(alpha: 0.12),
              onTap: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: SizedBox.square(
                dimension: AppDimensions.touchTarget,
                child: Icon(
                  PhosphorIconsRegular.globe,
                  size: AppDimensions.iconMedium,
                  color: primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Semantics(
      key: ValueKey('language-option-${language.code}'),
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            constraints:
                const BoxConstraints(minHeight: AppDimensions.touchTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: isDark ? 0.18 : 0.08)
                  : Colors.transparent,
              borderRadius: AppRadii.rMedium,
              border: Border.all(
                color: selected
                    ? primary.withValues(alpha: isDark ? 0.55 : 0.38)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? Container(
                          key: const ValueKey('selected'),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIconsBold.check,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('unselected'),
                          width: 24,
                          height: 24,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
