import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success carries data', () {
      const r = Success<int>(42);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
      expect(r.dataOrNull, 42);
      expect(r.failureOrNull, isNull);
    });

    test('Failure carries error', () {
      const f = ValidationFailure(message: 'X');
      const r = FailureResult<int>(f);
      expect(r.isSuccess, isFalse);
      expect(r.isFailure, isTrue);
      expect(r.dataOrNull, isNull);
      expect(r.failureOrNull, f);
    });

    test('when dispatches correctly', () {
      const s = Success<int>(7);
      final a = s.when(success: (d) => d * 2, failure: (_) => -1);
      expect(a, 14);

      const f = ValidationFailure(message: 'X');
      const r = FailureResult<int>(f);
      final b = r.when(success: (d) => d, failure: (e) => e.message);
      expect(b, 'X');
    });
  });
}