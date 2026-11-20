import 'package:campusvote_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:campusvote_flutter/features/notifications/notification_destination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los resultados publicados abren el podio, no la lista de proyectos', () {
    const fair = 'fair 1';
    for (final role in [AuthRole.student, AuthRole.jury, AuthRole.teacher]) {
      expect(
        notificationPath(kind: 'RESULTS_PUBLISHED', role: role, fairId: fair),
        '/resultados/fair%201',
      );
    }
  });

  test('un aviso de feria abierta sigue llevando al panel de cada rol', () {
    expect(
      notificationPath(kind: 'FAIR_OPENED', role: AuthRole.student, fairId: 'f'),
      '/teaching/explore/f',
    );
    expect(
      notificationPath(kind: 'FAIR_OPENED', role: AuthRole.jury, fairId: 'f'),
      '/jury/fair/f',
    );
    expect(
      notificationPath(kind: 'FAIR_OPENED', role: AuthRole.teacher, fairId: 'f'),
      '/jury/fair/f',
    );
  });

  test('la reseña del jurado abre el proyecto del alumno', () {
    expect(
      notificationPath(
        kind: 'RATING_RECEIVED',
        role: AuthRole.student,
        fairId: 'f',
        projectId: 'p 1',
      ),
      '/teaching/projects/p%201?fair=f',
    );
  });
}
