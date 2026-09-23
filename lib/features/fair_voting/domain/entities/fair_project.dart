/// Estado del proyecto de feria (DRAFT / SUBMITTED / APPROVED / REJECTED).
enum FairProjectStatus { draft, submitted, approved, rejected, unknown }

FairProjectStatus parseFairProjectStatus(String? raw) {
  switch (raw?.toUpperCase()) {
    case 'DRAFT':
      return FairProjectStatus.draft;
    case 'SUBMITTED':
      return FairProjectStatus.submitted;
    case 'APPROVED':
      return FairProjectStatus.approved;
    case 'REJECTED':
      return FairProjectStatus.rejected;
  }
  return FairProjectStatus.unknown;
}

/// Proyecto de una feria.
class FairProject {
  final String id;
  final String fairId;
  final String? organizationId;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverUrl;
  final String? projectUrl;
  final FairProjectStatus status;
  final String? categoryId;
  final String? standId;
  final DateTime? reviewedAt;
  final DateTime? submittedAt;
  final List<FairProjectMember> members;
  final String? categoryName;
  final String? standCode;

  const FairProject({
    required this.id,
    required this.fairId,
    this.organizationId,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverUrl,
    this.projectUrl,
    required this.status,
    this.categoryId,
    this.standId,
    this.reviewedAt,
    this.submittedAt,
    this.members = const [],
    this.categoryName,
    this.standCode,
  });

  bool get isApproved => status == FairProjectStatus.approved;
}

/// Integrante de un proyecto.
class FairProjectMember {
  final String id;
  final String userId;
  final String fullName;
  final String role;
  final String? institutionalId;

  const FairProjectMember({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.role,
    this.institutionalId,
  });
}

class PaginatedFairProjects {
  final List<FairProject> items;
  final int total;
  final int page;
  final int totalPages;
  const PaginatedFairProjects({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}