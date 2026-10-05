import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_preferences.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page_layout.dart';
import '../../../core/widgets/app_palette.dart';
import 'settings_copy.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final copy = SettingsCopy(preferences.language);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: copy.title),
      body: SafeArea(
        top: false,
        child: PageScrollBody(
          maxWidth: kFormMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionLabel(copy.appearance),
              const SizedBox(height: AppSpacing.m),
              AppCard(
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: primary),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(copy.darkMode,
                              style: theme.textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(copy.darkModeHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: appMuted(isDark),
                              )),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: preferences.darkMode ?? isDark,
                      onChanged: (value) => ref
                          .read(appPreferencesProvider.notifier)
                          .setDarkMode(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.textSize, style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        for (final size in AppTextSize.values) ...[
                          if (size != AppTextSize.small)
                            const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: _TextSizeOption(
                              label: switch (size) {
                                AppTextSize.small => copy.small,
                                AppTextSize.normal => copy.normal,
                                AppTextSize.large => copy.large,
                              },
                              size: size,
                              selected: preferences.textSize == size,
                              onTap: () => ref
                                  .read(appPreferencesProvider.notifier)
                                  .setTextSize(size),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(copy.languageSection),
              const SizedBox(height: AppSpacing.m),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.languageLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children: [
                        for (final language in AppLanguage.values)
                          ChoiceChip(
                            label: Text(language == AppLanguage.spanish
                                ? copy.spanish
                                : copy.english),
                            selected: preferences.language == language,
                            onSelected: (_) => ref
                                .read(appPreferencesProvider.notifier)
                                .setLanguage(language),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
      );
}

class _TextSizeOption extends StatelessWidget {
  const _TextSizeOption(
      {required this.label,
      required this.size,
      required this.selected,
      required this.onTap});

  final String label;
  final AppTextSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rMedium,
          side: BorderSide(color: selected ? primary : theme.dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Column(
              children: [
                Text('Aa',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: selected ? primary : null,
                      fontSize: 16 * size.factor,
                      fontWeight: FontWeight.w700,
                    )),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? primary : null,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
