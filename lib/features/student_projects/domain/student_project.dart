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
    this.videoUrl,
    this.imageUrls = const [],
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
  final String? videoUrl;
  final List<String> imageUrls;

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

  /// Las reseñas y comentarios del jurado se ven en cuanto se envían: con la
  /// feria abierta y 7 días después del cierre. El conteo de votos llega
  /// solo cuando se publican los resultados (voto secreto).
  bool get hasFeedback => isApproved && (fair?.reviewsOpen ?? false);

  factory StudentProject.fromJson(Map<String, dynamic> json) {
    final fair = json['fair'];
    final members = json['members'];
    return StudentProject(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Proyecto'}',
      description: _text(json['description']),
      logoUrl: _text(json['logo_url']),
      coverUrl: _text(json['cover_url']),
      videoUrl: _text(json['video_url']),
      imageUrls: _urls(json['image_urls']),
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

  /// Compañeros: con la feria abierta se ven al instante. Al cerrar, 7 días más.
  bool get reviewsOpen {
    if (isOpen) return true;
    if (!isClosed) return false;
    final end = endsAt;
    if (end == null) return false;
    return DateTime.now().isBefore(end.add(const Duration(days: 7)));
  }

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

/// Calificación por estrellas y votos del jurado. Llegan juntos cuando los
/// resultados ya están publicados.
class ProjectFeedback {
  const ProjectFeedback({
    required this.published,
    required this.votes,
    required this.reviews,
    this.comments = const [],
  });

  const ProjectFeedback.hidden()
      : published = false,
        votes = null,
        reviews = const [],
        comments = const [];

  final bool published;

  /// Votos del jurado; null mientras los resultados no se publiquen.
  final int? votes;
  final List<ProjectReview> reviews;

  /// Comentarios del jurado (sin estrellas ni autor).
  final List<ProjectReview> comments;

  ProjectFeedback withComments(List<ProjectReview> value) => ProjectFeedback(
      published: published, votes: votes, reviews: reviews, comments: value);

  double? get average {
    if (reviews.isEmpty) return null;
    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  factory ProjectFeedback.fromJson(Map<String, dynamic> json) {
    final raw = json['reviews'];
    final votes = json['votes'];
    return ProjectFeedback(
      published: true,
      votes: votes is num ? votes.toInt() : null,
      reviews: raw is List
          ? raw
              .whereType<Map>()
              .map((row) => ProjectReview.fromJson(Map<String, dynamic>.from(row)))
              .where((review) => review.rating >= 1 && review.rating <= 5)
              .toList(growable: false)
          : const [],
    );
  }
}

class ProjectReview {
  const ProjectReview({required this.rating, this.comment, this.createdAt});

  /// `GET /engagement` → comentario del jurado, sin estrellas.
  static ProjectReview? juryComment(Map<String, dynamic> json) {
    final text = _text(json['comment']);
    if (text == null) return null;
    return ProjectReview(
      rating: 0,
      comment: text,
      createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal(),
    );
  }

  final int rating;
  final String? comment;
  final DateTime? createdAt;

  factory ProjectReview.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    return ProjectReview(
      rating: rating is num ? rating.toInt() : 0,
      comment: _text(json['comment']),
      createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal(),
    );
  }
}

String? _text(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

List<String> _urls(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
