import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/core_providers.dart';
import '../storage/local_storage.dart';

enum AppTextSize {
  small(0.9),
  normal(1.0),
  large(1.12);

  const AppTextSize(this.factor);
  final double factor;
}

enum AppLanguage {
  spanish('es'),
  english('en');

  const AppLanguage(this.code);
  final String code;
}

class AppPreferences {
  const AppPreferences(
      {this.darkMode,
      this.textSize = AppTextSize.normal,
      this.language = AppLanguage.spanish});

  /// Null conserva el tema del sistema hasta que el usuario elija uno.
  final bool? darkMode;
  final AppTextSize textSize;
  final AppLanguage language;
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesController, AppPreferences>((ref) {
  return AppPreferencesController(ref.watch(localStorageProvider));
});

class AppPreferencesController extends StateNotifier<AppPreferences> {
  AppPreferencesController(this._storage) : super(_load(_storage));

  static const _themeKey = 'settings.theme';
  static const _textKey = 'settings.text_size';
  static const _languageKey = 'settings.language';

  final LocalStorage _storage;

  static AppPreferences _load(LocalStorage storage) {
    final theme = storage.getString(_themeKey);
    final text = storage.getString(_textKey);
    final language = storage.getString(_languageKey);
    return AppPreferences(
      darkMode: theme == 'dark'
          ? true
          : theme == 'light'
              ? false
              : null,
      textSize: AppTextSize.values.firstWhere(
        (value) => value.name == text,
        orElse: () => AppTextSize.normal,
      ),
      language: AppLanguage.values.firstWhere(
        (value) => value.code == language,
        orElse: () => AppLanguage.spanish,
      ),
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    state = AppPreferences(
        darkMode: enabled, textSize: state.textSize, language: state.language);
    await _storage.setString(_themeKey, enabled ? 'dark' : 'light');
  }

  Future<void> setTextSize(AppTextSize size) async {
    state = AppPreferences(
        darkMode: state.darkMode, textSize: size, language: state.language);
    await _storage.setString(_textKey, size.name);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = AppPreferences(
        darkMode: state.darkMode, textSize: state.textSize, language: language);
    await _storage.setString(_languageKey, language.code);
  }
}
