import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_logo.dart';
import '../features/settings/presentation/settings_copy.dart';

/// Introducción audiovisual local que precede a la bienvenida.
class SplashIntroVideo extends StatefulWidget {
  const SplashIntroVideo({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashIntroVideo> createState() => _SplashIntroVideoState();
}

class _SplashIntroVideoState extends State<SplashIntroVideo> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video-campusvote.mp4')
      ..addListener(_handlePlayback);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _isReady = true);
      await _controller.play();
    } on Object {
      if (mounted) {
        setState(() => _hasFailed = true);
        widget.onFinished();
      }
    }
  }

  void _handlePlayback() {
    if (!_controller.value.isInitialized ||
        _controller.value.isPlaying ||
        _controller.value.position < _controller.value.duration) {
      return;
    }
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handlePlayback)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFailed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isReady)
              IntroVideoFrame(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              Center(
                child: Semantics(
                  label: SettingsCopy.of(context)
                      .t('Cargando introducción de CampusVote'),
                  liveRegion: true,
                  child: AppLogo.asset(size: AppDimensions.brandLogoLarge),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.48),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.l,
              bottom: AppSpacing.l,
              child: TextButton(
                onPressed: widget.onFinished,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black.withValues(alpha: 0.34),
                ),
                child: Text(SettingsCopy.of(context).t('Omitir introducción')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centra el contenido sin recortar el video y limita sus dimensiones al
/// espacio seguro del dispositivo, manteniendo su proporción original.
class IntroVideoFrame extends StatelessWidget {
  const IntroVideoFrame(
      {super.key, required this.aspectRatio, required this.child});

  final double aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio =
            aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1.0;
        final maxWidth = math.min(constraints.maxWidth * 0.88, 520.0);
        // Deja sitio para el botón inferior incluso en teléfonos bajos.
        final maxHeight = math.min(
          math.min(constraints.maxHeight * 0.75, 680.0),
          math.max(0.0,
              constraints.maxHeight - 2 * (AppSpacing.xxxl + AppSpacing.l)),
        );
        final width = math.min(maxWidth, maxHeight * ratio);

        return Center(
          child: SizedBox(
            width: width,
            height: width / ratio,
            child: AspectRatio(aspectRatio: ratio, child: child),
          ),
        );
      },
    );
  }
}
