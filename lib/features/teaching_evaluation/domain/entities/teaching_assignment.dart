/// Asignación docente que el ESTUDIANTE evalúa en el periodo activo.
///
/// El backend ya decide cuáles le tocan: las de su carrera y ciclo o, si es
/// irregular, las de los cursos que la sede le matriculó.
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

  /// Sede y carrera del curso: definen qué rúbrica aplica.
  final String siteId;
  final String careerId;

  /// Si hoy está dentro de la jornada de evaluación publicada.
  final bool evaluationOpen;
  final DateTime? opensAt;
  final DateTime? closesAt;

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
    this.siteId = '',
    this.careerId = '',
    this.evaluationOpen = true,
    this.opensAt,
    this.closesAt,
  });

  String get teacherFullName => '$teacherFirstName $teacherLastName';

  /// Se puede evaluar ahora: activa, en jornada y sin enviar.
  bool get canEvaluate => isActive && evaluationOpen && !evaluated;

  /// La jornada todavía no empieza.
  bool get opensLater {
    final opens = opensAt;
    if (opens == null || evaluationOpen) return false;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).isBefore(opens);
  }

  TeachingAssignment copyWith({bool? evaluated}) => TeachingAssignment(
        id: id,
        courseId: courseId,
        teacherId: teacherId,
        courseCode: courseCode,
        courseName: courseName,
        cycle: cycle,
        teacherFirstName: teacherFirstName,
        teacherLastName: teacherLastName,
        evaluated: evaluated ?? this.evaluated,
        isActive: isActive,
        siteId: siteId,
        careerId: careerId,
        evaluationOpen: evaluationOpen,
        opensAt: opensAt,
        closesAt: closesAt,
      );
}
