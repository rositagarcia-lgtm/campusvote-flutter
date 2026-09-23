import '../../../../core/errors/result.dart';
import '../../../../core/network/api_response.dart';

/// Helpers compartidos para mapear envelopes de respuesta.
class VotingApiMapper {
  const VotingApiMapper._();

  static ApiResponse<T> wrap<T>(dynamic raw, T Function(dynamic) builder) {
    if (raw is! Map) return ApiResponse<T>(success: false);
    return ApiResponse<T>.fromJson(
      Map<String, dynamic>.from(raw),
      (d) => builder(d),
    );
  }

  static Failure toFailure(String? message) =>
      UnknownFailure(message: message ?? 'Error desconocido');
}