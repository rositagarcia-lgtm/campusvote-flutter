import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'fade_slide.dart';

/// Lenguaje de movimiento de la app.
///
/// Todo movimiento comunica algo (llegada, cambio de valor, respuesta al
/// toque) y dura poco. Si el sistema pide reducir animaciones, cada widget de
/// este archivo muestra directamente su estado final.
abstract final class AppMotion {
  static const quick = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 700);

  /// Separación entre elementos de una cascada de entrada.
  static const stagger = Duration(milliseconds: 70);

  static const emphasized = Curves.easeOutCubic;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Entrada en cascada para el elemento [index] de una lista o pantalla.
  ///
  /// Se limita a los primeros ocho para que una lista larga no haga esperar
  /// al usuario: el resto entra con el último retardo.
  static Widget reveal(int index, Widget child) => FadeSlide(
        delay: stagger * index.clamp(0, 8),
        duration: const Duration(milliseconds: 520),
        offset: 16,
        child: child,
      );
}

/// Número que cuenta desde 0 hasta [value] al aparecer o al cambiar.
///
/// Hace legible un cambio de estado (p. ej. "3 pendientes" → "2") sin
/// necesidad de un aviso aparte.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
  });

  final int value;
  final String suffix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) {
      return Text('$value$suffix', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      builder: (_, v, __) => Text('${v.round()}$suffix', style: style),
    );
  }
}

/// Respuesta táctil: la tarjeta se hunde un 2 % mientras se presiona.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down && !AppMotion.reduced(context) ? 0.98 : 1,
        duration: AppMotion.quick,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Sacudida horizontal breve al aparecer: señala un error sin depender solo
/// del color. Cambia la `key` (p. ej. con el mensaje) para repetirla.
class Shake extends StatelessWidget {
  const Shake({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 480),
      builder: (_, t, child) {
        // Tres oscilaciones que se amortiguan.
        final dx = 8 * (1 - t) * math.sin(t * math.pi * 6);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: child,
    );
  }
}

/// Confirmación: el círculo se dibuja y luego el check, con un leve rebote.
class SuccessMark extends StatelessWidget {
  const SuccessMark({super.key, this.size = 88, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    final reduce = AppMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (_, t, __) {
        final scale = 0.85 + 0.15 * Curves.elasticOut.transform(
              (t * 1.4 - 0.4).clamp(0.0, 1.0),
            );
        return Transform.scale(
          scale: scale,
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(painter: _SuccessPainter(t, c)),
          ),
        );
      },
    );
  }
}

class _SuccessPainter extends CustomPainter {
  _SuccessPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final ring = (t / 0.55).clamp(0.0, 1.0);
    final tick = ((t - 0.45) / 0.45).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      r,
      Paint()..color = color.withValues(alpha: 0.12 * ring),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 4),
      -math.pi / 2,
      2 * math.pi * Curves.easeOutCubic.transform(ring),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    if (tick == 0) return;
    final a = Offset(size.width * 0.30, size.height * 0.52);
    final b = Offset(size.width * 0.45, size.height * 0.66);
    final c = Offset(size.width * 0.72, size.height * 0.38);
    final path = Path()..moveTo(a.dx, a.dy);
    final eased = Curves.easeOut.transform(tick);
    if (eased < 0.4) {
      final p = Offset.lerp(a, b, eased / 0.4)!;
      path.lineTo(p.dx, p.dy);
    } else {
      path.lineTo(b.dx, b.dy);
      final p = Offset.lerp(b, c, (eased - 0.4) / 0.6)!;
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SuccessPainter old) => old.t != t || old.color != color;
}
