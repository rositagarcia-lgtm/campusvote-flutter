import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/voting/widgets/voting_ranking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la selección oficial se adapta a móvil, móvil grande y tablet',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const project = FairProjectModel(
      id: 'project-1',
      fairId: 'fair-1',
      name:
          'Proyecto de investigación con nombre suficientemente largo para ajustarse',
      description: 'Descripción',
      status: 'APPROVED',
      categoryName: 'Innovación y desarrollo tecnológico',
    );

    for (final width in [390.0, 430.0, 768.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 850);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 850),
                textScaler: const TextScaler.linear(1.3),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: RankedProjectOption(
                  project: project,
                  rank: 1,
                  score: 17.5,
                  selected: true,
                  enabled: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'ancho $width');
      expect(find.text(project.name), findsOneWidget);
      expect(find.text(project.categoryName!), findsOneWidget);
      expect(find.text('17.5/20'), findsOneWidget);
    }
  });
}
