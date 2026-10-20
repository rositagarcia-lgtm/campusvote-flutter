import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/certificates/data/certificates_repository.dart';
import 'package:campusvote_flutter/features/certificates/presentation/my_certificates_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra certificados y bloquea la descarga durante las pruebas',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        myCertificatesProvider.overrideWith((_) async => const [
              MyCertificate(
                id: 'certificate-1',
                winner: true,
                fairName: 'Feria de Ciencia',
                projectName: 'Robot solar',
              ),
            ]),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const MyCertificatesPage(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Robot solar'), findsOneWidget);
    expect(find.textContaining('La descarga estará'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Descarga en pruebas'),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
