import 'package:campusvote_flutter/features/voting/domain/usecases/ballot_usecases.dart';
import 'package:campusvote_flutter/features/voting/domain/repositories/voting_repository.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/voting/domain/entities/voting_receipt.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements VotingRepository {
  String? lastSessionId;
  List<String>? lastOptionIds;
  Map<String, dynamic>? lastSelections;

  @override
  Future<Result<VotingReceipt>> castVote({
    required String sessionId,
    required List<String> optionIds,
    required Map<String, dynamic> rawSelections,
  }) async {
    lastSessionId = sessionId;
    lastOptionIds = optionIds;
    lastSelections = rawSelections;
    return Success(
      VotingReceipt(receiptCode: 'abc123', castAt: DateTime(2025)),
    );
  }

  // No usados en este test
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CastVoteUseCase', () {
    test('forwards selections to repo', () async {
      final repo = _FakeRepo();
      final useCase = CastVoteUseCase(repo);
      final res = await useCase(
        sessionId: 'sess',
        optionIds: ['opt1', 'opt2'],
        rawSelections: {'k': 'v'},
      );
      expect(res, isA<Success<VotingReceipt>>());
      expect(repo.lastSessionId, 'sess');
      expect(repo.lastOptionIds, ['opt1', 'opt2']);
      expect(repo.lastSelections?['k'], 'v');
    });
  });
}