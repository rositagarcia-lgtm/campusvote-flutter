import '../../domain/entities/rubric_response.dart';

/// Mapeo de la hoja de respuestas de rúbrica del JURY.
///
/// Backend entrega:
///   {
///     id, fair_id, project_id, rubric_id,
///     submitted (bool), submitted_at, created_at, updated_at,
///     responses: [{ criterion_id, criterion_name, criterion_position, checked }]
///   }
class RubricResponseModel extends RubricResponse {
  const RubricResponseModel({
    required super.fairId,
    required super.projectId,
    required super.rubricId,
    required super.submitted,
    super.submittedAt,
    super.createdAt,
    super.updatedAt,
    required super.answers,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory RubricResponseModel.fromJson(Map<String, dynamic> json) {
    final answers = <String, bool>{};
    final raw = json['responses'];
    if (raw is List) {
      for (final r in raw.whereType<Map>()) {
        final m = Map<String, dynamic>.from(r);
        final cid = (m['criterion_id'] ?? m['criterionId'] ?? '').toString();
        if (cid.isEmpty) continue;
        answers[cid] = (m['checked'] ?? false) == true;
      }
    }
    return RubricResponseModel(
      fairId: (json['fair_id'] ?? json['fairId'] ?? '').toString(),
      projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
      rubricId: (json['rubric_id'] ?? json['rubricId'] ?? '').toString(),
      submitted: (json['submitted'] ?? false) == true,
      submittedAt: _parseDate(json['submitted_at'] ?? json['submittedAt']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      answers: answers,
    );
  }

  RubricResponse toEntity() => this;
}
