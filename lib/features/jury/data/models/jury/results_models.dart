import 'common.dart';

/// Hoja de la lista `GET /fairs/my-evaluations` (`mapEvaluation`).
class JuryEvaluationSummaryModel {
  const JuryEvaluationSummaryModel({
    required this.id,
    required this.fairId,
    required this.projectId,
    required this.submitted,
    this.projectName,
    this.projectStatus,
    this.checkedCount,
    this.criteriaCount,
    this.score,
    this.submittedAt,
  });

  final String id;
  final String fairId;
  final String projectId;
  final String? projectName;
  final String? projectStatus;
  final bool submitted;
  final DateTime? submittedAt;
  final int? checkedCount;
  final int? criteriaCount;
  final double? score;

  factory JuryEvaluationSummaryModel.fromJson(Map<String, dynamic> json) {
    final project = asMap(json['project']);
    return JuryEvaluationSummaryModel(
      id: parseText(json['id']) ?? '',
      fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
      projectId: parseText(json['project_id'] ?? json['projectId']) ?? '',
      projectName: parseText(project['name']),
      projectStatus: parseText(project['status']),
      submitted: (json['submitted'] ?? false) == true,
      submittedAt: parseDate(json['submitted_at'] ?? json['submittedAt']),
      checkedCount: (json['checked_count'] ?? json['checkedCount']) as int?,
      criteriaCount: (json['criteria_count'] ?? json['criteriaCount']) as int?,
      score: (json['score'] as num?)?.toDouble(),
    );
  }
}

/// Envoltorio paginado `{ data, meta.pagination }`.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;

  int get totalPages => limit == 0 ? 1 : (total + limit - 1) ~/ limit;

  /// Factory (no static) porque un `static` no puede referenciar el `T` de la
  /// clase. Desenvuelve `{ data: [...], meta: { pagination } }`.
  factory PaginatedResult.fromEnvelope(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) parse,
  ) {
    final data = body['data'];
    final raw = data is List
        ? data
        : (data is Map && data['data'] is List
            ? data['data'] as List
            : const <dynamic>[]);
    final meta = body['meta'];
    final pagination =
        meta is Map ? Map<String, dynamic>.from(meta) : <String, dynamic>{};
    final items = raw
        .whereType<Map>()
        .map((e) => parse(Map<String, dynamic>.from(e)))
        .toList();
    return PaginatedResult<T>(
      items: items,
      total: (pagination['total'] ?? items.length) as int,
      page: (pagination['page'] ?? 1) as int,
      limit: (pagination['limit'] ?? 20) as int,
    );
  }
}
