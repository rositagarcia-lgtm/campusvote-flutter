/// Modelos del panel de jurado.
///
/// Contrato real del backend (`src/modules/juryAssignments`,
/// `fairEvaluations`, `fairVoting`, `fairResults`): snake_case → camelCase.
/// `fromJson`/`toJson` manuales, sin freezed.
library;

DateTime? _date(dynamic v) =>
    (v is String && v.isNotEmpty) ? DateTime.tryParse(v)?.toLocal() : null;

String? _text(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> _mapList(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

/// Estado de la feria (DRAFT / OPEN / CLOSED).
enum FairStatus { draft, open, closed, unknown }

FairStatus parseFairStatus(String? raw) => switch (raw?.toUpperCase()) {
      'DRAFT' => FairStatus.draft,
      'OPEN' => FairStatus.open,
      'CLOSED' => FairStatus.closed,
      _ => FairStatus.unknown,
    };

/// `GET /fairs/my-assignments` → item de `data[]`.
class FairAssignmentModel {
  const FairAssignmentModel({
    required this.fairId,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.status,
    this.imageUrl,
    this.startsAt,
    this.endsAt,
    this.assignedAt,
    this.organizationName,
    this.siteName,
  });

  final String fairId;
  final String organizationId;
  final String name;
  final String description;
  final FairStatus status;
  final String? imageUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? assignedAt;
  final String? organizationName;
  final String? siteName;

  bool get isOpen => status == FairStatus.open;
  bool get isClosed => status == FairStatus.closed;

  factory FairAssignmentModel.fromJson(Map<String, dynamic> json) {
    // El backend envuelve la feria: { assigned_at, fair: {...} }.
    final fair = json['fair'] is Map ? _map(json['fair']) : json;
    return FairAssignmentModel(
      fairId: _text(fair['id']) ?? '',
      organizationId: _text(fair['organization_id']) ?? '',
      name: _text(fair['name']) ?? '',
      description: fair['description']?.toString() ?? '',
      status: parseFairStatus(_text(fair['status'])),
      imageUrl: _text(fair['image_url'] ?? fair['imageUrl']),
      startsAt: _date(fair['starts_at'] ?? fair['startsAt']),
      endsAt: _date(fair['ends_at'] ?? fair['endsAt']),
      assignedAt: _date(json['assigned_at'] ?? json['assignedAt']),
      organizationName:
          _text(fair['organization_name'] ?? fair['organizationName']),
      siteName: _text(fair['site_name'] ?? fair['siteName']),
    );
  }

  Map<String, dynamic> toJson() => {
        'assigned_at': assignedAt?.toIso8601String(),
        'fair': {
          'id': fairId,
          'organization_id': organizationId,
          'organization_name': organizationName,
          'site_name': siteName,
          'name': name,
          'description': description,
          'status': status.name.toUpperCase(),
          'image_url': imageUrl,
          'starts_at': startsAt?.toIso8601String(),
          'ends_at': endsAt?.toIso8601String(),
        },
      };
}

/// `GET /fairs/:fairId/projects` → item de `data[]`.
///
/// `mapApprovedProject` solo incluye proyectos APROBADOS de las categorías
/// asignadas al jurado: la app NO debe re-filtrar (regla 7).
class FairProjectModel {
  const FairProjectModel({
    required this.id,
    required this.fairId,
    required this.name,
    required this.description,
    required this.status,
    this.logoUrl,
    this.coverUrl,
    this.imageUrls = const [],
    this.videoUrl,
    this.categoryId,
    this.categoryName,
    this.standId,
    this.standCode,
  });

  final String id;
  final String fairId;
  final String name;
  final String description;
  final String status;
  final String? logoUrl;
  final String? coverUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? categoryId;
  final String? categoryName;
  final String? standId;
  final String? standCode;

  factory FairProjectModel.fromJson(Map<String, dynamic> json) {
    final category = _map(json['category']);
    final stand = _map(json['stand']);
    return FairProjectModel(
      id: _text(json['id']) ?? '',
      fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
      name: _text(json['name']) ?? '',
      description: json['description']?.toString() ?? '',
      status: _text(json['status']) ?? 'UNKNOWN',
      logoUrl: _text(json['logo_url'] ?? json['logoUrl']),
      coverUrl: _text(json['cover_url'] ?? json['coverUrl']),
      imageUrls: (json['image_urls'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      videoUrl: _text(json['video_url'] ?? json['videoUrl']),
      categoryId: _text(category['id'] ?? json['category_id']),
      categoryName: _text(category['name']),
      standId: _text(stand['id'] ?? json['stand_id']),
      standCode: _text(stand['code']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fair_id': fairId,
        'name': name,
        'description': description,
        'status': status,
        'logo_url': logoUrl,
        'cover_url': coverUrl,
        'image_urls': imageUrls,
        'video_url': videoUrl,
        'category': {'id': categoryId, 'name': categoryName},
        'stand': {'id': standId, 'code': standCode},
      };
}

/// Criterio de la rúbrica (checklist). `isActive=false` no admite respuestas:
/// el backend responde 409 (`normalizeChecklistResponses`).
class RubricCriterionModel {
  const RubricCriterionModel({
    required this.id,
    required this.name,
    required this.position,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int position;
  final String? description;
  final bool isActive;

  factory RubricCriterionModel.fromJson(Map<String, dynamic> json) =>
      RubricCriterionModel(
        id: _text(json['id']) ?? '',
        name: _text(json['name']) ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
        description: _text(json['description']),
        isActive: (json['is_active'] ?? json['isActive'] ?? true) == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'position': position,
        'is_active': isActive,
      };
}

/// Rúbrica resuelta por el backend para la categoría del proyecto.
class RubricModel {
  const RubricModel({
    required this.id,
    required this.name,
    required this.criteria,
    this.description,
    this.categoryId,
  });

  final String id;
  final String name;
  final String? description;
  final String? categoryId;

  /// Ya viene filtrada a criterios ACTIVOS en `getMyChecklist`.
  final List<RubricCriterionModel> criteria;

  factory RubricModel.fromJson(Map<String, dynamic> json) {
    final list = _mapList(json['criteria'])
        .map(RubricCriterionModel.fromJson)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return RubricModel(
      id: _text(json['id']) ?? '',
      name: _text(json['name']) ?? '',
      description: _text(json['description']),
      categoryId: _text(json['category_id'] ?? json['categoryId']),
      criteria: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category_id': categoryId,
        'criteria': criteria.map((c) => c.toJson()).toList(),
      };
}

/// Una respuesta marcada del jurado.
class RubricResponseModel {
  const RubricResponseModel({
    required this.criterionId,
    required this.checked,
    this.criterionName,
    this.criterionPosition,
  });

  final String criterionId;
  final bool checked;
  final String? criterionName;
  final int? criterionPosition;

  factory RubricResponseModel.fromJson(Map<String, dynamic> json) =>
      RubricResponseModel(
        criterionId: _text(json['criterion_id'] ?? json['criterionId']) ?? '',
        checked: (json['checked'] ?? false) == true,
        criterionName: _text(json['criterion_name'] ?? json['criterionName']),
        criterionPosition:
            (json['criterion_position'] ?? json['criterionPosition']) as int?,
      );

  /// El PUT es `.strict()`: SOLO admite `criterion_id` y `checked`.
  Map<String, dynamic> toJson() => {
        'criterion_id': criterionId,
        'checked': checked,
      };
}

/// Hoja de evaluación del jurado para un proyecto.
///
/// `GET /fairs/:fairId/projects/:projectId/rubric` devuelve esta misma forma
/// (`mapEvaluation` + `rubric`), con `submitted` en false si aún no existe.
class RubricEvaluationModel {
  const RubricEvaluationModel({
    required this.fairId,
    required this.projectId,
    required this.rubric,
    required this.submitted,
    required this.responses,
    this.projectName,
    this.projectStatus,
    this.categoryName,
    this.checkedCount,
    this.criteriaCount,
    this.score,
    this.submittedAt,
  });

  final String fairId;
  final String projectId;
  final String? projectName;
  final String? projectStatus;
  final String? categoryName;
  final RubricModel rubric;
  final bool submitted;
  final DateTime? submittedAt;
  final int? checkedCount;
  final int? criteriaCount;

  /// 0.0 – 20.0, calculado por el backend.
  final double? score;
  final List<RubricResponseModel> responses;

  int get totalCriteria => rubric.criteria.length;

  factory RubricEvaluationModel.fromJson(Map<String, dynamic> json) {
    final project = _map(json['project']);
    final rubricJson = json['rubric'];
    return RubricEvaluationModel(
      fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
      projectId: _text(json['project_id'] ?? json['projectId']) ?? '',
      projectName: _text(project['name']),
      projectStatus: _text(project['status']),
      categoryName: _text(_map(project['category'])['name']),
      rubric: rubricJson is Map
          ? RubricModel.fromJson(_map(rubricJson))
          : const RubricModel(id: '', name: '', criteria: []),
      submitted: (json['submitted'] ?? false) == true,
      submittedAt: _date(json['submitted_at'] ?? json['submittedAt']),
      checkedCount: (json['checked_count'] ?? json['checkedCount']) as int?,
      criteriaCount: (json['criteria_count'] ?? json['criteriaCount']) as int?,
      score: (json['score'] as num?)?.toDouble(),
      responses: _mapList(json['responses'])
          .map(RubricResponseModel.fromJson)
          .toList(),
    );
  }
}

/// `GET /fairs/:fairId/voting/status`.
class VotingStatusModel {
  const VotingStatusModel({
    required this.fairId,
    required this.fairStatus,
    required this.hasVoted,
    this.votedAt,
  });

  final String fairId;
  final FairStatus fairStatus;
  final bool hasVoted;
  final DateTime? votedAt;

  /// El voto solo se emite con la feria OPEN y sin haber votado.
  bool get isOpen => fairStatus == FairStatus.open;
  bool get canVote => isOpen && !hasVoted;

  factory VotingStatusModel.fromJson(Map<String, dynamic> json) =>
      VotingStatusModel(
        fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
        fairStatus:
            parseFairStatus(_text(json['fair_status'] ?? json['fairStatus'])),
        hasVoted: (json['has_voted'] ?? json['hasVoted'] ?? false) == true,
        votedAt: _date(json['voted_at'] ?? json['votedAt']),
      );
}

/// Recibo anónimo de `POST /fairs/:fairId/votes`.
class VoteReceiptModel {
  const VoteReceiptModel({required this.status, required this.receiptCode});

  final String status;
  final String receiptCode;

  factory VoteReceiptModel.fromJson(Map<String, dynamic> json) =>
      VoteReceiptModel(
        status: _text(json['status']) ?? 'CAST',
        receiptCode: _text(json['receipt_code'] ?? json['receiptCode']) ?? '',
      );
}

/// Declaración derii neutro del jurado.
class JuryDeclarationModel {
  const JuryDeclarationModel({
    required this.id,
    required this.fairId,
    required this.statement,
    this.signedAt,
  });

  final String id;
  final String fairId;
  final String statement;
  final DateTime? signedAt;

  factory JuryDeclarationModel.fromJson(Map<String, dynamic> json) =>
      JuryDeclarationModel(
        id: _text(json['id']) ?? '',
        fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
        statement: json['statement']?.toString() ?? '',
        signedAt: _date(json['signed_at'] ?? json['signedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fair_id': fairId,
        'statement': statement,
        'signed_at': signedAt?.toIso8601String(),
      };
}

/// `GET /fairs/:fairId/jury/declaration`.
class JuryDeclarationStatusModel {
  const JuryDeclarationStatusModel({
    required this.fairId,
    required this.signed,
    this.declaration,
  });

  final String fairId;
  final bool signed;
  final JuryDeclarationModel? declaration;

  factory JuryDeclarationStatusModel.fromJson(Map<String, dynamic> json) {
    final d = json['declaration'];
    return JuryDeclarationStatusModel(
      fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
      signed: (json['signed'] ?? false) == true,
      declaration: d is Map ? JuryDeclarationModel.fromJson(_map(d)) : null,
    );
  }
}

/// `GET /fairs/my-progress/:fairId`.
class JuryProgressModel {
  const JuryProgressModel({
    required this.fairId,
    required this.totalProjects,
    required this.completedProjects,
    required this.pendingProjects,
    required this.progressPercentage,
    required this.hasVoted,
    this.fairName,
    this.fairStatus = FairStatus.unknown,
    this.declaration,
  });

  final String fairId;
  final String? fairName;
  final FairStatus fairStatus;
  final int totalProjects;
  final int completedProjects;
  final int pendingProjects;

  /// 0 – 100, redondeado por el backend.
  final int progressPercentage;
  final bool hasVoted;
  final JuryDeclarationModel? declaration;

  bool get isComplete =>
      totalProjects > 0 && completedProjects >= totalProjects;

  /// `JuryProgressBar`:evaluatedProjects / totalProjects.
  double get ratio =>
      totalProjects == 0 ? 0 : completedProjects / totalProjects;

  factory JuryProgressModel.fromJson(Map<String, dynamic> json) {
    final d = json['declaration'];
    return JuryProgressModel(
      fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
      fairName: _text(json['fair_name'] ?? json['fairName']),
      fairStatus:
          parseFairStatus(_text(json['fair_status'] ?? json['fairStatus'])),
      totalProjects: (json['total_projects'] ?? 0) as int,
      completedProjects: (json['completed_projects'] ?? 0) as int,
      pendingProjects: (json['pending_projects'] ?? 0) as int,
      progressPercentage: (json['progress_percentage'] ?? 0) as int,
      hasVoted: (json['has_voted'] ?? false) == true,
      declaration: d is Map ? JuryDeclarationModel.fromJson(_map(d)) : null,
    );
  }
}

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
    final project = _map(json['project']);
    return JuryEvaluationSummaryModel(
      id: _text(json['id']) ?? '',
      fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
      projectId: _text(json['project_id'] ?? json['projectId']) ?? '',
      projectName: _text(project['name']),
      projectStatus: _text(project['status']),
      submitted: (json['submitted'] ?? false) == true,
      submittedAt: _date(json['submitted_at'] ?? json['submittedAt']),
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
        projectId: _text(json['project_id'] ?? json['projectId']) ?? '',
        name: _text(json['name'] ?? json['project_name']) ?? '',
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
    final by = _map(json['published_by']);
    final name = [
      _text(by['first_name'] ?? by['firstName']),
      _text(by['last_name'] ?? by['lastName']),
    ].whereType<String>().where((e) => e.isNotEmpty).join(' ');
    return FairResultsModel(
      fairId: _text(json['fair_id'] ?? json['fairId']) ?? '',
      fairStatus:
          parseFairStatus(_text(json['fair_status'] ?? json['fairStatus'])),
      published: (json['published'] ?? false) == true,
      publishedAt: _date(json['published_at'] ?? json['publishedAt']),
      publishedByName: name.isEmpty ? null : name,
      ranking:
          _mapList(json['ranking']).map(FairResultEntryModel.fromJson).toList(),
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
