part of '../project_visuals.dart';

/// Video del proyecto (pitch o video adicional), servido desde su URL pública.
///
/// Se carga recién al tocar «Reproducir»: no gasta datos de quien solo mira
/// la ficha, y un video lento no bloquea la pantalla. El controlador avisa
/// cada cambio (reproduciendo, cargando, posición, error) para que los
/// controles nunca queden congelados.
class ProjectVideo extends StatefulWidget {
  const ProjectVideo({
    super.key,
    required this.url,
    this.borderRadius = AppRadii.rMedium,
    this.posterUrl,
  });

  final String url;
  final BorderRadius borderRadius;

  /// Imagen de fondo antes de reproducir (la portada del proyecto).
  final String? posterUrl;

  @override
  State<ProjectVideo> createState() => _ProjectVideoState();
}

class _ProjectVideoState extends State<ProjectVideo> {
  VideoPlayerController? _controller;
  bool _starting = false;
  bool _failed = false;

  void _onChange() {
    final value = _controller?.value;
    if (!mounted || value == null) return;
    if (value.hasError) {
      _failed = true;
    }
    setState(() {});
  }

  Future<void> _start() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null || !uri.hasScheme) {
      setState(() => _failed = true);
      return;
    }
    setState(() {
      _starting = true;
      _failed = false;
    });
    final controller = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _controller?.removeListener(_onChange);
      _controller?.dispose();
      _controller = controller..addListener(_onChange);
      await controller.play();
    } catch (_) {
      controller.dispose();
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null) {
      _start();
      return;
    }
    final value = controller.value;
    if (value.isPlaying) {
      controller.pause();
    } else {
      // Al terminar, vuelve a empezar desde el inicio.
      if (value.duration > Duration.zero && value.position >= value.duration) {
        controller.seekTo(Duration.zero);
      }
      controller.play();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    final ratio = ready && controller.value.aspectRatio > 0
        ? controller.value.aspectRatio
        : 16 / 9;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: ratio,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (ready)
                GestureDetector(onTap: _toggle, child: VideoPlayer(controller))
              else
                _VideoPoster(url: widget.posterUrl),
              if (_failed)
                _VideoMessage(
                  message: text.t('No pudimos reproducir el video del proyecto.'),
                  actionLabel: text.t('Reintentar'),
                  onAction: _start,
                )
              else
                _VideoControls(
                  controller: ready ? controller : null,
                  loading: _starting ||
                      (ready && controller.value.isBuffering && !controller.value.isPlaying),
                  onToggle: _toggle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _videoTime(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
