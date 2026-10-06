import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_dashboard_progress.dart';
import 'package:campusvote_flutter/features/jury/presentation/widgets/jury_dashboard_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el avance real sin overflow en cuatro anchos',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(_app(const AsyncValue.data(
        JuryDashboardProgress(completed: 3, total: 8),
      )));
      expect(tester.takeException(), isNull, reason: 'ancho $width');
      expect(find.text('38%'), findsOneWidget);
      expect(find.text('3 de 8 proyectos evaluados en ferias abiertas'),
          findsOneWidget);
    }
  });

  testWidgets('no inventa porcentaje sin proyectos o con error',
      (tester) async {
    await tester.pumpWidget(_app(const AsyncValue.data(
      JuryDashboardProgress(completed: 0, total: 0),
    )));
    expect(find.text('Sin datos'), findsOneWidget);
    expect(find.text('0%'), findsNothing);

    await tester
        .pumpWidget(_app(AsyncValue.error(Exception(), StackTrace.empty)));
    expect(find.text('No disponible'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
  });
}

Widget _app(AsyncValue<JuryDashboardProgress> progress) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: JuryDashboardOverview(
            openCount: 1,
            assignedCount: 2,
            progress: progress,
          ),
        ),
      ),
    );
