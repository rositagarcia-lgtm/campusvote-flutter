import 'package:flutter/material.dart';

/// Entrada escalonada: opacidad 0→1 y desplazamiento vertical →0.
///
/// Se usa en las pantallas de acceso (splash, correo, OTP) para que los
/// bloques aparezcan en cascada en lugar de saltar de golpe.
class FadeSlide extends StatefulWidget {
  const FadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 20.0,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;

  /// Espera antes de iniciar la animación de este bloque.
  final Duration delay;

  /// Desplazamiento vertical inicial en píxeles lógicos.
  final double offset;

  final Duration duration;

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _animate = true;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _animate ? 1 : 0),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * widget.offset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
