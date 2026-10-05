import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/presentation/widgets/teacher_rating_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0, 768.0]) {
    testWidgets('selector accesible y sin overflow a ${width.toInt()} px',
        (tester) async {
      var selectedScore = 0;
      await tester.binding.setSurfaceSize(Size(width, 520));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 520),
            textScaler: const TextScaler.linear(1.4),
          ),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                body: Center(
                  child: SizedBox(
                    width: width - 32,
                    child: TeacherRatingSelector(
                      value: selectedScore,
                      onChanged: (value) =>
                          setState(() => selectedScore = value),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fourthStar = find.bySemanticsLabel('4 de 5 estrellas');
      expect(fourthStar, findsOneWidget);
      expect(tester.getSize(fourthStar).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(fourthStar).height, greaterThanOrEqualTo(48));
      await tester.tap(fourthStar);
      await tester.pumpAndSettle();
      expect(selectedScore, 4);
      expect(find.text('Seleccionaste 4 de 5.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
