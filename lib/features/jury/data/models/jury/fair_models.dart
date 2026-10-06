import 'common.dart';

/// `GET /fairs/my-assignments` → item de `data[]`.
class FairAssignmentModel {
  const FairAssignmentModel({
    required this.fairId,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.status,
    this.imageUrl,
    this.startsAt,
    this.endsAt,
    this.assignedAt,
    this.organizationName,
    this.siteName,
  });

  final String fairId;
  final String organizationId;
  final String name;
  final String description;
  final FairStatus status;
  final String? imageUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? assignedAt;
  final String? organizationName;
  final String? siteName;

  bool get isOpen => status == FairStatus.open;
  bool get isClosed => status == FairStatus.closed;

  factory FairAssignmentModel.fromJson(Map<String, dynamic> json) {
    // El backend envuelve la feria: { assigned_at, fair: {...} }.
    final fair = json['fair'] is Map ? asMap(json['fair']) : json;
    return FairAssignmentModel(
      fairId: parseText(fair['id']) ?? '',
      organizationId: parseText(fair['organization_id']) ?? '',
      name: parseText(fair['name']) ?? '',
      description: fair['description']?.toString() ?? '',
      status: parseFairStatus(parseText(fair['status'])),
      imageUrl: parseText(fair['image_url'] ?? fair['imageUrl']),
      startsAt: parseDate(fair['starts_at'] ?? fair['startsAt']),
      endsAt: parseDate(fair['ends_at'] ?? fair['endsAt']),
      assignedAt: parseDate(json['assigned_at'] ?? json['assignedAt']),
      organizationName:
          parseText(fair['organization_name'] ?? fair['organizationName']),
      siteName: parseText(fair['site_name'] ?? fair['siteName']),
    );
  }

  Map<String, dynamic> toJson() => {
        'assigned_at': assignedAt?.toIso8601String(),
        'fair': {
          'id': fairId,
          'organization_id': organizationId,
          'organization_name': organizationName,
          'site_name': siteName,
          'name': name,
          'description': description,
          'status': status.name.toUpperCase(),
          'image_url': imageUrl,
          'starts_at': startsAt?.toIso8601String(),
          'ends_at': endsAt?.toIso8601String(),
        },
      };
}

/// `GET /fairs/:fairId/projects` → item de `data[]`.
///
/// `mapApprovedProject` solo incluye proyectos APROBADOS de las categorías
/// asignadas al jurado: la app NO debe re-filtrar (regla 7).
class FairProjectModel {
  const FairProjectModel({
    required this.id,
    required this.fairId,
    required this.name,
    required this.description,
    required this.status,
    this.logoUrl,
    this.coverUrl,
    this.imageUrls = const [],
    this.videoUrl,
    this.categoryId,
    this.categoryName,
    this.standId,
    this.standCode,
  });

  final String id;
  final String fairId;
  final String name;
  final String description;
  final String status;
  final String? logoUrl;
  final String? coverUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? categoryId;
  final String? categoryName;
  final String? standId;
  final String? standCode;

  factory FairProjectModel.fromJson(Map<String, dynamic> json) {
    final category = asMap(json['category']);
    final stand = asMap(json['stand']);
    return FairProjectModel(
      id: parseText(json['id']) ?? '',
      fairId: parseText(json['fair_id'] ?? json['fairId']) ?? '',
      name: parseText(json['name']) ?? '',
      description: json['description']?.toString() ?? '',
      status: parseText(json['status']) ?? 'UNKNOWN',
      logoUrl: parseText(json['logo_url'] ?? json['logoUrl']),
      coverUrl: parseText(json['cover_url'] ?? json['coverUrl']),
      imageUrls: (json['image_urls'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      videoUrl: parseText(json['video_url'] ?? json['videoUrl']),
      categoryId: parseText(category['id'] ?? json['category_id']),
      categoryName: parseText(category['name']),
      standId: parseText(stand['id'] ?? json['stand_id']),
      standCode: parseText(stand['code']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fair_id': fairId,
        'name': name,
        'description': description,
        'status': status,
        'logo_url': logoUrl,
        'cover_url': coverUrl,
        'image_urls': imageUrls,
        'video_url': videoUrl,
        'category': {'id': categoryId, 'name': categoryName},
        'stand': {'id': standId, 'code': standCode},
      };
}

