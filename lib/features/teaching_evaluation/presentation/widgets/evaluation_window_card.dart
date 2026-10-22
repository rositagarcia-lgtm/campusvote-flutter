import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_countdown.dart';
import '../../domain/entities/teaching_assignment.dart';

/// Cuándo puede evaluar el alumno, con las fechas que publicó su sede:
///
/// * jornada abierta con pendientes → cuánto falta para que cierre;
/// * jornada por venir → cuenta regresiva hasta el primer día;
/// * todo evaluado → confirmación;
/// * sin fecha publicada → lo dice, sin inventar una.
///
/// Las fechas son días de calendario: abre al empezar el día y cierra al
/// terminar el último día.
class EvaluationWindowCard extends StatelessWidget {
  const EvaluationWindowCard({
    super.key,
    required this.pending,
    required this.completed,
  });

  /// Asignaciones sin evaluar (abiertas o fuera de jornada).
  final List<TeachingAssignment> pending;
  final List<TeachingAssignment> completed;

  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFD97706);
  static const _slate = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final open = pending.where((a) => a.canEvaluate).toList();
    if (open.isNotEmpty) {
      final closes = open
          .map((a) => a.closesAt)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (min, d) => min == null || d.isBefore(min) ? d : min);
      final opens = open.map((a) => a.opensAt).whereType<DateTime>().firstOrNull;
      return AppCountdown(
        title: 'La jornada cierra en',
        target: closes?.add(const Duration(days: 1)),
        start: opens,
        color: _green,
        icon: PhosphorIconsRegular.timer,
        doneMessage: open.length == 1
            ? 'La jornada está abierta: tienes 1 docente por evaluar.'
            : 'La jornada está abierta: tienes ${open.length} docentes por evaluar.',
      );
    }
    final next = pending
        .where((a) => a.opensLater)
        .map((a) => a.opensAt!)
        .fold<DateTime?>(null, (min, d) => min == null || d.isBefore(min) ? d : min);
    if (next != null) {
      return AppCountdown(
        title: 'Tu próxima jornada empieza en',
        target: next,
        color: _amber,
        icon: PhosphorIconsRegular.hourglass,
        doneMessage: 'Tu jornada de evaluación ya empezó: desliza para actualizar.',
      );
    }
    if (pending.isEmpty && completed.isNotEmpty) {
      return const CountdownShell(
        color: _green,
        icon: PhosphorIconsFill.sealCheck,
        child: Text('Evaluaste a todos tus docentes de este periodo. ¡Gracias!',
            style: TextStyle(color: _green, fontWeight: FontWeight.w600)),
      );
    }
    return const CountdownShell(
      color: _slate,
      icon: PhosphorIconsRegular.calendarBlank,
      child: Text(
        'Tu sede aún no publica la próxima jornada de evaluación. '
        'Cuando la publique, verás aquí su fecha y la cuenta regresiva.',
        style: TextStyle(color: _slate, fontWeight: FontWeight.w600),
      ),
    );
  }
}
