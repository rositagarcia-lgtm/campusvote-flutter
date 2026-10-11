import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/fair_audience/data/fair_audience_repository.dart';
import 'package:campusvote_flutter/features/fair_audience/domain/audience_models.dart';
import 'package:campusvote_flutter/features/fair_audience/presentation/audience_projects_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ApiClient extends ApiClient {
  _ApiClient() : super(storage: SecureStorage());

  String? lastPath;
  Object? lastBody;

  @override
  Future<Response<dynamic>> put(String path, {Object? body}) async {
    lastPath = path;
    lastBody = body;
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'success': true, 'data': {}},
    );
  }
}

final _boardJson = {
  'fair': {
    'id': 'f1',
    'name': 'Feria 2026',
    'status': 'CLOSED',
    'can_rate': false
  },
  'min_votes': 3,
  'favorite_project_id': 'p1',
  'projects': [
    {
      'id': 'p1',
      'name': 'Robot reciclador',
      'category': 'Tecnología',
      'stand': 'A-1',
      'votes': 7,
      'average': 4.6,
      'my_score': 5,
    },
    {'id': 'p2', 'name': 'Huerto urbano', 'votes': 1, 'is_mine': true},
  ],
};

void main() {
  test('lee el tablero: favorito, voto propio y promedio oculto', () {
    final board = AudienceBoard.fromJson(_boardJson);
    expect(board.fair.isOpen, isFalse);
    expect(board.favorite!.name, 'Robot reciclador');
    expect(board.projects.first.myScore, 5);
    expect(board.projects.last.isMine, isTrue);
    expect(board.projects.last.average, isNull);
  });

  test('envía el voto con el contrato del backend', () async {
    final api = _ApiClient();
    await FairAudienceRepository(api).rate(
      fairId: 'f1',
      projectId: 'p1',
      score: 4,
      comment: '   ',
    );
    expect(api.lastPath, '/api/fairs/f1/projects/p1/audience-rating');
    expect(api.lastBody, {'score': 4, 'comment': null});
  });

  testWidgets('feria cerrada: favorito del público y tu proyecto marcado',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        audienceBoardProvider('f1')
            .overrideWith((ref) async => AudienceBoard.fromJson(_boardJson)),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const AudienceProjectsPage(fairId: 'f1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('FAVORITO DEL PÚBLICO'), findsOneWidget);
    expect(find.text('Tu voto: 5 ★'), findsOneWidget);
    expect(find.text('Tu proyecto'), findsOneWidget);
    expect(find.text('Promedio desde 3 votos'), findsOneWidget);
    expect(
        find.textContaining('opiniones quedaron congeladas'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // El propio proyecto no se puede calificar.
    await tester.tap(find.text('Huerto urbano'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Es tu proyecto'), findsOneWidget);
    expect(find.text('Enviar mi opinión'), findsNothing);
  });
}
