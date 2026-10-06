import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/core/widgets/app_segmented_option.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/projects/fair_project_filter.dart';
import 'package:campusvote_flutter/features/jury/presentation/projects/widgets/fair_project_card.dart';
import 'package:campusvote_flutter/features/jury/presentation/projects/widgets/fair_project_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const alpha = FairProjectModel(
  id: 'a',
  fairId: 'f1',
  name: 'Robot de aula',
  description: 'Mapa del aula',
  status: 'APPROVED',
  standCode: 'R-01',
  categoryName: 'Robótica',
);
const beta = FairProjectModel(
  id: 'b',
  fairId: 'f1',
  name: 'Dron de vigilancia',
  description: 'Vigilancia',
  status: 'APPROVED',
);
const gamma = FairProjectModel(
  id: 'c',
  fairId: 'f1',
  name: 'Riego autónomo',
  description: 'Huerta',
  status: 'SUBMITTED',
);

void main() {
  group('filtros de proyectos', () {
    test('cada filtro usa las rúbricas confirmadas por la API', () {
      const projects = [alpha, beta, gamma];
      const submitted = {'a'};

      expect(
        filterFairProjects(
          projects: projects,
          filter: FairProjectFilter.all,
          submittedIds: submitted,
        ),
        hasLength(3),
      );
      expect(
        filterFairProjects(
          projects: projects,
          filter: FairProjectFilter.completed,
          submittedIds: submitted,
        ).map((project) => project.id),
        ['a'],
      );
      expect(
        filterFairProjects(
          projects: projects,
          filter: FairProjectFilter.pending,
          submittedIds: submitted,
        ).map((project) => project.id),
        ['b', 'c'],
      );
    });

    test('contar evaluados coincide con lo que filtra la lista', () {
      const projects = [alpha, beta, gamma];
      const submitted = {'a', 'c'};

      expect(
        countEvaluatedProjects(projects: projects, submittedIds: submitted),
        2,
      );
      expect(
        filterFairProjects(
          projects: projects,
          filter: FairProjectFilter.completed,
          submittedIds: submitted,
        ),
        hasLength(countEvaluatedProjects(
          projects: projects,
          submittedIds: submitted,
        )),
      );
    });

    test('sin rúbricas enviadas, ningún filtro cuela proyectos', () {
      expect(
        filterFairProjects(
          projects: const [alpha],
          filter: FairProjectFilter.completed,
          submittedIds: const {},
        ),
        isEmpty,
      );
    });

    test('el nombre de la feria sale de la asignación del jurado', () {
      const assignments = [
        FairAssignmentModel(
          fairId: 'otra',
          organizationId: 'o1',
          name: 'Feria Sur',
          description: 'Sede Sur',
          status: FairStatus.open,
        ),
        FairAssignmentModel(
          fairId: 'f1',
          organizationId: 'o1',
          name: 'Feria Norte',
          description: 'Sede Norte',
          status: FairStatus.open,
        ),
      ];

      expect(
        fairNameForFairId(assignments: assignments, fairId: 'f1'),
        'Feria Norte',
      );
      expect(
        fairNameForFairId(assignments: assignments, fairId: 'f9'),
        isNull,
      );
      expect(fairNameForFairId(assignments: const [], fairId: 'f1'), isNull);
    });
  });

  group('barra de filtros', () {
    Future<void> pumpBar(
      WidgetTester tester, {
      required FairProjectFilter selected,
      required List<FairProjectModel> projects,
      required Set<String> submittedIds,
      ValueChanged<FairProjectFilter>? onSelected,
      Size size = const Size(360, 800),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: FairProjectFilterBar(
          selected: selected,
          projects: projects,
          submittedIds: submittedIds,
          onSelected: onSelected ?? (_) {},
        )),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('muestra los tres filtros con su total', (tester) async {
      await pumpBar(tester,
        selected: FairProjectFilter.all,
        projects: const [alpha, beta, gamma],
        submittedIds: const {'a'},
      );
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);
      expect(find.text('Evaluados'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Todos
      expect(find.text('2'), findsOneWidget); // Pendientes
      expect(find.text('1'), findsOneWidget); // Evaluados
    });

    testWidgets('el total viaja también en la semántica', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBar(tester,
        selected: FairProjectFilter.all,
        projects: const [alpha, beta],
        submittedIds: const {},
      );
      expect(find.bySemanticsLabel('Pendientes, 2'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('se elige otro filtro y se dibuja en 320 px', (tester) async {
      FairProjectFilter? chosen;
      await pumpBar(
        tester,
        selected: FairProjectFilter.all,
        projects: const [alpha, beta, gamma],
        submittedIds: const {'a'},
        onSelected: (filter) => chosen = filter,
        size: const Size(320, 640),
      );
      await tester.tap(find.text('Evaluados'));
      expect(chosen, FairProjectFilter.completed);
      expect(tester.takeException(), isNull);
    });
  });

  group('tarjeta de proyecto', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      bool? submitted,
      Size size = const Size(360, 800),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: FairProjectCard(
          fairId: 'f1',
          project: alpha,
          evaluationSubmitted: submitted,
        )),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('usa datos reales del proyecto, stand y categoría', (tester) async {
      await pumpCard(tester);
      expect(find.text('Robot de aula'), findsOneWidget);
      expect(find.text('Mapa del aula'), findsOneWidget);
      expect(find.text('R-01'), findsOneWidget);
      expect(find.text('Robótica'), findsOneWidget);
      expect(find.text('Aprobado'), findsOneWidget);
      expect(find.text('Evaluar con rúbrica'), findsOneWidget);
    });

    testWidgets('es plana y traducible por el lector de pantalla',
        (tester) async {
      await pumpCard(tester, submitted: false);
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel(RegExp('Robot')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('sin estado conocido no afirma pendiente ni evaluado',
        (tester) async {
      await pumpCard(tester);
      expect(find.text('Pendiente'), findsNothing);
      expect(find.text('Evaluado'), findsNothing);
    });

    testWidgets('con rúbrica enviada ofrece volver a verla', (tester) async {
      await pumpCard(tester, submitted: true);
      expect(find.text('Evaluado'), findsOneWidget);
      expect(find.text('Ver rúbrica registrada'), findsOneWidget);
    });

    testWidgets('no se corta el nombre en 320 px', (tester) async {
      await pumpCard(tester, size: const Size(320, 640));
      expect(tester.takeException(), isNull);
    });
  });

  group('control segmentado compartido', () {
    testWidgets('el contador no se pega al nombre y marca selección',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AppSegmentOption(
          label: 'Todos',
          count: 12,
          selected: true,
          onTap: _noop,
          style: AppSegmentStyle.filled,
        )),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byType(AppSegmentOption), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

void _noop() {}