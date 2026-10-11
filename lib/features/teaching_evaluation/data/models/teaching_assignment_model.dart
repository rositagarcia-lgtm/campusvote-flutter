import '../../domain/entities/teacher_evaluation_form.dart';
import '../../domain/entities/teaching_assignment.dart';

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String _text(Object? value) => (value ?? '').toString();

/// Fecha de calendario (sin hora): `2026-10-15T00:00:00.000Z` es el día 15
/// en cualquier zona horaria, no el 14 a las 19:00 en Lima.
DateTime? _calendarDate(Object? value) {
  final raw = value?.toString() ?? '';
  if (raw.length < 10) return null;
  final parsed = DateTime.tryParse(raw.substring(0, 10));
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

/// Asignación docente tal como la devuelve `GET /my-teaching-assignments`
/// (Prisma camelCase con `course`, `teacher` y `academicPeriod` anidados; las
/// fechas del periodo son las de la jornada de evaluación).
class TeachingAssignmentModel {
  const TeachingAssignmentModel._(this.entity);

  final TeachingAssignment entity;

  factory TeachingAssignmentModel.fromJson(Map<String, dynamic> json) {
    final course = _map(json['course']);
    final teacher = _map(json['teacher']);
    final period = _map(json['academicPeriod']);
    final cycleValue = json['cycle'] ?? course['cycle'];
    return TeachingAssignmentModel._(TeachingAssignment(
      id: _text(json['id']),
      courseId: _text(json['courseId'] ?? course['id']),
      teacherId: _text(json['teacherId'] ?? teacher['id']),
      courseCode: _text(course['code']),
      courseName: _text(course['name']),
      cycle: cycleValue is num ? cycleValue.toInt() : 0,
      teacherFirstName: _text(teacher['firstName']),
      teacherLastName: _text(teacher['lastName']),
      evaluated: json['evaluated'] == true,
      // Activa y abierta solo si el backend lo confirma.
      isActive: json['isActive'] == true,
      siteId: _text(course['siteId']),
      careerId: _text(json['careerId'] ?? course['careerId']),
      evaluationOpen: json['evaluationOpen'] == true,
      opensAt: _calendarDate(period['startDate']),
      closesAt: _calendarDate(period['endDate']),
    ));
  }

  TeachingAssignment toEntity() => entity;
}

/// Criterio de `GET /evaluation-criteria`.
EvaluationCriterion criterionFromJson(Map<String, dynamic> json) {
  final description = _text(json['description']).trim();
  final careerId = _text(json['careerId']).trim();
  return EvaluationCriterion(
    id: _text(json['id']),
    name: _text(json['name']),
    description: description.isEmpty ? null : description,
    careerId: careerId.isEmpty ? null : careerId,
  );
}

/// Evaluación de `GET /evaluation-responses/:id` (detalles con `criterionId`).
EvaluationDraft draftFromJson(Map<String, dynamic> json) {
  final scores = <String, int>{};
  final details = json['details'];
  if (details is List) {
    for (final item in details.whereType<Map>()) {
      final criterionId = _text(item['criterionId']);
      final score = item['score'];
      if (criterionId.isNotEmpty && score is num) {
        scores[criterionId] = score.toInt();
      }
    }
  }
  final comment = json['comment']?.toString();
  return EvaluationDraft(
    id: _text(json['id']),
    submitted: _text(json['status']).toUpperCase() == 'SUBMITTED',
    scores: scores,
    comment: comment,
  );
}
