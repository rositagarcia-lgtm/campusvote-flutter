import '../../domain/entities/ballot.dart';
import '../../domain/entities/candidate_list.dart';
import '../../domain/entities/election_position.dart';
import 'candidate_list_model.dart';
import 'election_position_model.dart';

/// Modela el contrato real:
/// - GET /api/ballots/election/:electionId/active → { id, version, generatedAt }
/// - GET /api/ballots/:ballotId/positions        → array de BallotPosition con
///   { id, ballotId, positionId, orderIndex, position, ballotOptions[] }
/// - ballotOptions: { id, optionType, candidateListId, label, orderIndex }
class BallotModel extends Ballot {
  const BallotModel({
    required super.id,
    required super.electionId,
    required super.version,
    required super.positions,
  });

  static String _str(dynamic v) => (v ?? '').toString();
  static int _int(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static ElectionPosition _readPosition(Map<String, dynamic> m) {
    // El backend anida el cargo en `position`; en otros formatos puede venir plano.
    if (m['position'] is Map) {
      final pos = Map<String, dynamic>.from(m['position'] as Map);
      return ElectionPositionModel.fromJson({
        'id': pos['id'],
        'name': pos['name'],
        'description': pos['description'],
        'seats': pos['seats'],
      });
    }
    return ElectionPositionModel.fromJson({
      'id': m['positionId'] ?? m['position_id'],
      'name': m['name'],
      'description': m['description'],
      'seats': m['seats'] ?? 1,
    });
  }

  static BallotOptionType _parseType(dynamic v) {
    final raw = (v ?? '').toString().toUpperCase();
    if (raw == 'BLANK') return BallotOptionType.blank;
    if (raw == 'VOID') return BallotOptionType.none;
    return BallotOptionType.candidateList;
  }

  static BallotOption _readOption(Map<String, dynamic> o) {
    final id = _str(o['id']);
    final type = _parseType(o['optionType'] ?? o['option_type']);
    final label = _str(o['label']);
    final listId =
        (o['candidateListId'] ?? o['candidate_list_id'])?.toString();

    CandidateList? list;
    if (o['candidateList'] is Map) {
      list = CandidateListModel.fromJson(
        Map<String, dynamic>.from(o['candidateList'] as Map),
      );
    } else if (listId != null && listId.isNotEmpty) {
      list = CandidateList(
        id: listId,
        name: label.isNotEmpty ? label : 'Lista',
      );
    }

    return BallotOption(
      id: id.isNotEmpty ? id : listId ?? '',
      type: type,
      label: label,
      list: list,
    );
  }

  factory BallotModel.fromJson(Map<String, dynamic> json) {
    final rawList = (json['positions'] is List)
        ? json['positions'] as List
        : (json['ballotPositions'] is List
            ? json['ballotPositions'] as List
            : const []);

    final positions = <BallotPosition>[];
    for (final raw in rawList) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final pos = _readPosition(m);
      final orderIndex = _int(m['orderIndex'] ?? m['order_index'], 1);

      final optionsRaw = (m['options'] is List)
          ? m['options'] as List
          : (m['ballotOptions'] is List
              ? m['ballotOptions'] as List
              : const []);
      final options = <BallotOption>[];
      for (final oRaw in optionsRaw) {
        if (oRaw is! Map) continue;
        options.add(_readOption(Map<String, dynamic>.from(oRaw)));
      }

      positions.add(BallotPosition(
        id: _str(m['id']),
        position: pos,
        orderIndex: orderIndex,
        options: options,
        allowsBlank: true,
        allowsVoid: true,
      ));
    }

    return BallotModel(
      id: _str(json['id']),
      electionId:
          _str(json['electionId'] ?? json['election_id'] ?? ''),
      version: _int(json['version'], 1),
      positions: positions,
    );
  }

  Ballot toEntity() => this;
}