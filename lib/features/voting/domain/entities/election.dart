/// Entidad Election del dominio.
///
/// Estado del backend: `DRAFT | SCHEDULED | OPEN | CLOSED | CERTIFIED | PUBLISHED`.
class Election {
  final String id;
  final String title;
  final String description;
  final String processType;
  final String scopeType;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final String organizationId;
  final String? organizationName;
  final String? organizationLogo;
  final String? periodId;
  final String? facultyId;
  final String? programId;
  final bool isAnonymousAllowed;

  const Election({
    required this.id,
    required this.title,
    required this.description,
    required this.processType,
    required this.scopeType,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.organizationId,
    this.organizationName,
    this.organizationLogo,
    this.periodId,
    this.facultyId,
    this.programId,
    this.isAnonymousAllowed = false,
  });

  bool get isOpen => status == 'OPEN';
  bool get isClosed => status == 'CLOSED' ||
      status == 'CERTIFIED' ||
      status == 'PUBLISHED';
  bool get isUpcoming => status == 'SCHEDULED' || status == 'DRAFT';

  Election copyWith({
    String? title,
    String? description,
    String? status,
    String? organizationName,
    String? organizationLogo,
  }) {
    return Election(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      processType: processType,
      scopeType: scopeType,
      status: status ?? this.status,
      startAt: startAt,
      endAt: endAt,
      organizationId: organizationId,
      organizationName: organizationName ?? this.organizationName,
      organizationLogo: organizationLogo ?? this.organizationLogo,
      periodId: periodId,
      facultyId: facultyId,
      programId: programId,
      isAnonymousAllowed: isAnonymousAllowed,
    );
  }
}