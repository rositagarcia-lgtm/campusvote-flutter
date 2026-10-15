// Avance de la evaluación docente visto por el propio docente: por curso,
// cuántos alumnos convocados hay y cuántos ya lo evaluaron. Solo conteos.

class CourseProgress {
  const CourseProgress({
    required this.courseName,
    this.courseCode,
    this.cycle,
    required this.eligible,
    required this.evaluated,
  });

  final String courseName;
  final String? courseCode;
  final int? cycle;
  final int eligible;
  final int evaluated;

  double get ratio => eligible == 0 ? 0 : evaluated / eligible;

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
        courseName: '${json['course_name'] ?? 'Curso'}',
        courseCode: json['course_code']?.toString(),
        cycle: (json['cycle'] as num?)?.toInt(),
        eligible: (json['eligible_students'] as num?)?.toInt() ?? 0,
        evaluated: (json['evaluated_students'] as num?)?.toInt() ?? 0,
      );
}

enum JornadaState { upcoming, open, closed }

class ScheduleProgress {
  const ScheduleProgress({
    required this.periodName,
    required this.state,
    this.startDate,
    this.endDate,
    this.daysLeft,
    required this.courses,
  });

  final String periodName;
  final JornadaState state;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? daysLeft;
  final List<CourseProgress> courses;

  int get eligible => courses.fold(0, (sum, c) => sum + c.eligible);
  int get evaluated => courses.fold(0, (sum, c) => sum + c.evaluated);

  factory ScheduleProgress.fromJson(Map<String, dynamic> json) {
    final period = json['academic_period'];
    return ScheduleProgress(
      periodName: period is Map ? '${period['name'] ?? ''}' : '',
      state: switch (json['state']) {
        'OPEN' => JornadaState.open,
        'CLOSED' => JornadaState.closed,
        _ => JornadaState.upcoming,
      },
      startDate: DateTime.tryParse('${json['start_date'] ?? ''}'),
      endDate: DateTime.tryParse('${json['end_date'] ?? ''}'),
      daysLeft: (json['days_left'] as num?)?.toInt(),
      courses: [
        for (final c in json['courses'] is List ? json['courses'] as List : const [])
          if (c is Map) CourseProgress.fromJson(Map<String, dynamic>.from(c)),
      ],
    );
  }
}
