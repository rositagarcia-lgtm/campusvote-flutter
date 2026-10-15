import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/jury_state.dart';
import 'package:flutter_test/flutter_test.dart';

FairProjectModel _project(String id, String category) =>
    FairProjectModel.fromJson({
      'id': id,
      'name': 'Proyecto $id',
      'status': 'APPROVED',
      'category': {'id': category, 'name': category},
    });

void main() {
  final status = VotingStatusModel.fromJson({
    'fair_id': 'f1',
    'fair_status': 'OPEN',
    'voting_window': 'OPEN',
    'has_voted': false,
    'categories': [
      {'category_id': 'tec', 'category_name': 'Tecnología', 'has_voted': false},
    ],
  });

  test('el jurado solo ve y vota proyectos de su categoría', () {
    final state = VotingFormState(
      loading: false,
      status: status,
      activeCategoryId: 'tec',
      projects: [_project('a', 'tec'), _project('b', 'cien')],
    );
    expect(state.visibleProjects.map((p) => p.id), ['a']);
    expect(state.canVote, isTrue);
    expect(state.activeCategory!.name, 'Tecnología');
  });

  test('tras votar en su categoría ya no puede votar de nuevo', () {
    final voted = status.withCategoryVoted('tec');
    final state = VotingFormState(
      loading: false,
      status: voted,
      activeCategoryId: 'tec',
    );
    expect(voted.hasVoted, isTrue);
    expect(state.hasVoted, isTrue);
    expect(state.canVote, isFalse);
  });

  test('excepción con dos categorías: vota en cada una, solo en las asignadas',
      () {
    final two = VotingStatusModel.fromJson({
      'fair_id': 'f1',
      'fair_status': 'OPEN',
      'voting_window': 'OPEN',
      'categories': [
        {
          'category_id': 'tec',
          'category_name': 'Tecnología',
          'has_voted': false
        },
        {
          'category_id': 'cien',
          'category_name': 'Ciencias',
          'has_voted': false
        },
      ],
    });
    final afterFirst = two.withCategoryVoted('tec');
    final state = VotingFormState(
      loading: false,
      status: afterFirst,
      activeCategoryId: 'tec',
      projects: [
        _project('a', 'tec'),
        _project('b', 'cien'),
        _project('c', 'arte')
      ],
    );
    expect(afterFirst.hasVoted, isFalse);
    expect(state.canVote, isFalse);
    expect(state.nextPendingCategory!.id, 'cien');
    // Nunca aparecen proyectos de una categoría no asignada.
    final inCiencias = VotingFormState(
      loading: false,
      status: afterFirst,
      activeCategoryId: 'cien',
      projects: state.projects,
    );
    expect(inCiencias.visibleProjects.map((p) => p.id), ['b']);
    expect(inCiencias.canVote, isTrue);
  });
}
