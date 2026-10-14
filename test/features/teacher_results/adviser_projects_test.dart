import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/teacher_results/data/adviser_projects_repository.dart';
import 'package:campusvote_flutter/features/teacher_results/presentation/adviser_projects_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _approved = AdvisedProject.fromJson({
  'id': 'p1',
  'name': 'Robot reciclador',
  'status': 'APPROVED',
  'fair': {'name': 'Feria 2026', 'status': 'OPEN'},
  'stand': {'code': 'A-1'},
  'members': [
    {
      'user': {'first_name': 'Ana', 'last_name': 'Ruiz'}
    },
    {
      'user': {'first_name': 'Luis', 'last_name': 'Paz'}
    },
  ],
});

final _pending = AdvisedProject.fromJson({
  'id': 'p2',
  'name': 'Huerto urbano',
  'status': 'DRAFT_PENDING_STUDENT_CONFIRMATION',
  'fair': {'name': 'Feria 2026', 'status': 'OPEN'},
});

void main() {
  test('lee feria, stand, equipo y estado del proyecto asesorado', () {
    expect(_approved.fairName, 'Feria 2026');
    expect(_approved.stand, 'A-1');
    expect(_approved.team, ['Ana Ruiz', 'Luis Paz']);
    expect(_approved.videoUrl, isNull);
    expect(_approved.imageUrls, isEmpty);
    expect(_approved.statusLabel, ('Aprobado', false));
    expect(_pending.statusLabel.$2, isTrue);
  });

  testWidgets('primero los proyectos que esperan una acción', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        adviserProjectsProvider
            .overrideWith((ref) async => [_approved, _pending]),
      ],
      child: MaterialApp(
          theme: AppTheme.light(), home: const AdviserProjectsPage()),
    ));
    await tester.pumpAndSettle();

    final pendingY = tester.getTopLeft(find.text('Huerto urbano')).dy;
    final approvedY = tester.getTopLeft(find.text('Robot reciclador')).dy;
    expect(pendingY, lessThan(approvedY));
    expect(find.text('Espera que el alumno confirme'), findsOneWidget);
    expect(find.text('Ana Ruiz, Luis Paz'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
