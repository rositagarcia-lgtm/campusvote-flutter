import 'dart:async';

import 'package:campusvote_flutter/app/splash_intro_video.dart';
import 'package:campusvote_flutter/core/routing/app_router.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/totp.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/presentation/pages/account_page.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
// El contrato del plugin ya llega como dependencia transitiva de video_player.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _FakeVideoPlatform extends VideoPlayerPlatform {
  final events = StreamController<VideoEvent>.broadcast(sync: true);
  String? asset;
  int playCalls = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    asset = options.dataSource.asset;
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> play(int playerId) async {
    playCalls++;
  }

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black);

  void initialized(Duration duration) => events.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: duration,
        size: const Size(360, 640),
      ));

  void completed() =>
      events.add(VideoEvent(eventType: VideoEventType.completed));
}

class _SessionRepository implements AuthRepository {
  @override
  Future<bool> hasSession() async => true;

  @override
  Future<AuthUser?> currentUser() async => const AuthUser(
        id: 'test',
        email: 'test@example.com',
        role: AuthRole.admin,
      );

  // Al abrir, la app refresca perfil y estado 2FA; aquí el servidor no
  // responde y la app debe seguir con la sesión guardada.
  @override
  Future<Result<AuthUser>> getProfile() async =>
      const FailureResult(NetworkFailure(message: 'sin red en el test'));

  @override
  Future<Result<TotpStatus>> getTwoFactorStatus() async =>
      const FailureResult(NetworkFailure(message: 'sin red en el test'));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('El test solo restaura la sesión');
}

class _RouterHarness extends ConsumerStatefulWidget {
  const _RouterHarness();

  @override
  ConsumerState<_RouterHarness> createState() => _RouterHarnessState();
}

class _RouterHarnessState extends ConsumerState<_RouterHarness> {
  late final GoRouterRefreshNotifier _notifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _notifier = GoRouterRefreshNotifier(ref);
    _router = buildAppRouter(ref, refreshListenable: _notifier);
  }

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);

  @override
  void dispose() {
    _router.dispose();
    _notifier.dispose();
    super.dispose();
  }
}

void main() {
  testWidgets('si initialize no responde, el intro continúa sin quedar colgado',
      (tester) async {
    final previous = VideoPlayerPlatform.instance;
    final video = _FakeVideoPlatform();
    VideoPlayerPlatform.instance = video;
    addTearDown(() async {
      VideoPlayerPlatform.instance = previous;
      await video.events.close();
    });

    var navigations = 0;
    await tester.pumpWidget(MaterialApp(
      home: SplashIntroVideo(onFinished: () => navigations++),
    ));
    await tester.pump();
    expect(navigations, 0);

    await tester.pump(const Duration(seconds: 13));
    await tester.pump();
    expect(navigations, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('duración cero no navega antes de que el usuario omita',
      (tester) async {
    final previous = VideoPlayerPlatform.instance;
    final video = _FakeVideoPlatform();
    VideoPlayerPlatform.instance = video;
    addTearDown(() async {
      VideoPlayerPlatform.instance = previous;
      await video.events.close();
    });

    var navigations = 0;
    await tester.pumpWidget(MaterialApp(
      home: SplashIntroVideo(onFinished: () => navigations++),
    ));
    await tester.pump();
    video.initialized(Duration.zero);
    await tester.pump();
    await tester.pump();

    expect(video.playCalls, 1);
    expect(navigations, 0);
    video.completed();
    await tester.pump();
    expect(navigations, 0);

    await tester.tap(find.text('Omitir introducción'));
    await tester.pump();
    expect(navigations, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('sesión restaurada espera el video antes de abrir la cuenta',
      (tester) async {
    final previous = VideoPlayerPlatform.instance;
    final video = _FakeVideoPlatform();
    VideoPlayerPlatform.instance = video;
    addTearDown(() async {
      VideoPlayerPlatform.instance = previous;
      await video.events.close();
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_SessionRepository()),
      ],
      child: const _RouterHarness(),
    ));
    await tester.pumpAndSettle();

    expect(video.asset, 'assets/video-campusvote.mp4');
    expect(find.byType(SplashIntroVideo), findsOneWidget);
    expect(find.byType(AccountPage), findsNothing);

    video.initialized(const Duration(seconds: 4));
    await tester.pump();
    await tester.pump();
    expect(video.playCalls, 1);
    expect(find.byType(SplashIntroVideo), findsOneWidget);

    video.completed();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(AccountPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
