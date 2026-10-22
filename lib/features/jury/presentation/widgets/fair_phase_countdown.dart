import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_countdown.dart';
import '../../data/models/jury_models.dart';
import 'fair_phase_badge.dart';

/// Reloj de la feria según su fase, con fechas reales del servidor:
///
/// * vista previa → cuenta regresiva hasta que se puede calificar;
/// * en vivo → cuánto falta para el cierre y una barra del día de feria;
/// * terminó / inscripción abierta → una línea de estado, sin reloj.
class FairPhaseCountdown extends StatelessWidget {
  const FairPhaseCountdown({super.key, required this.fair});

  final FairAssignmentModel fair;

  @override
  Widget build(BuildContext context) {
    final phase = fair.phase;
    final (_, icon, color) = FairPhaseBadge.describe(phase);
    final live = phase == JuryPhase.live;
    final target = switch (phase) {
      JuryPhase.preview => fair.reviewOpensAt ?? fair.startsAt,
      JuryPhase.live => fair.endsAt,
      _ => null,
    };
    return AppCountdown(
      key: ValueKey('${fair.fairId}-${phase.name}'),
      title: live ? 'Cierra en' : 'Podrás calificar en',
      spokenPrefix: live ? 'La feria cierra en' : 'Podrás calificar en',
      target: target,
      start: live ? fair.startsAt : null,
      color: color,
      icon: target == null
          ? icon
          : live
              ? PhosphorIconsRegular.timer
              : PhosphorIconsRegular.hourglass,
      doneMessage: switch (phase) {
        JuryPhase.ended =>
          'La feria terminó. Tus evaluaciones quedan registradas.',
        JuryPhase.beforePreview =>
          'Verás los proyectos de tu categoría cuando cierre la inscripción.',
        JuryPhase.preview => 'Ya puedes estudiar los proyectos de tu categoría.',
        JuryPhase.live => 'La feria está en curso: evalúa y deja tus reseñas.',
      },
    );
  }
}
