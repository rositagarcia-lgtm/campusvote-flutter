import 'package:crypto/crypto.dart';

/// Hash helper para el payload del voto.
///
/// El backend espera un `payloadHash` (string). Usamos SHA-256 determinista
/// sobre la representación canónica del payload JSON.
class PayloadHasher {
  const PayloadHasher._();

  static String hash(Map<String, dynamic> payload) {
    final canonical = _canonicalize(payload);
    return sha256.convert(canonical.codeUnits).toString();
  }

  static String _canonicalize(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${value.replaceAll('"', '\\"')}"';
    if (value is List) {
      return '[${value.map(_canonicalize).join(',')}]';
    }
    if (value is Map) {
      final keys = value.keys.map((e) => e.toString()).toList()..sort();
      final entries =
          keys.map((k) => '"$k":${_canonicalize(value[k])}').join(',');
      return '{$entries}';
    }
    return '"$value"';
  }
}
