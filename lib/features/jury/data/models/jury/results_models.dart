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

/// Item del ranking de `GET /fairs/:fairId/results`.
///
/// OJO: el endpoint es ADMIN-only (`fairResult.routes.js:27`), un JURY recibe
/// 403. Se modela igual para cuando el backend lo habilite.
class FairResultEntryModel {
  const FairResultEntryModel({
    required this.projectId,
    required this.name,
    required this.votes,
    this.position,
    this.winner = false,
  });

  final String projectId;
  final String name;
  final int votes;
  final int? position;
  final bool winner;

  factory FairResultEntryModel.fromJson(Map<String, dynamic> json) =>
      FairResultEntryModel(
        projectId: parseText(json['project_id'] ?? json['projectId']) ?? '',
        name: parseText(json['name'] ?? json['project_name']) ?? '',
        votes: (json['votes'] ?? json['vote_count'] ?? 0) as int,
        position: (json['position']) as int?,
        winner: (json['winner'] ?? false) == true,
      );
}

/// `GET /fairs/:fairId/results`.
class FairResultsModel {
  const FairResultsModel({
    required this.fairId,
    required this.fairStatus,
    required this.published,
    required this.ranking,
    this.publishedAt,
    this.publishedByName,
  });

  final String fairId;
  final FairStatus fairStatus;
  final bool published;
  final DateTime? publishedAt;
  final String? publishedByName;
  final List<FairResultEntryModel> ranking;

  factory FairResultsModel.fromJson(Map<String, dynamic> json) {
    final by = asMap(json['published_by']);
    final name = [
      parseText(by['first_name'] ?? by['firstName']),
      parseText(by['last_name'] ?? by['lastName']),
    ].whereType<String>().where((e) => e.isNotEmpty).join(' ');
    return FairResultsModel(
      fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
      fairStatus:
          parseFairStatus(parseText(json['fair_status'] ?? json['fairStatus'])),
      published: (json['published'] ?? false) == true,
      publishedAt: parseDate(json['published_at'] ?? json['publishedAt']),
      publishedByName: name.isEmpty ? null : name,
      ranking:
          asMapList(json['ranking']).map(FairResultEntryModel.fromJson).toList(),
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
