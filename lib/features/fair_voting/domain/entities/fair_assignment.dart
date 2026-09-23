/// Estados del fair (DRAFT/OPEN/CLOSED).
enum FairAssignmentStatus { draft, open, closed, unknown }

FairAssignmentStatus parseFairAssignmentStatus(String? raw) {
  switch (raw?.toUpperCase()) {
    case 'DRAFT':
      return FairAssignmentStatus.draft;
    case 'OPEN':
      return FairAssignmentStatus.open;
    case 'CLOSED':
      return FairAssignmentStatus.closed;
  }
  return FairAssignmentStatus.unknown;
}

/// Feria vista desde la perspectiva del jurado asignado.
/// Proviene de `GET /api/fairs/my-assignments` (rol=JURY).
class FairAssignment {
  final String fairId;
  final String organizationId;
  final String name;
  final String description;
  final FairAssignmentStatus status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? assignedAt;

  const FairAssignment({
    required this.fairId,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.status,
    this.startsAt,
    this.endsAt,
    this.assignedAt,
  });

  bool get isOpen => status == FairAssignmentStatus.open;
  bool get isClosed => status == FairAssignmentStatus.closed;
}

class PaginatedFairAssignments {
  final List<FairAssignment> items;
  final int total;
  final int page;
  final int totalPages;
  const PaginatedFairAssignments({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}