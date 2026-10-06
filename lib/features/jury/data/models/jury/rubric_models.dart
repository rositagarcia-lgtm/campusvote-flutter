import 'common.dart';

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
        id: parseText(json['id']) ?? '',
        name: parseText(json['name']) ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
        description: parseText(json['description']),
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
    final list = asMapList(json['criteria'])
        .map(RubricCriterionModel.fromJson)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return RubricModel(
      id: parseText(json['id']) ?? '',
      name: parseText(json['name']) ?? '',
      description: parseText(json['description']),
      categoryId: parseText(json['category_id'] ?? json['categoryId']),
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
        criterionId: parseText(json['criterion_id'] ?? json['criterionId']) ?? '',
        checked: (json['checked'] ?? false) == true,
        criterionName: parseText(json['criterion_name'] ?? json['criterionName']),
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
    final project = asMap(json['project']);
    final rubricJson = json['rubric'];
    return RubricEvaluationModel(
      fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
      projectId: parseText(json['project_id'] ?? json['projectId']) ?? '',
      projectName: parseText(project['name']),
      projectStatus: parseText(project['status']),
      categoryName: parseText(asMap(project['category'])['name']),
      rubric: rubricJson is Map
          ? RubricModel.fromJson(asMap(rubricJson))
          : const RubricModel(id: '', name: '', criteria: []),
      submitted: (json['submitted'] ?? false) == true,
      submittedAt: parseDate(json['submitted_at'] ?? json['submittedAt']),
      checkedCount: (json['checked_count'] ?? json['checkedCount']) as int?,
      criteriaCount: (json['criteria_count'] ?? json['criteriaCount']) as int?,
      score: (json['score'] as num?)?.toDouble(),
      responses: asMapList(json['responses'])
          .map(RubricResponseModel.fromJson)
          .toList(),
    );
  }
}
