import 'common.dart';

num _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

class RubricCriterionModel {
  const RubricCriterionModel({
    required this.id,
    required this.name,
    required this.position,
    this.points = 0,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int position;
  final double points;
  final String? description;
  final bool isActive;

  factory RubricCriterionModel.fromJson(Map<String, dynamic> json) =>
      RubricCriterionModel(
        id: parseText(json['id']) ?? '',
        name: parseText(json['name']) ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
        points: _toNum(json['points']).toDouble(),
        description: parseText(json['description']),
        isActive: (json['is_active'] ?? json['isActive'] ?? true) == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'position': position,
        'points': points,
        'is_active': isActive,
      };
}

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
  final List<RubricCriterionModel> criteria;

  factory RubricModel.fromJson(Map<String, dynamic> json) {
    final criteriaList = asMapList(json['criteria'])
        .map(RubricCriterionModel.fromJson)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return RubricModel(
      id: parseText(json['id']) ?? '',
      name: parseText(json['name']) ?? '',
      description: parseText(json['description']),
      categoryId: parseText(json['category_id'] ?? json['categoryId']),
      criteria: criteriaList,
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
        criterionId:
            parseText(json['criterion_id'] ?? json['criterionId']) ?? '',
        checked: (json['checked'] ?? false) == true,
        criterionName:
            parseText(json['criterion_name'] ?? json['criterionName']),
        criterionPosition:
            ((json['criterion_position'] ?? json['criterionPosition']) as num?)
                ?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'criterion_id': criterionId,
        'checked': checked,
      };
}

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
      checkedCount:
          ((json['checked_count'] ?? json['checkedCount']) as num?)?.toInt(),
      criteriaCount:
          ((json['criteria_count'] ?? json['criteriaCount']) as num?)?.toInt(),
      score: json['score'] == null ? null : _toNum(json['score']).toDouble(),
      responses: asMapList(json['responses'])
          .map(RubricResponseModel.fromJson)
          .toList(),
    );
  }
}