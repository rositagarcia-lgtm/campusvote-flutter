/// Modelos del panel de jurado.
///
/// Contrato real del backend (`src/modules/juryAssignments`,
/// `fairEvaluations`, `fairVoting`, `fairResults`): snake_case → camelCase.
/// `fromJson`/`toJson` manuales, sin freezed.
library;

DateTime? parseDate(dynamic v) =>
    (v is String && v.isNotEmpty) ? DateTime.tryParse(v)?.toLocal() : null;

String? parseText(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

Map<String, dynamic> asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> asMapList(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

/// Estado de la feria (DRAFT / OPEN / CLOSED).
enum FairStatus { draft, open, closed, unknown }

FairStatus parseFairStatus(String? raw) => switch (raw?.toUpperCase()) {
      'DRAFT' => FairStatus.draft,
      'OPEN' => FairStatus.open,
      'CLOSED' => FairStatus.closed,
      _ => FairStatus.unknown,
    };
