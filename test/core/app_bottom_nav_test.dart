import 'package:campusvote_flutter/core/widgets/app_bottom_nav.dart';
import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/core/theme/app_colors.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoSessionRepository implements AuthRepository {
  @override
  Future<bool> hasSession() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('El test no usa operaciones de sesión');
}

void main() {
  testWidgets('NavigationBar de main reserva espacio y respeta SafeArea',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final dimensions in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(480, 1000),
    ]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        for (final size in AppTextSize.values) {
          for (final language in AppLanguage.values) {
            for (final (selectedIndex, current) in [
              (0, AppNavDestination.panel),
              (1, AppNavDestination.account),
            ]) {
              tester.view.physicalSize = dimensions;
              tester.view.devicePixelRatio = 1;
              await tester.pumpWidget(ProviderScope(
                overrides: [
                  authRepositoryProvider
                      .overrideWithValue(_NoSessionRepository()),
                ],
                child: MaterialApp(
                  theme: ThemeData(
                    useMaterial3: true,
                    brightness: brightness,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.primary,
                      brightness: brightness,
                    ),
                  ),
                  builder: (context, child) => AppLanguageScope(
                    language: language,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        padding: const EdgeInsets.only(bottom: 24),
                        textScaler: TextScaler.linear(size.factor),
                      ),
                      child: child!,
                    ),
                  ),
                  home: Scaffold(
                    body: ListView(
                      key: const ValueKey('long-scroll'),
                      children: [
                        for (var i = 0; i < 30; i++)
                          SizedBox(height: 60, child: Text('Fila $i')),
                      ],
                    ),
                    bottomNavigationBar:
                        AppBottomNav(current: current),
                  ),
                ),
              ));
              await tester.pumpAndSettle();

              final body =
                  tester.getRect(find.byKey(const ValueKey('long-scroll')));
              final nav = find.byType(AppBottomNav);
              final surface = tester.getRect(nav);
              final destinations = find.descendant(
                of: nav,
                matching: find.byType(InkWell),
              );
              expect(body.bottom, lessThanOrEqualTo(surface.top + 0.01));
              expect(surface.left, greaterThanOrEqualTo(0));
              expect(surface.right, lessThanOrEqualTo(dimensions.width));
              expect(destinations, findsNWidgets(2));
              final selectedItem = tester.widget<Semantics>(find
                  .ancestor(
                    of: destinations.at(selectedIndex),
                    matching: find.byType(Semantics),
                  )
                  .first);
              expect(selectedItem.properties.selected, isTrue);
              expect(tester.getRect(destinations.first).bottom,
                  lessThanOrEqualTo(dimensions.height - 24));
              expect(tester.takeException(), isNull);
            }
          }
        }
      }
    }
  });
}
