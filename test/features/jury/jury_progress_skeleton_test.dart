import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/widgets/app_empty_view.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/domain/repositories/jury_repository.dart';
import 'package:campusvote_flutter/features/jury/presentation/pages/jury_progress_page.dart';
import 'package:campusvote_flutter/features/jury/presentation/progress/widgets/jury_panel.dart';
import 'package:campusvote_flutter/features/jury/presentation/progress/widgets/jury_progress_skeleton.dart';
import 'package:campusvote_flutter/features/jury/presentation/progress/widgets/jury_progress_view.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/data/jury_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _oldFair = JuryProgressModel(
  fairId: 'old',
  fairName: 'Feria Tecnológica 2022',
  fairStatus: FairStatus.closed,
  totalProjects: 4,
  completedProjects: 4,
  pendingProjects: 0,
  progressPercentage: 100,
  hasVoted: true,
  declaration: JuryDeclarationModel(
    id: 'decl-old',
    fairId: 'old',
    statement: 'Declaro no tener conflicto de interés con los proyectos.',
  ),
);

const _recentFair = JuryProgressModel(
  fairId: 'recent',
  fairName: 'Feria Tecsup 2026',
  fairStatus: FairStatus.open,
  totalProjects: 3,
  completedProjects: 1,
  pendingProjects: 2,
  progressPercentage: 33,
  hasVoted: false,
);

const _emptyFair = JuryProgressModel(
  fairId: 'empty',
  fairName: 'Feria sin proyectos',
  fairStatus: FairStatus.open,
  totalProjects: 0,
  completedProjects: 0,
  pendingProjects: 0,
  progressPercentage: 0,
  hasVoted: false,
);

const _assignments = [
  FairAssignmentModel(
    fairId: 'old',
    organizationId: 'o1',
    name: 'Feria Tecnológica 2022',
    description: '',
    status: FairStatus.closed,
    siteName: 'Campus Tecsup — Ate',
    endsAt: null,
  ),
  FairAssignmentModel(
    fairId: 'recent',
    organizationId: 'o1',
    name: 'Feria Tecsup 2026',
    description: '',
    status: FairStatus.open,
    siteName: 'Campus Tecsup — Lima',
    // Sin fecha de cierre: el test no depende de un contador con Timer.
    endsAt: null,
  ),
];

class _FakeRepo implements JuryRepository {
  _FakeRepo({this.failOld = false});

  final bool failOld;

  @override
  Future<JuryProgressModel> getMyProgress(String fairId) async {
    if (failOld && fairId == 'old') throw Exception('servidor no disponible');
    return switch (fairId) {
      'old' => _oldFair,
      'empty' => _emptyFair,
      _ => _recentFair,
    };
  }

  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async =>
      VotingStatusModel(
        fairId: fairId,
        fairStatus: fairId == 'old' ? FairStatus.closed : FairStatus.open,
        hasVoted: fairId == 'old',
      );

  @override
  Future<PaginatedResult<FairAssignmentModel>> getMyAssignments({
    int page = 1,
    int limit = 50,
  }) async =>
      PaginatedResult(
        items: _assignments,
        total: _assignments.length,
        page: page,
        limit: limit,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Drena todos los errores de renderizado acumulados en el frame actual.
List<Object> _renderErrors(WidgetTester tester) {
  final errors = <Object>[];
  while (true) {
    final error = tester.takeException();
    if (error == null) return errors;
    errors.add(error);
  }
}

void _expectNoRenderError(WidgetTester tester, String reason) {
  expect(_renderErrors(tester), isEmpty, reason: reason);
}

void _setViewport(WidgetTester tester, {double width = 390, double height = 800}) {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
}

Widget _skeletonApp({bool dark = false}) => MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: const Scaffold(body: JuryProgressSkeleton()),
    );

Widget _pageApp(
  String fairId, {
  required _FakeRepo repo,
  required LocalStorage storage,
}) =>
    ProviderScope(
      overrides: [
        juryRepositoryProvider.overrideWithValue(repo),
        localStorageProvider.overrideWithValue(storage),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: JuryProgressPage(fairId: fairId),
      ),
    );

Widget _viewApp(
  JuryProgressModel progress, {
  required _FakeRepo repo,
  required LocalStorage storage,
}) =>
    ProviderScope(
      overrides: [
        juryRepositoryProvider.overrideWithValue(repo),
        localStorageProvider.overrideWithValue(storage),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: JuryProgressView(fairId: progress.fairId, progress: progress),
        ),
      ),
    );

void main() {
  late LocalStorage storage;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.create();
  });

  testWidgets('1. Skeleton de Mi progreso sin overflow en varios tamaños',
      (tester) async {
    _setViewport(tester);
    for (final width in [320.0, 360.0, 390.0, 430.0, 768.0]) {
      for (final height in [640.0, 800.0]) {
        tester.view.physicalSize = Size(width, height);
        await tester.pumpWidget(_skeletonApp());
        await tester.pump();
        _expectNoRenderError(tester, 'skeleton ${width.toInt()}x${height.toInt()}');
        expect(find.byType(JuryPanel), findsNWidgets(5),
            reason: 'dos tarjetas + tres etapas en ${width.toInt()}px');
      }
    }
  });

  testWidgets('1b. Skeleton respeta tema oscuro y ancho estrecho', (tester) async {
    _setViewport(tester, width: 320, height: 640);
    await tester.pumpWidget(_skeletonApp(dark: true));
    await tester.pump();
    _expectNoRenderError(tester, 'skeleton oscuro 320px');
  });

  testWidgets('2. Tarjetas con distinta cantidad de contenido', (tester) async {
    _setViewport(tester);
    final repo = _FakeRepo();
    for (final progress in [_recentFair, _oldFair, _emptyFair]) {
      await tester.pumpWidget(_viewApp(progress, repo: repo, storage: storage));
      await tester.pump();
      _expectNoRenderError(tester, 'contenido de ${progress.fairId}');
      expect(find.byType(JuryPanel), findsWidgets);
    }
  });

  testWidgets('3. Contenido cargado sin overflow en cinco anchos', (tester) async {
    _setViewport(tester);
    final repo = _FakeRepo();
    for (final width in [320.0, 360.0, 390.0, 430.0, 768.0]) {
      tester.view.physicalSize = Size(width, 800);
      for (final progress in [_recentFair, _oldFair]) {
        await tester.pumpWidget(_viewApp(progress, repo: repo, storage: storage));
        await tester.pump();
        _expectNoRenderError(
            tester, '${progress.fairId} a ${width.toInt()}px');
      }
    }
  });

  testWidgets('4. Cambio entre ferias reciente y antigua, y reingreso',
      (tester) async {
    _setViewport(tester);
    final repo = _FakeRepo();

    await tester.pumpWidget(_pageApp('recent', repo: repo, storage: storage));
    await tester.pump();
    expect(find.text('Feria Tecsup 2026'), findsWidgets);
    _expectNoRenderError(tester, 'feria reciente');

    await tester.pumpWidget(_pageApp('old', repo: repo, storage: storage));
    // Cada feria tiene su propio estado de carga: no se reutiliza el Skeleton
    // ni se muestra contenido de la feria anterior.
    expect(find.byType(JuryProgressSkeleton), findsOneWidget);
    expect(find.text('Feria Tecsup 2026'), findsNothing);
    _expectNoRenderError(tester, 'carga de feria antigua');

    await tester.pump();
    expect(find.byType(JuryProgressSkeleton), findsNothing);
    expect(find.text('Feria Tecnológica 2022'), findsWidgets);
    expect(find.text('Feria Tecsup 2026'), findsNothing);
    _expectNoRenderError(tester, 'datos de feria antigua');

    await tester.pumpWidget(_pageApp('recent', repo: repo, storage: storage));
    await tester.pump();
    expect(find.text('Feria Tecsup 2026'), findsWidgets);
    expect(find.text('Feria Tecnológica 2022'), findsNothing);
    _expectNoRenderError(tester, 'reingreso a feria reciente');
  });

  testWidgets('5. Ingreso directo a feria antigua', (tester) async {
    _setViewport(tester, width: 320, height: 640);
    await tester.pumpWidget(_pageApp('old', repo: _FakeRepo(), storage: storage));
    await tester.pump();
    expect(find.text('Feria Tecnológica 2022'), findsWidgets);
    expect(find.text('Cerrada'), findsWidgets);
    _expectNoRenderError(tester, 'ingreso a feria antigua');
  });

  testWidgets('6. Transición de carga a contenido', (tester) async {
    _setViewport(tester);
    await tester.pumpWidget(_pageApp('recent', repo: _FakeRepo(), storage: storage));
    expect(find.byType(JuryProgressSkeleton), findsOneWidget);
    _expectNoRenderError(tester, 'estado de carga');

    await tester.pump();
    expect(find.byType(JuryProgressSkeleton), findsNothing);
    expect(find.text('Feria Tecsup 2026'), findsWidgets);
    _expectNoRenderError(tester, 'estado con datos');
  });

  testWidgets('7. Estados vacío y de error sin overflow', (tester) async {
    _setViewport(tester);

    await tester.pumpWidget(_pageApp('empty', repo: _FakeRepo(), storage: storage));
    await tester.pump();
    expect(find.text('Feria sin proyectos'), findsWidgets);
    _expectNoRenderError(tester, 'feria sin proyectos');

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AppEmptyView(message: 'No hay proyectos aprobados para evaluar.'),
      ),
    ));
    await tester.pump();
    _expectNoRenderError(tester, 'vista vacía compartida');

    await tester.pumpWidget(_pageApp('old', repo: _FakeRepo(failOld: true), storage: storage));
    await tester.pump();
    expect(find.text('Reintentar'), findsOneWidget);
    _expectNoRenderError(tester, 'vista de error');
  });
}
