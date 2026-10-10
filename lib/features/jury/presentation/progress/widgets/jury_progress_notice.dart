import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/app_notice.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../jury_flow.dart';

/// Aviso de una frase sobre la situación actual del jurado.
///
/// Cada concepto conserva su propio estado: el texto no fusiona rúbrica, voto y
/// declaración en un único porcentaje.
class JuryProgressNotice extends StatelessWidget {
  const JuryProgressNotice({super.key, required this.flow});

  final JuryFlow flow;

  @override
  Widget build(BuildContext context) {
    if (flow.participationComplete) {
      return const NoticeBanner(
        tone: AppTone.success,
        icon: PhosphorIconsFill.sealCheck,
        message: 'Completaste la evaluación, el voto oficial y tu declaración.',
      );
    }
    final hint = flow.hint;
    if (hint == null) {
      return const NoticeBanner(
        tone: AppTone.neutral,
        icon: PhosphorIconsRegular.lockSimple,
        message:
            'La feria está cerrada: no admite nuevas participaciones por tu '
            'cuenta.',
      );
    }
    return NoticeBanner(
      tone: AppTone.info,
      icon: PhosphorIconsRegular.hourglassMedium,
      message: hint,
    );
  }
}
