import 'package:flutter/services.dart';

/// Vibración breve para confirmar acciones importantes (votar, enviar una
/// rúbrica o una evaluación). Android e iOS la omiten si el usuario la
/// desactivó en el sistema; nunca bloquea ni lanza.
abstract final class AppHaptics {
  /// La acción quedó registrada en el servidor.
  static void success() {
    HapticFeedback.mediumImpact().ignore();
  }

  /// Elegir una opción (una estrella, un proyecto).
  static void selection() {
    HapticFeedback.selectionClick().ignore();
  }
}
