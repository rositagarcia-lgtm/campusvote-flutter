import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/config/app_env.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../features/settings/presentation/settings_copy.dart';

/// Un valor inicializado con duración cero todavía no representa el fin.
bool hasIntroPlaybackCompleted(VideoPlayerValue value,
        {required bool started}) =>
    started &&
    value.isInitialized &&
    value.duration > Duration.zero &&
    value.isCompleted;

/// Introducción que precede a la bienvenida. Sale de Cloudflare cuando
/// [AppEnv.introVideoUrl] está definida; si no, del archivo de la app.
class SplashIntroVideo extends StatefulWidget {
  const SplashIntroVideo({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashIntroVideo> createState() => _SplashIntroVideoState();
}

class _SplashIntroVideoState extends State<SplashIntroVideo> {
  VideoPlayerController? _controller;

  VideoPlayerController get _player => _controller!;

  bool get _runningWidgetTests =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');
  bool _isReady = false;
  bool _hasFailed = false;
  bool _playbackStarted = false;
  bool _finished = false;
  bool _errorLogged = false;
  Timer? _playbackWatchdog;

  void _log(String message) => debugPrint(
        '[SplashIntro ${DateTime.now().toIso8601String()}] $message',
      );

  @override
  void initState() {
    super.initState();
    final compiled = AppEnv.introVideoUrl.trim();
    if (compiled.isNotEmpty || _runningWidgetTests) {
      _open(compiled.isEmpty ? null : compiled);
      return;
    }
    unawaited(_openFromServer());
  }

  Future<void> _openFromServer() async {
    String? url;
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ));
      final response = await dio.get<Map<String, dynamic>>('/api/public/intro-video');
      final data = response.data?['data'];
      final raw = data is Map ? data['url']?.toString().trim() ?? '' : '';
      if (raw.startsWith('https://')) url = raw;
    } catch (error) {
      _log('intro.remote.error=$error');
    }
    if (!mounted || _finished) return;
    _open(url);
  }

  void _open(String? remote) {
    final source = (remote == null || remote.isEmpty) ? null : remote;
    _controller = source == null
        ? VideoPlayerController.asset('assets/video-campusvote.mp4')
        : VideoPlayerController.networkUrl(Uri.parse(source))
      ..addListener(_handlePlayback);
    _log('initialize.begin source=${source ?? 'assets/video-campusvote.mp4'} '
        'isInitialized=${_player.value.isInitialized}');
    if (mounted) setState(() {});
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await _player.initialize().timeout(const Duration(seconds: 12));
      if (!mounted || _finished) return;
      final value = _player.value;
      _log('initialize.done isInitialized=${value.isInitialized} '
          'duration=${value.duration} aspectRatio=${value.aspectRatio} '
          'error=${value.errorDescription}');
      if (!value.isInitialized || value.hasError) {
        throw StateError('VideoPlayerController no quedó inicializado');
      }
      setState(() => _isReady = true);
      // Renderizar la textura antes de dar la orden de reproducción evita
      // perder los primeros fotogramas durante el arranque en Android.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || _finished) return;
      _log('play.request');
      await _player.play();
      if (!mounted || _finished) return;
      _playbackStarted = true;
      _log('play.ack isPlaying=${_player.value.isPlaying} '
          'position=${_player.value.position}');
      _playbackWatchdog = Timer(const Duration(seconds: 8), () {
        if (mounted &&
            !_finished &&
            _player.value.position == Duration.zero) {
          _fail(StateError('La reproducción no avanzó tras iniciar play()'),
              StackTrace.current);
        }
      });
      _handlePlayback();
    } catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  void _handlePlayback() {
    if (!mounted || _finished) return;
    final value = _player.value;
    if (value.hasError) {
      if (!_errorLogged) {
        _errorLogged = true;
        _log('controller.error ${value.errorDescription}');
      }
      if (_isReady) {
        _fail(StateError(value.errorDescription ?? 'Error de video'),
            StackTrace.current);
      }
      return;
    }
    if (value.position > Duration.zero) {
      _playbackWatchdog?.cancel();
      _playbackWatchdog = null;
    }
    if (hasIntroPlaybackCompleted(value, started: _playbackStarted)) {
      _finish('playback.completed');
    }
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (!mounted || _finished) return;
    _log(
        'fallback.error=$error controllerError=${_player.value.errorDescription}');
    debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
    setState(() => _hasFailed = true);
    _finish('playback.failed');
  }

  void _finish(String reason) {
    if (!mounted || _finished) return;
    _finished = true;
    _playbackWatchdog?.cancel();
    _log('navigation.trigger reason=$reason '
        'position=${_player.value.position} '
        'duration=${_player.value.duration}');
    widget.onFinished();
  }

  @override
  void dispose() {
    _playbackWatchdog?.cancel();
    _controller
      ?..removeListener(_handlePlayback)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFailed) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isReady)
            IntroVideoFrame(
              aspectRatio: _player.value.aspectRatio,
              child: VideoPlayer(_player),
            )
          else
            Semantics(
              label: SettingsCopy.of(context)
                  .t('Cargando introducción de CampusVote'),
              liveRegion: true,
              child: const SizedBox.expand(),
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
          Positioned.fill(
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.l,
                    bottom: AppSpacing.l,
                  ),
                  child: TextButton(
                    onPressed: () => _finish('user.skip'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.34),
                    ),
                    child:
                        Text(SettingsCopy.of(context).t('Omitir introducción')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Llena el viewport sin deformar el video, centrando cualquier recorte.
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
        final viewportRatio = constraints.maxHeight > 0
            ? constraints.maxWidth / constraints.maxHeight
            : ratio;
        final mismatch =
            (ratio - viewportRatio).abs() / math.max(ratio, viewportRatio);
        final adjustment = (mismatch / 0.25).clamp(0.0, 1.0).toDouble();
        final safeScale = 1.0 - 0.08 * adjustment;

        return ColoredBox(
          color: AppColors.darkBackground,
          child: ClipRect(
            child: Transform.scale(
              scale: safeScale,
              alignment: Alignment.center,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: constraints.maxHeight * ratio,
                    height: constraints.maxHeight,
                    child: AspectRatio(aspectRatio: ratio, child: child),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
