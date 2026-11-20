import 'package:campusvote_flutter/features/certificates/data/certificates_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyCertificate certificate(Map<String, dynamic> json) =>
      MyCertificate.fromJson({
        'id': 'cert-1',
        'certificate_type': 'WINNER',
        'fair': {'name': 'Feria'},
        'project': {'name': 'Proyecto'},
        ...json,
      });

  test('un ganador sin place no se presenta como primer puesto', () {
    final c = certificate({});
    expect(c.shown, isTrue);
    expect(c.rank, 0);
  });

  test('el puesto del servidor se respeta', () {
    final c = certificate({'place': 2});
    expect(c.rank, 2);
  });
}
