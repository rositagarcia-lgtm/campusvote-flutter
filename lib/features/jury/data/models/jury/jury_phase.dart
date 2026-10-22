import 'common.dart';

/// Momento de la feria para el jurado (`phase` del backend):
///
/// * [beforePreview]: la inscripción sigue abierta; aún no hay proyectos.
/// * [preview]: cerró la inscripción; ve los proyectos de su categoría para
///   estudiarlos, sin calificar.
/// * [live]: día de la feria; evalúa, vota y reseña.
/// * [ended]: terminó; solo lectura.
enum JuryPhase { beforePreview, preview, live, ended }

JuryPhase? parseJuryPhase(String? raw) => switch (raw) {
      'BEFORE_PREVIEW' => JuryPhase.beforePreview,
      'PREVIEW' => JuryPhase.preview,
      'LIVE' => JuryPhase.live,
      'ENDED' => JuryPhase.ended,
      _ => null,
    };

String juryPhaseCode(JuryPhase phase) => switch (phase) {
      JuryPhase.beforePreview => 'BEFORE_PREVIEW',
      JuryPhase.preview => 'PREVIEW',
      JuryPhase.live => 'LIVE',
      JuryPhase.ended => 'ENDED',
    };

/// Fase cuando el servidor aún no la envía (versiones anteriores): se deduce
/// del estado, como hacía la app antes.
JuryPhase fallbackJuryPhase(FairStatus status, DateTime? endsAt) {
  switch (status) {
    case FairStatus.open:
      final ended = endsAt != null && DateTime.now().isAfter(endsAt);
      return ended ? JuryPhase.ended : JuryPhase.live;
    case FairStatus.closed:
      return JuryPhase.ended;
    case FairStatus.draft:
    case FairStatus.unknown:
      return JuryPhase.beforePreview;
  }
}
