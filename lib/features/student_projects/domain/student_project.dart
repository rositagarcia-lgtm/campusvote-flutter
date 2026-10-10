/// Proyecto de feria del alumno (`GET /api/projects/mine`).
///
/// El servidor solo devuelve proyectos donde el alumno es integrante; la app
/// no filtra nada, solo presenta.
class StudentProject {
  const StudentProject({
    required this.id,
    required this.name,
    required this.status,
    required this.members,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.reviewNotes,
    this.myRole,
    this.fair,
    this.category,
    this.stand,
  });

  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;

  /// DRAFT · DRAFT_PENDING_STUDENT_CONFIRMATION · SUBMITTED · APPROVED · REJECTED
  final String status;
  final String? reviewNotes;

  /// EXPOSITOR · COLLABORATOR · OWNER
  final String? myRole;
  final StudentProjectFair? fair;
  final String? category;
  final String? stand;
  final List<ProjectMate> members;

  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  /// Solo un proyecto aprobado en una feria abierta o cerrada recibe likes y
  /// comentarios del jurado.
  bool get hasFeedback =>
      isApproved && (fair?.isOpen == true || fair?.isClosed == true);

  factory StudentProject.fromJson(Map<String, dynamic> json) {
    final fair = json['fair'];
    final members = json['members'];
    return StudentProject(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Proyecto'}',
      description: _text(json['description']),
      logoUrl: _text(json['logo_url']),
      coverUrl: _text(json['cover_url']),
      status: '${json['status'] ?? 'DRAFT'}',
      reviewNotes: _text(json['review_notes']),
      myRole: _text(json['my_role']),
      fair: fair is Map
          ? StudentProjectFair.fromJson(Map<String, dynamic>.from(fair))
          : null,
      category: _text(json['category']),
      stand: _text(json['stand']),
      members: members is List
          ? members
              .whereType<Map>()
              .map((m) => ProjectMate.fromJson(Map<String, dynamic>.from(m)))
              .toList(growable: false)
          : const [],
    );
  }
}

class StudentProjectFair {
  const StudentProjectFair({
    required this.id,
    required this.name,
    required this.status,
    this.imageUrl,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String name;

  /// DRAFT · OPEN · CLOSED
  final String status;
  final String? imageUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isOpen => status == 'OPEN';
  bool get isClosed => status == 'CLOSED';

  factory StudentProjectFair.fromJson(Map<String, dynamic> json) =>
      StudentProjectFair(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? 'Feria'}',
        status: '${json['status'] ?? 'DRAFT'}',
        imageUrl: _text(json['image_url']),
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal(),
        endsAt: DateTime.tryParse('${json['ends_at']}')?.toLocal(),
      );
}

class ProjectMate {
  const ProjectMate(
      {required this.name, required this.role, this.isMe = false});

  final String name;
  final String role;
  final bool isMe;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory ProjectMate.fromJson(Map<String, dynamic> json) => ProjectMate(
        name: _text(json['name']) ?? 'Integrante',
        role: '${json['role'] ?? ''}',
        isMe: json['is_me'] == true,
      );
}

/// Me gusta y comentarios del jurado (anónimos) sobre un proyecto.
class ProjectFeedback {
  const ProjectFeedback({required this.likes, required this.comments});

  final int likes;
  final List<ProjectComment> comments;

  factory ProjectFeedback.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'];
    return ProjectFeedback(
      likes:
          json['likes_count'] is num ? (json['likes_count'] as num).toInt() : 0,
      comments: raw is List
          ? raw
              .whereType<Map>()
              .map((c) => ProjectComment(
                    text: _text(c['comment']) ?? '',
                    createdAt:
                        DateTime.tryParse('${c['created_at']}')?.toLocal(),
                  ))
              .where((c) => c.text.isNotEmpty)
              .toList(growable: false)
          : const [],
    );
  }
}

class ProjectComment {
  const ProjectComment({required this.text, this.createdAt});

  final String text;
  final DateTime? createdAt;
}

String? _text(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}
