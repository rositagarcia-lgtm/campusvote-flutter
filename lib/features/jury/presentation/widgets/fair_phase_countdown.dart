import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../data/models/jury_models.dart';
import 'fair_phase_badge.dart';

/// Reloj de la feria según su fase, con fechas reales del servidor:
///
/// * vista previa → cuenta regresiva hasta que se puede calificar;
/// * en vivo → cuánto falta para el cierre y una barra del día de feria;
/// * terminó / inscripción abierta → una línea de estado, sin reloj.
///
/// Late cada segundo solo mientras hay cuenta regresiva.
class FairPhaseCountdown extends StatefulWidget {
  const FairPhaseCountdown({super.key, required this.fair});

  final FairAssignmentModel fair;

  @override
  State<FairPhaseCountdown> createState() => _FairPhaseCountdownState();
}

class _FairPhaseCountdownState extends State<FairPhaseCountdown> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  DateTime? get _target => switch (widget.fair.phase) {
        JuryPhase.preview => widget.fair.reviewOpensAt ?? widget.fair.startsAt,
        JuryPhase.live => widget.fair.endsAt,
        _ => null,
      };

  @override
  void initState() {
    super.initState();
    if (_target != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = widget.fair.phase;
    final (_, icon, color) = FairPhaseBadge.describe(phase);
    final target = _target;
    final remaining = target?.difference(_now);

    if (target == null || remaining == null || remaining.isNegative) {
      final message = switch (phase) {
        JuryPhase.ended => 'La feria terminó. Tus evaluaciones quedan registradas.',
        JuryPhase.beforePreview =>
          'Verás los proyectos de tu categoría cuando cierre la inscripción.',
        JuryPhase.preview => 'Ya puedes estudiar los proyectos de tu categoría.',
        JuryPhase.live => 'La feria está en curso: evalúa y deja tus reseñas.',
      };
      return _Shell(color: color, icon: icon, child: Text(message,
          style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600, color: color)));
    }

    final live = phase == JuryPhase.live;
    final start = widget.fair.startsAt;
    final progress = live && start != null && target.isAfter(start)
        ? (_now.difference(start).inSeconds / target.difference(start).inSeconds)
            .clamp(0.0, 1.0)
        : null;

    return Semantics(
      liveRegion: false,
      label: live
          ? 'La feria cierra en ${_spoken(remaining)}'
          : 'Podrás calificar en ${_spoken(remaining)}',
      excludeSemantics: true,
      child: _Shell(
        color: color,
        icon: live ? PhosphorIconsRegular.timer : PhosphorIconsRegular.hourglass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(live ? 'Cierra en' : 'Podrás calificar en',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              if (remaining.inDays > 0) _Digit(value: remaining.inDays, unit: 'd', color: color),
              _Digit(value: remaining.inHours % 24, unit: 'h', color: color),
              _Digit(value: remaining.inMinutes % 60, unit: 'm', color: color),
              _Digit(value: remaining.inSeconds % 60, unit: 's', color: color),
            ]),
            if (progress != null) ...[
              const SizedBox(height: AppSpacing.s),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _spoken(Duration d) =>
      '${d.inDays} días, ${d.inHours % 24} horas y ${d.inMinutes % 60} minutos';
}

class _Shell extends StatelessWidget {
  const _Shell({required this.color, required this.icon, required this.child});

  final Color color;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadii.rMedium,
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconMedium, color: color),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Cifra con unidad; el número entra deslizando al cambiar.
class _Digit extends StatelessWidget {
  const _Digit({required this.value, required this.unit, required this.color});

  final int value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    final text = Text(value.toString().padLeft(2, '0'), key: ValueKey(value), style: style);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          AppMotion.reduced(context)
              ? text
              : AnimatedSwitcher(
                  duration: AppMotion.quick,
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween(begin: const Offset(0, -0.35), end: Offset.zero)
                        .animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: text,
                ),
          const SizedBox(width: 2),
          Text(unit, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
