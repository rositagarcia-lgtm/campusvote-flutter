/// Estado de los resultados de la evaluación docente.
enum TeacherResultsStatus {
  /// Hay resultados con el mínimo de respuestas.
  available,

  /// Menos respuestas que el mínimo: se ocultan para proteger el anonimato.
  insufficient,

  /// La jornada sigue abierta: no se muestran resultados parciales.
  locked,
}

class CourseResult {
  final String courseName;
  final String courseCode;
  final int? cycle;
  final String? periodName;
  final double average;
  final int responses;

  const CourseResult({
    required this.courseName,
    required this.courseCode,
    required this.average,
    required this.responses,
    this.cycle,
    this.periodName,
  });
}

class CriterionResult {
  final String name;
  final String? description;
  final double average;

  const CriterionResult({
    required this.name,
    required this.average,
    this.description,
  });
}

class PeriodResult {
  final String periodName;
  final double average;
  final int responses;

  const PeriodResult({
    required this.periodName,
    required this.average,
    required this.responses,
  });
}

/// Lo que el docente ve de su evaluación. Todo es agregado y anónimo: nunca
/// se sabe qué alumno respondió qué.
class TeacherResults {
  final TeacherResultsStatus status;
  final int totalResponses;
  final int minimumRequired;
  final double overallAverage;
  final double? overallRating;
  final List<CourseResult> byCourse;
  final List<CriterionResult> byCriterion;

  /// Cantidad de puntajes por estrella (5 a 1).
  final Map<int, int> distribution;
  final List<String> comments;
  final List<PeriodResult> evolution;

  const TeacherResults({
    required this.status,
    this.totalResponses = 0,
    this.minimumRequired = 3,
    this.overallAverage = 0,
    this.overallRating,
    this.byCourse = const [],
    this.byCriterion = const [],
    this.distribution = const {},
    this.comments = const [],
    this.evolution = const [],
  });

  /// Criterios ordenados de mayor a menor (el backend ya los ordena así).
  CriterionResult? get strongest =>
      byCriterion.length >= 2 ? byCriterion.first : null;
  CriterionResult? get weakest =>
      byCriterion.length >= 2 ? byCriterion.last : null;
}
