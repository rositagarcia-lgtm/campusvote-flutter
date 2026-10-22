import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/widgets/app_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester, TargetPlatform platform) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light().copyWith(platform: platform),
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => AppDialog.confirm(context,
            title: 'Cerrar sesión', message: '¿Seguro?', destructive: true),
        child: const Text('abrir'),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('en iPhone el diálogo es la alerta nativa de iOS', (tester) async {
    await _open(tester, TargetPlatform.iOS);
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('en Android sigue siendo el diálogo de Material', (tester) async {
    await _open(tester, TargetPlatform.android);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });
}
