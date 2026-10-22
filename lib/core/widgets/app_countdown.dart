import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_motion.dart';

/// Panel de cuenta regresiva: título, cifras d·h·m·s que cambian cada segundo
/// y, opcionalmente, una barra de avance entre [start] y [target].
///
/// Si [target] ya pasó o es nulo muestra [doneMessage] en el mismo marco, así
/// nunca aparece un contador en negativo. El número entra deslizando, salvo
/// que el sistema pida reducir animaciones.
class AppCountdown extends StatefulWidget {
  const AppCountdown({
    super.key,
    required this.title,
    required this.target,
    required this.color,
    required this.icon,
    required this.doneMessage,
    this.start,
    this.spokenPrefix,
  });

  final String title;
  final DateTime? target;
  final DateTime? start;
  final Color color;
  final IconData icon;
  final String doneMessage;

  /// Inicio de la frase para lectores de pantalla («La jornada cierra en»).
  final String? spokenPrefix;

  @override
  State<AppCountdown> createState() => _AppCountdownState();
}

class _AppCountdownState extends State<AppCountdown> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.target != null) {
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
    final color = widget.color;
    final target = widget.target;
    final remaining = target?.difference(_now);
    if (target == null || remaining == null || remaining.isNegative) {
      return CountdownShell(
        color: color,
        icon: widget.icon,
        child: Text(widget.doneMessage,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600, color: color)),
      );
    }
    final start = widget.start;
    final progress = start != null && target.isAfter(start)
        ? (_now.difference(start).inSeconds / target.difference(start).inSeconds)
            .clamp(0.0, 1.0)
        : null;
    final spoken = '${widget.spokenPrefix ?? widget.title} '
        '${remaining.inDays} días, ${remaining.inHours % 24} horas y '
        '${remaining.inMinutes % 60} minutos';

    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: CountdownShell(
        color: color,
        icon: widget.icon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Wrap(children: [
              if (remaining.inDays > 0)
                _Digit(value: remaining.inDays, unit: 'd', color: color),
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
}

/// Marco tintado del contador (también sirve para un mensaje de estado).
class CountdownShell extends StatelessWidget {
  const CountdownShell({
    super.key,
    required this.color,
    required this.icon,
    required this.child,
  });

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

class _Digit extends StatelessWidget {
  const _Digit({required this.value, required this.unit, required this.color});

  final int value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      value.toString().padLeft(2, '0'),
      key: ValueKey(value),
      style: theme.textTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          AppMotion.reduced(context)
              ? text
              : AnimatedSwitcher(
                  duration: AppMotion.quick,
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween(
                            begin: const Offset(0, -0.35), end: Offset.zero)
                        .animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: text,
                ),
          const SizedBox(width: 2),
          Text(unit,
              style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
