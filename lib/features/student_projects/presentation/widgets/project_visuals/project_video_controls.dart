part of '../project_visuals.dart';

/// Botón central, carga y barra de tiempo del reproductor.
class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.loading,
    required this.onToggle,
    required this.expanded,
    required this.onResize,
  });

  /// Nulo mientras el video no se cargó (solo se muestra «Reproducir»).
  final VideoPlayerController? controller;
  final bool loading;
  final VoidCallback onToggle;
  final bool expanded;
  final VoidCallback onResize;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final value = controller?.value;
    final playing = value?.isPlaying ?? false;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Con el video corriendo, el botón se oculta para no taparlo; tocar
        // la imagen pausa.
        IgnorePointer(
          ignoring: playing && !loading,
          child: AnimatedOpacity(
            opacity: playing && !loading ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : IconButton.filledTonal(
                      tooltip: text.t(playing ? 'Pausar video' : 'Reproducir video'),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(64, 64),
                        backgroundColor: Colors.white.withValues(alpha: 0.94),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      onPressed: onToggle,
                      icon: Icon(
                        playing ? PhosphorIconsFill.pause : PhosphorIconsFill.play,
                        size: 32,
                      ),
                    ),
            ),
          ),
        ),
        if (controller case final ready? when value != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.l, AppSpacing.m, AppSpacing.xs),
                child: Row(
                  children: [
                    _TimeLabel(_videoTime(value.position)),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: VideoProgressIndicator(
                        ready,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: theme.colorScheme.primaryContainer,
                          bufferedColor: Colors.white54,
                          backgroundColor: Colors.white30,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _TimeLabel(_videoTime(value.duration)),
                    IconButton(
                      tooltip: text.t(expanded ? 'Achicar video' : 'Agrandar video'),
                      onPressed: onResize,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                      ),
                      icon: CustomPaint(
                        size: const Size.square(18),
                        painter: _CornersPainter(inward: expanded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
      );
}

/// Portada antes de reproducir; sin imagen, un fondo neutro.
class _VideoPoster extends StatelessWidget {
  const _VideoPoster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final src = AppEnv.mediaUrl(url);
    const fallback = ColoredBox(color: Color(0xFF0F172A));
    if (src == null) return fallback;
    return Image.network(
      src,
      fit: BoxFit.cover,
      color: Colors.black.withValues(alpha: 0.35),
      colorBlendMode: BlendMode.darken,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

/// Mensaje sobre el video (error) con una acción para reintentar.
class _VideoMessage extends StatelessWidget {
  const _VideoMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.s),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuatro esquinas, el mismo control de agrandar del reproductor.
class _CornersPainter extends CustomPainter {
  const _CornersPainter({required this.inward});

  final bool inward;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final arm = side * 0.34;
    final weight = side * 0.1;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = weight
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    final inset = weight;
    final reach = inward ? side * 0.28 : 0.0;
    const corners = <(double, double, double, double)>[
      (1.0, 1.0, 1.0, 1.0),
      (-1.0, 1.0, -1.0, 1.0),
      (1.0, -1.0, 1.0, -1.0),
      (-1.0, -1.0, -1.0, -1.0),
    ];
    for (final (sx, sy, dx, dy) in corners) {
      final x = sx > 0 ? inset : side - inset;
      final y = sy > 0 ? inset : side - inset;
      final originX = x + dx * reach;
      final originY = y + dy * reach;
      final dirX = inward ? -dx : dx;
      final dirY = inward ? -dy : dy;
      final path = Path()
        ..moveTo(originX + dirX * arm, originY)
        ..lineTo(originX, originY)
        ..lineTo(originX, originY + dirY * arm);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornersPainter oldDelegate) => oldDelegate.inward != inward;
}
