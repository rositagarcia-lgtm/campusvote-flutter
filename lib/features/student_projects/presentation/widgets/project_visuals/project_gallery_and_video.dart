part of '../project_visuals.dart';

class ProjectGallery extends StatelessWidget {
  const ProjectGallery({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final resolved = [
      for (final url in urls)
        if (AppEnv.mediaUrl(url) case final src?) src,
    ];
    if (resolved.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resolved.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: AppRadii.rMedium,
          child: Image.network(
            resolved[index],
            width: 196,
            height: 148,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 196,
              height: 148,
              child: ColoredBox(color: Color(0x11000000)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Video del proyecto, servido desde su URL pública.
class ProjectVideo extends StatefulWidget {
  const ProjectVideo({
    super.key,
    required this.url,
    this.borderRadius = AppRadii.rMedium,
  });

  final String url;
  final BorderRadius borderRadius;

  @override
  State<ProjectVideo> createState() => _ProjectVideoState();
}

class _ProjectVideoState extends State<ProjectVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri == null || !uri.hasScheme) {
      _failed = true;
      return;
    }
    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    controller.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final controller = _controller;
    if (_failed || controller == null) {
      return Text(
        text.t('No pudimos reproducir el video del proyecto.'),
        style: theme.textTheme.bodyMedium,
      );
    }
    if (!controller.value.isInitialized) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final playing = controller.value.isPlaying;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x00000000),
                        Color(0x99000000),
                      ],
                      stops: [0, 0.48, 1],
                    ),
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: text.t(playing ? 'Pausar video' : 'Reproducir video'),
              style: IconButton.styleFrom(
                fixedSize: const Size(64, 64),
                backgroundColor: Colors.white.withValues(alpha: 0.94),
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: () => setState(() {
                playing ? controller.pause() : controller.play();
              }),
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 32,
              ),
            ),
            Positioned(
              left: AppSpacing.m,
              right: AppSpacing.m,
              bottom: AppSpacing.s,
              child: Row(
                children: [
                  Text(
                    _videoTime(controller.value.position),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
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
                  Text(
                    _videoTime(controller.value.duration),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
