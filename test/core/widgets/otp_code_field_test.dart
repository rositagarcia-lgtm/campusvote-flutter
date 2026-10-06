import 'package:campusvote_flutter/core/widgets/otp_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OTP segmentado conserva el campo nativo y limita a seis dígitos',
      (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OtpCodeField(
                  controller: controller,
                  label: 'Código de verificación',
                  autofocus: false,
                  segmented: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1234567');
    await tester.pump();

    expect(controller.text, '123456');
    // El tema global rellena inputs; el campo invisible no debe tapar casillas.
    expect(tester.widget<TextField>(find.byType(TextField)).decoration?.filled,
        isFalse);
    for (final digit in '123456'.split('')) {
      expect(find.text(digit), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
