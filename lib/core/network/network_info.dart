import 'dart:io';

/// Detecta si hay conectividad (best-effort).
class NetworkInfo {
  const NetworkInfo();

  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('campusvote-rg13.onrender.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.any((s) => s.address.isNotEmpty);
    } catch (_) {
      return false;
    }
  }
}