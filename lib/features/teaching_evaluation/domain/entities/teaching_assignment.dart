/// Asignación docente visible para un ESTUDIANTE en su carrera/ciclo/periodo.
class TeachingAssignment {
  final String id;
  final String courseId;
  final String teacherId;
  final String courseCode;
  final String courseName;
  final int cycle;
  final String teacherFirstName;
  final String teacherLastName;
  final bool evaluated;
  final bool isActive;

  const TeachingAssignment({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.courseCode,
    required this.courseName,
    required this.cycle,
    required this.teacherFirstName,
    required this.teacherLastName,
    required this.evaluated,
    required this.isActive,
  });

  String get teacherFullName => '$teacherFirstName $teacherLastName';
}

/// Confirmación del backend al registrar una evaluación docente.
class TeacherEvaluationResult {
  final String id;
  final int score;
  final DateTime? submittedAt;

  const TeacherEvaluationResult({
    required this.id,
    required this.score,
    this.submittedAt,
  });
}