/// Wrapper ligero sobre Map para inspeccionar el envelope estándar.
///
/// El backend entrega:
/// `{ success: true, message, data, meta? }`
/// o
/// `{ success: false, error: { code, message, details, timestamp } }`
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;
  final ApiErrorPayload? error;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) dataBuilder,
  ) {
    final isSuccess = json['success'] == true;
    return ApiResponse<T>(
      success: isSuccess,
      message: json['message'] as String?,
      data: isSuccess && json['data'] != null
          ? dataBuilder(json['data'])
          : null,
      meta: json['meta'] is Map
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
      error: !isSuccess && json['error'] is Map
          ? ApiErrorPayload.fromJson(Map<String, dynamic>.from(json['error'] as Map))
          : null,
    );
  }
}

class ApiErrorPayload {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final String? timestamp;

  const ApiErrorPayload({
    required this.code,
    required this.message,
    this.details,
    this.timestamp,
  });

  factory ApiErrorPayload.fromJson(Map<String, dynamic> json) {
    return ApiErrorPayload(
      code: (json['code'] ?? 'UNKNOWN').toString(),
      message: (json['message'] ?? 'Error').toString(),
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'] as Map)
          : null,
      timestamp: json['timestamp'] as String?,
    );
  }
}

class ApiPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const ApiPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ApiPagination.fromJson(Map<String, dynamic> json) {
    return ApiPagination(
      page: (json['page'] ?? 1) as int,
      limit: (json['limit'] ?? 10) as int,
      total: (json['total'] ?? 0) as int,
      totalPages: (json['totalPages'] ?? 0) as int,
      hasNext: (json['hasNext'] ?? false) as bool,
      hasPrev: (json['hasPrev'] ?? false) as bool,
    );
  }
}