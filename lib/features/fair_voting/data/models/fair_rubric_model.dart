import '../../domain/entities/fair_rubric.dart';

/// Mapeo de `GET /api/fairs/:id/rubric` para JURY.
///
/// Backend entrega:
///   { id, fair_id, name, description,
///     criteria: [{ id, name, description, position, is_active }] }
class FairRubricModel extends FairRubric {
  const FairRubricModel({
    required super.id,
    required super.fairId,
    required super.name,
    super.description,
    required super.criteria,
  });

  factory FairRubricModel.fromJson(Map<String, dynamic> json) {
    final rawCriteria = json['criteria'];
    final criteria = <FairRubricCriterion>[];
    if (rawCriteria is List) {
      for (final c in rawCriteria.whereType<Map>()) {
        final m = Map<String, dynamic>.from(c);
        criteria.add(FairRubricCriterion(
          id: (m['id'] ?? '').toString(),
          name: (m['name'] ?? '').toString(),
          description: m['description']?.toString(),
          position: (m['position'] ?? 0) as int,
          isActive: (m['is_active'] ?? m['isActive'] ?? true) == true,
        ));
      }
    }
    criteria.sort((a, b) => a.position.compareTo(b.position));
    return FairRubricModel(
      id: (json['id'] ?? '').toString(),
      fairId: (json['fair_id'] ?? json['fairId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      criteria: criteria,
    );
  }
}
