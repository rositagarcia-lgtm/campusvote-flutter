/// Feria que el alumno puede explorar (abierta o ya cerrada).
class AudienceFair {
  final String id;
  final String name;
  final bool isOpen;
  final DateTime? startsAt;
  final String? imageUrl;
  final String? site;

  const AudienceFair({
    required this.id,
    required this.name,
    required this.isOpen,
    this.startsAt,
    this.imageUrl,
    this.site,
  });

  factory AudienceFair.fromJson(Map<String, dynamic> json) => AudienceFair(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        isOpen: json['can_rate'] == true || json['status'] == 'OPEN',
        startsAt: DateTime.tryParse('${json['starts_at'] ?? ''}')?.toLocal(),
        imageUrl: _nullable(json['image_url']),
        site: _nullable(json['site']),
      );
}

/// Proyecto de la feria visto por un alumno del público.
class AudienceProject {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? logoUrl;
  final String? category;
  final String? stand;
  final bool isMine;
  final int? myScore;
  final String? myComment;
  final int votes;

  /// `null` mientras no alcanza el mínimo de votos (anonimato).
  final double? average;

  const AudienceProject({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.logoUrl,
    this.category,
    this.stand,
    this.isMine = false,
    this.myScore,
    this.myComment,
    this.votes = 0,
    this.average,
  });

  factory AudienceProject.fromJson(Map<String, dynamic> json) =>
      AudienceProject(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        description: _nullable(json['description']),
        coverUrl: _nullable(json['cover_url']),
        logoUrl: _nullable(json['logo_url']),
        category: _nullable(json['category']),
        stand: _nullable(json['stand']),
        isMine: json['is_mine'] == true,
        myScore:
            json['my_score'] is num ? (json['my_score'] as num).toInt() : null,
        myComment: _nullable(json['my_comment']),
        votes: json['votes'] is num ? (json['votes'] as num).toInt() : 0,
        average:
            json['average'] is num ? (json['average'] as num).toDouble() : null,
      );
}

class AudienceBoard {
  final AudienceFair fair;
  final List<AudienceProject> projects;
  final String? favoriteProjectId;
  final int minVotes;

  const AudienceBoard({
    required this.fair,
    required this.projects,
    this.favoriteProjectId,
    this.minVotes = 3,
  });

  AudienceProject? get favorite =>
      projects.where((p) => p.id == favoriteProjectId).firstOrNull;

  factory AudienceBoard.fromJson(Map<String, dynamic> json) => AudienceBoard(
        fair: AudienceFair.fromJson(_map(json['fair'])),
        favoriteProjectId: _nullable(json['favorite_project_id']),
        minVotes:
            json['min_votes'] is num ? (json['min_votes'] as num).toInt() : 3,
        projects: [
          for (final p
              in json['projects'] is List ? json['projects'] as List : const [])
            if (p is Map)
              AudienceProject.fromJson(Map<String, dynamic>.from(p)),
        ],
      );
}

/// Lo que opinaron los compañeros del proyecto propio (anónimo).
class PeerFeedback {
  final int votes;
  final int minVotes;
  final double? average;
  final List<String> comments;
  final List<PeerReview> reviews;
  final bool available;

  const PeerFeedback({
    required this.votes,
    this.minVotes = 3,
    this.average,
    this.comments = const [],
    this.reviews = const [],
    this.available = true,
  });

  factory PeerFeedback.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'];
    final reviews = rawReviews is List
        ? [
            for (final row in rawReviews)
              if (row is Map) PeerReview.fromJson(Map<String, dynamic>.from(row)),
          ]
        : const <PeerReview>[];
    final comments = [
      for (final c in json['comments'] is List ? json['comments'] as List : const [])
        if ('$c'.trim().isNotEmpty) '$c'.trim(),
    ];
    return PeerFeedback(
      votes: json['votes'] is num ? (json['votes'] as num).toInt() : 0,
      minVotes: json['min_votes'] is num ? (json['min_votes'] as num).toInt() : 3,
      average: json['average'] is num ? (json['average'] as num).toDouble() : null,
      comments: comments,
      reviews: reviews.isNotEmpty
          ? reviews
          : [
              for (final comment in comments) PeerReview(score: null, comment: comment),
            ],
      available: json['available'] is bool ? json['available'] as bool : true,
    );
  }
}

class PeerReview {
  const PeerReview({required this.score, this.comment});

  final int? score;
  final String? comment;

  factory PeerReview.fromJson(Map<String, dynamic> json) {
    final score = json['score'];
    final comment = '${json['comment'] ?? ''}'.trim();
    return PeerReview(
      score: score is num ? score.toInt() : null,
      comment: comment.isEmpty ? null : comment,
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String? _nullable(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
