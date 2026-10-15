import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/fair_results/data/published_results_repository.dart';
import 'package:campusvote_flutter/features/fair_results/domain/published_results.dart';
import 'package:campusvote_flutter/features/fair_results/presentation/published_results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _json = {
  'fair': {'id': 'f1', 'name': 'Feria de Ciencia 2026'},
  'published_at': '2026-10-14T12:00:00Z',
  'categories': [
    {
      'category_name': 'Robótica',
      'podium': [
        {'position': 2, 'project_id': 'b', 'project_name': 'Dron'},
        {'position': 1, 'project_id': 'a', 'project_name': 'Brazo Robótico'},
        {'position': 3, 'project_id': 'c', 'project_name': 'Carrito', 'is_mine': true},
      ],
    },
    {'category_name': 'Arte', 'podium': []},
  ],
  'audience_favorite': {'project_id': 'x', 'project_name': 'Huerto'},
  'my_projects': [
    {'project_name': 'Carrito', 'category_name': 'Robótica', 'position': 3},
  ],
};

void main() {
  test('lee el podio ordenado y el puesto propio', () {
    final r = PublishedResults.fromJson(_json);
    expect(r.categories.first.podium.map((p) => p.position), [1, 2, 3]);
    expect(r.categories.first.winner?.projectName, 'Brazo Robótico');
    expect(r.categories.last.winner, isNull);
    expect(r.audienceFavorite, 'Huerto');
    expect(r.myProjects.single.position, 3);
  });

  testWidgets('muestra ganador, puestos, el proyecto propio y el favorito',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        publishedResultsProvider('f1')
            .overrideWith((_) async => PublishedResults.fromJson(_json)),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const PublishedResultsPage(fairId: 'f1'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Brazo Robótico'), findsOneWidget);
    expect(find.text('GANADOR'), findsOneWidget);
    expect(find.textContaining('3.° puesto de Robótica'), findsOneWidget);
    expect(find.text('Esta categoría no recibió votos del jurado.'),
        findsOneWidget);
    expect(find.text('Huerto'), findsOneWidget);
    expect(find.textContaining('votos'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
