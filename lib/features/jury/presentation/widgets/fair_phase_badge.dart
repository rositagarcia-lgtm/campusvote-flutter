import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../data/models/jury_models.dart';

/// Etiqueta de la fase de la feria para el jurado.
///
/// Sobre la portada usa vidrio esmerilado (blur + blanco translúcido) para
/// leerse sobre cualquier foto; fuera de ella, el tinte del tono. En vivo
/// lleva un punto que late (quieto si el sistema pide reducir animaciones).
class FairPhaseBadge extends StatelessWidget {
  const FairPhaseBadge({super.key, required this.phase, this.onImage = false});

  final JuryPhase phase;
  final bool onImage;

  static (String, IconData, Color) describe(JuryPhase phase) => switch (phase) {
        JuryPhase.live => ('En vivo', PhosphorIconsFill.radioButton, const Color(0xFF16A34A)),
        JuryPhase.preview => ('Vista previa', PhosphorIconsRegular.eye, const Color(0xFFD97706)),
        JuryPhase.ended => ('Terminó', PhosphorIconsRegular.flagCheckered, const Color(0xFF64748B)),
        JuryPhase.beforePreview => ('Inscripción abierta', PhosphorIconsRegular.hourglass, const Color(0xFF0284C7)),
      };

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = describe(phase);
    final theme = Theme.of(context);
    final fg = onImage ? Colors.white : color;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (phase == JuryPhase.live)
          _PulseDot(color: onImage ? const Color(0xFF4ADE80) : color)
        else
          Icon(icon, size: 14, color: fg),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: content,
    );
    return Semantics(
      label: 'Fase de la feria: $label',
      excludeSemantics: true,
      child: onImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: padded,
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: padded,
            ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});

  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 6 + 8 * t,
                height: 6 + 8 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ],
          );
        },
      ),
    );
  }
}
