import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_state.dart';
import 'package:flutter_test/flutter_test.dart';

FairProjectModel _p(String id, String name) => FairProjectModel(
      id: id,
      fairId: 'f-1',
      name: name,
      description: '',
      status: 'APPROVED',
    );

void main() {
  final state = VotingFormState(
    loading: false,
    projects: [
      _p('a', 'Zeta'),
      _p('b', 'Alfa'),
      _p('c', 'Brazo Robótico'),
      _p('d', 'Drone'),
    ],
    scores: const {'a': 12.0, 'c': 18.5, 'd': 15.0},
  );

  test('ordena de mayor a menor puntaje propio y deja los no evaluados al final', () {
    expect(state.rankedProjects.map((p) => p.id), ['c', 'd', 'a', 'b']);
  });

  test('la posición solo existe para proyectos con rúbrica finalizada', () {
    expect(state.rankOf('c'), 1);
    expect(state.rankOf('d'), 2);
    expect(state.rankOf('a'), 3);
    expect(state.rankOf('b'), isNull);
  });

  test('sin puntajes, el orden es alfabético', () {
    final empty = VotingFormState(loading: false, projects: state.projects);
    expect(empty.rankedProjects.map((p) => p.name),
        ['Alfa', 'Brazo Robótico', 'Drone', 'Zeta']);
  });
}
