import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/app_notice.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../data/models/jury_models.dart';

/// Resumen de una feria terminada, con los números que confirmó el servidor.
///
/// Si la categoría del jurado no tuvo proyectos aprobados, lo dice tal cual:
/// no había nada que evaluar ni votar, y no es un pendiente suyo.
class JuryEndedRecap extends StatelessWidget {
  const JuryEndedRecap({super.key, required this.progress});

  final JuryProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final total = progress.totalProjects;
    if (total == 0) {
      return const NoticeBanner(
        tone: AppTone.neutral,
        icon: PhosphorIconsRegular.info,
        message:
            'La feria terminó. Fuiste jurado, pero tu categoría no tuvo '
            'proyectos aprobados: no había nada que evaluar ni votar. Tu '
            'asignación queda registrada.',
      );
    }
    final done = progress.completedProjects;
    final evaluated = done == total
        ? 'Evaluaste los $total proyectos de tu categoría'
        : 'Evaluaste $done de $total proyectos de tu categoría';
    final vote = progress.hasVoted
        ? ' y registraste tu voto oficial.'
        : ' y no registraste voto oficial.';
    final complete = done == total && progress.hasVoted;
    return NoticeBanner(
      tone: complete ? AppTone.success : AppTone.neutral,
      icon: complete ? PhosphorIconsFill.sealCheck : PhosphorIconsRegular.flagCheckered,
      message: 'La feria terminó. $evaluated$vote',
    );
  }
}
