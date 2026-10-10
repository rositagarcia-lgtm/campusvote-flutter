import 'package:campusvote_flutter/core/branding/branding_controller.dart';
import 'package:campusvote_flutter/core/branding/organization_branding.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/core/theme/app_colors.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/theme/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _navy = OrganizationBranding(
  id: 'org-navy',
  name: 'Universidad Marina',
  primaryColor: Color(0xFF0A1F44),
  secondaryColor: Color(0xFFFFC72C),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrandContrast', () {
    test('elige tinta clara sobre colores oscuros y oscura sobre claros', () {
      expect(
          BrandContrast.onColor(const Color(0xFF0A1F44)), AppColors.inkInverse);
      expect(BrandContrast.onColor(const Color(0xFFFFC72C)), AppColors.ink);
    });

    test('aclara un primario oscuro hasta ser legible en fondo oscuro', () {
      const bg = AppColors.darkSurface;
      expect(BrandContrast.ratio(_navy.primaryColor, bg), lessThan(3));
      final fixed = BrandContrast.ensure(_navy.primaryColor, bg);
      expect(BrandContrast.ratio(fixed, bg), greaterThanOrEqualTo(3));
      // Conserva el tono de la marca.
      expect(HSLColor.fromColor(fixed).hue,
          closeTo(HSLColor.fromColor(_navy.primaryColor).hue, 1));
    });

    test('no toca un color que ya cumple el contraste', () {
      expect(BrandContrast.ensure(AppColors.primary, AppColors.surface),
          AppColors.primary);
    });
  });

  group('AppTheme con marca de organización', () {
    testWidgets('claro conserva el primario exacto de la organización',
        (tester) async {
      final theme = AppTheme.light(branding: _navy);
      expect(theme.colorScheme.primary, _navy.primaryColor);
      expect(theme.colorScheme.onPrimary, AppColors.inkInverse);
      expect(theme.colorScheme.onSecondary, AppColors.ink);
    });

    testWidgets('oscuro corrige el primario para que sea legible',
        (tester) async {
      final theme = AppTheme.dark(branding: _navy);
      expect(
        BrandContrast.ratio(
            theme.colorScheme.primary, theme.colorScheme.surface),
        greaterThanOrEqualTo(3),
      );
    });

    testWidgets('los tokens tonales salen de la marca, no de valores genéricos',
        (tester) async {
      final scheme = AppTheme.light(branding: _navy).colorScheme;
      expect(scheme.primaryContainer, isNot(scheme.primary));
      expect(scheme.outlineVariant, isNot(scheme.onSurface));
      expect(scheme.onSurfaceVariant, AppColors.inkMuted);
    });

    testWidgets('CampusVote mantiene sus neutros fijos', (tester) async {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      expect(light.scaffoldBackgroundColor, AppColors.background);
      expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(light.colorScheme.primary, AppColors.primary);
    });
  });

  group('BrandingController caché', () {
    late LocalStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorage(await SharedPreferences.getInstance());
    });

    test('recuerda la marca aplicada y la restaura para la misma org', () {
      BrandingController(storage: storage).apply(_navy);

      final restored = BrandingController(storage: storage)
        ..restoreCached('org-navy');
      expect(restored.state.name, _navy.name);
      expect(restored.state.primaryColor.toARGB32(),
          _navy.primaryColor.toARGB32());
    });

    test('no aplica la marca guardada de otra organización', () {
      BrandingController(storage: storage).apply(_navy);
      final other = BrandingController(storage: storage)
        ..restoreCached('org-otra');
      expect(other.state.id, 'campusvote');
    });

    test('reset borra la marca recordada', () {
      final controller = BrandingController(storage: storage)..apply(_navy);
      controller.reset();
      final next = BrandingController(storage: storage)
        ..restoreCached('org-navy');
      expect(next.state.id, 'campusvote');
    });
  });
}
