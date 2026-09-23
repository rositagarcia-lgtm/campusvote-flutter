import 'package:campusvote_flutter/features/voting/data/models/receipt_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptModel.fromJson — /cast (solo receiptCode)', () {
    test('parsea respuesta mínima del cast', () {
      final m = ReceiptModel.fromJson({
        'receiptCode': 'RC-ABC123',
        'status': 'CAST',
        'message': 'ok',
      });
      expect(m.receiptCode, 'RC-ABC123');
      expect(m.electionId, isNull);
      expect(m.castAt, isNull);
    });
  });

  group('ReceiptModel.fromJson — /verify-receipt (público)', () {
    test('parsea respuesta de verificación', () {
      final m = ReceiptModel.fromJson({
        'valid': true,
        'receiptCode': 'RC-ABC123',
        'electionId': 'e1',
        'electionTitle': 'Elección 2025',
        'electionStatus': 'OPEN',
        'castAt': '2025-01-01T00:00:00Z',
        'payloadHash': 'sha256:...',
      });
      expect(m.receiptCode, 'RC-ABC123');
      expect(m.electionId, 'e1');
      expect(m.electionTitle, 'Elección 2025');
      expect(m.castAt, isNotNull);
      expect(m.isValid, isTrue);
    });
  });
}