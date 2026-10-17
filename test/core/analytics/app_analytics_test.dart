import 'package:campusvote_flutter/core/analytics/app_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las pantallas se registran sin IDs ni tokens', () {
    expect(
      AppAnalytics.sanitize('/jury/fair/c1f79d06-eb11-44f7-9523-378ccff2fc14/vote'),
      '/jury/fair/:id/vote',
    );
    expect(AppAnalytics.sanitize('/j/invitacion?token=abc'), '/j/invitacion');
    expect(AppAnalytics.sanitize('/x/aB3dE5fG7hJ9kL1mN3pQ5rS'), '/x/:token');
  });

  test('sin Firebase configurado no falla', () {
    AppAnalytics.screen('/teaching');
    AppAnalytics.event('prueba');
  });
}
