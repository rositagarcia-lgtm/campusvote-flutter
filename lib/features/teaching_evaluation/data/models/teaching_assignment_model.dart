import '../../domain/entities/teaching_assignment.dart';

/// Parse de una asignación docente tal como la devuelve el backend
/// (Prisma camelCase + `course` y `teacher` anidados + flag `evaluated`).
class TeachingAssignmentModel {
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

  const TeachingAssignmentModel({
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

  factory TeachingAssignmentModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'] is Map
        ? Map<String, dynamic>.from(json['course'] as Map)
        : <String, dynamic>{};
    final teacher = json['teacher'] is Map
        ? Map<String, dynamic>.from(json['teacher'] as Map)
        : <String, dynamic>{};

    final cycleValue = json['cycle'] ?? course['cycle'];
    return TeachingAssignmentModel(
      id: (json['id'] ?? '').toString(),
      courseId: (json['courseId'] ?? course['id'] ?? '').toString(),
      teacherId: (json['teacherId'] ?? teacher['id'] ?? '').toString(),
      courseCode: (course['code'] ?? '').toString(),
      courseName: (course['name'] ?? '').toString(),
      cycle: cycleValue is num ? cycleValue.toInt() : 0,
      teacherFirstName: (teacher['firstName'] ?? '').toString(),
      teacherLastName: (teacher['lastName'] ?? '').toString(),
      evaluated: json['evaluated'] == true,
      // Una asignación solo se considera activa si el backend lo confirma.
      isActive: json['isActive'] == true,
    );
  }

  TeachingAssignment toEntity() => TeachingAssignment(
        id: id,
        courseId: courseId,
        teacherId: teacherId,
        courseCode: courseCode,
        courseName: courseName,
        cycle: cycle,
        teacherFirstName: teacherFirstName,
        teacherLastName: teacherLastName,
        evaluated: evaluated,
        isActive: isActive,
      );
}
