part of '../project_visuals.dart';

/// Botón central, carga y barra de tiempo del reproductor.
class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.loading,
    required this.onToggle,
  });

  /// Nulo mientras el video no se cargó (solo se muestra «Reproducir»).
  final VideoPlayerController? controller;
  final bool loading;
  final VoidCallback onToggle;

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
