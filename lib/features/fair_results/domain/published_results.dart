// Resultados publicados de una feria, tal como los ve la comunidad
// (alumnos, docentes y jurados): podio por categoría sin votos.

class PublishedFair {
  const PublishedFair({
    required this.id,
    required this.name,
    this.imageUrl,
    this.publishedAt,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final DateTime? publishedAt;

  factory PublishedFair.fromJson(Map<String, dynamic> json) => PublishedFair(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? 'Feria'}',
        imageUrl: _text(json['image_url']),
        publishedAt: DateTime.tryParse('${json['published_at'] ?? ''}'),
      );
}

class PodiumEntry {
  const PodiumEntry({
    required this.position,
    required this.projectId,
    required this.projectName,
    this.coverUrl,
    this.stand,
    this.isMine = false,
  });

  final int position;
  final String projectId;
  final String projectName;
  final String? coverUrl;
  final String? stand;
  final bool isMine;

  factory PodiumEntry.fromJson(Map<String, dynamic> json) => PodiumEntry(
        position: (json['position'] as num?)?.toInt() ?? 0,
        projectId: '${json['project_id'] ?? ''}',
        projectName: '${json['project_name'] ?? ''}',
        coverUrl: _text(json['cover_url']),
        stand: _text(json['stand']),
        isMine: json['is_mine'] == true,
      );
}

class CategoryPodium {
  const CategoryPodium({required this.name, required this.podium});

  final String name;
  final List<PodiumEntry> podium;

  PodiumEntry? get winner =>
      podium.where((p) => p.position == 1).firstOrNull;

  factory CategoryPodium.fromJson(Map<String, dynamic> json) => CategoryPodium(
        name: '${json['category_name'] ?? 'Sin categoría'}',
        podium: [
          for (final p in _list(json['podium'])) PodiumEntry.fromJson(p),
        ]..sort((a, b) => a.position.compareTo(b.position)),
      );
}

class MyProjectResult {
  const MyProjectResult({
    required this.projectName,
    required this.categoryName,
    this.position,
  });

  final String projectName;
  final String categoryName;

  /// Puesto en su categoría; null si no recibió votos del jurado.
  final int? position;

  bool get winner => position == 1;

  factory MyProjectResult.fromJson(Map<String, dynamic> json) =>
      MyProjectResult(
        projectName: '${json['project_name'] ?? ''}',
        categoryName: '${json['category_name'] ?? ''}',
        position: (json['position'] as num?)?.toInt(),
      );
}

class PublishedResults {
  const PublishedResults({
    required this.fair,
    required this.categories,
    this.audienceFavorite,
    this.myProjects = const [],
  });

  final PublishedFair fair;
  final List<CategoryPodium> categories;
  final String? audienceFavorite;
  final List<MyProjectResult> myProjects;

  factory PublishedResults.fromJson(Map<String, dynamic> json) {
    final fair = json['fair'] is Map
        ? Map<String, dynamic>.from(json['fair'] as Map)
        : <String, dynamic>{};
    final favorite = json['audience_favorite'];
    return PublishedResults(
      fair: PublishedFair.fromJson(
          {...fair, 'published_at': json['published_at']}),
      categories: [
        for (final c in _list(json['categories'])) CategoryPodium.fromJson(c),
      ],
      audienceFavorite:
          favorite is Map ? _text(favorite['project_name']) : null,
      myProjects: [
        for (final p in _list(json['my_projects'])) MyProjectResult.fromJson(p),
      ],
    );
  }
}

List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
    : const [];

String? _text(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
