import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/fair_audience/data/fair_audience_repository.dart';
import 'package:campusvote_flutter/features/fair_audience/domain/audience_models.dart';
import 'package:campusvote_flutter/features/fair_audience/presentation/peer_feedback_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra al equipo comentarios anónimos sin revelar autores',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        peerFeedbackProvider((fairId: 'f1', projectId: 'p1'))
            .overrideWith((_) async => const PeerFeedback(
                  votes: 3,
                  average: 4.3,
                  comments: ['Mejorar la autonomía de la batería'],
                )),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: PeerFeedbackSection(fairId: 'f1', projectId: 'p1'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mejorar la autonomía de la batería'), findsOneWidget);
    expect(find.text('3 votos de compañeros'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
