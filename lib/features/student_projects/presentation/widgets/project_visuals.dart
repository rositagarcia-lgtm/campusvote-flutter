import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../../domain/student_project.dart';

/// Etapas del recorrido de un proyecto, de la inscripción al cierre de feria.
enum ProjectStage { registered, review, approved, live, finished }

extension StudentProjectStage on StudentProject {
  ProjectStage get stage {
    if (status == 'SUBMITTED' || isRejected) return ProjectStage.review;
    if (!isApproved) return ProjectStage.registered;
    if (fair?.isClosed == true) return ProjectStage.finished;
    if (fair?.isOpen == true) return ProjectStage.live;
    return ProjectStage.approved;
  }

  /// Texto y tono del estado, siempre acompañados de ícono (no solo color).
  (String, AppTone, IconData) get statusBadge => switch (status) {
        'APPROVED' when fair?.isOpen == true => (
            'En feria',
            AppTone.success,
            PhosphorIconsFill.radioButton,
          ),
        'APPROVED' when fair?.isClosed == true => (
            'Feria finalizada',
            AppTone.neutral,
            PhosphorIconsRegular.sealCheck,
          ),
        'APPROVED' => (
            'Aprobado',
            AppTone.success,
            PhosphorIconsRegular.sealCheck
          ),
        'SUBMITTED' => (
            'En revisión',
            AppTone.warning,
            PhosphorIconsRegular.hourglassMedium
          ),
        'REJECTED' => (
            'Con observaciones',
            AppTone.danger,
            PhosphorIconsRegular.warningCircle
          ),
        'DRAFT_PENDING_STUDENT_CONFIRMATION' => (
            'Por confirmar',
            AppTone.info,
            PhosphorIconsRegular.notePencil,
          ),
        _ => ('Borrador', AppTone.neutral, PhosphorIconsRegular.pencilSimple),
      };
}

String projectRoleLabel(String? role) => switch (role) {
      'EXPOSITOR' => 'Expositor',
      'COLLABORATOR' => 'Colaborador',
      'OWNER' => 'Responsable',
      _ => 'Integrante',
    };

/// Portada del proyecto. Sin imagen, un bloque con el color institucional y
/// las iniciales del proyecto: nunca un hueco gris.
class ProjectCover extends StatelessWidget {
  const ProjectCover({super.key, required this.project, this.height = 148});

  final StudentProject project;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = AppEnv.mediaUrl(project.coverUrl ?? project.fair?.imageUrl);
    final initials = project.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(gradient: context.brandGradient),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -36,
            child: Icon(
              PhosphorIconsRegular.storefront,
              size: 150,
              color: AppColors.inkInverse.withValues(alpha: 0.12),
            ),
          ),
          Center(
            child: Text(
              initials,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.inkInverse,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
            ),
          ),
        ],
      ),
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: url == null
          ? placeholder
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
              frameBuilder: (_, child, frame, sync) => AnimatedOpacity(
                opacity: sync || frame != null ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: child,
              ),
            ),
    );
  }
}

/// Avatares superpuestos del equipo; el propio alumno lleva anillo de marca.
class TeamAvatars extends StatelessWidget {
  const TeamAvatars({super.key, required this.members, this.size = 30});

  final List<ProjectMate> members;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = members.take(4).toList();
    final extra = members.length - shown.length;
    final step = size * 0.68;
    final count = shown.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      height: size,
      width: count == 0 ? 0 : step * (count - 1) + size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: _Bubble(
                size: size,
                label: shown[i].initials,
                fill: shown[i].isMe
                    ? scheme.primary
                    : Color.alphaBlend(
                        scheme.primary.withValues(alpha: 0.14),
                        scheme.surface,
                      ),
                ink: shown[i].isMe ? scheme.onPrimary : scheme.primary,
                ring: scheme.surface,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: step * shown.length,
              child: _Bubble(
                size: size,
                label: '+$extra',
                fill: scheme.surfaceContainerHighest,
                ink: scheme.onSurfaceVariant,
                ring: scheme.surface,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.size,
    required this.label,
    required this.fill,
    required this.ink,
    required this.ring,
  });

  final double size;
  final String label;
  final Color fill;
  final Color ink;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.34,
            ),
      ),
    );
  }
}

/// Recorrido del proyecto en cinco pasos; el paso actual pulsa suavemente.
class ProjectJourney extends StatelessWidget {
  const ProjectJourney({super.key, required this.project});

  final StudentProject project;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final current = project.stage.index;
    final failed = project.isRejected;
    const labels = ['Inscrito', 'Revisión', 'Aprobado', 'En feria', 'Cierre'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: i == 0
                          ? const SizedBox()
                          : _Track(done: i <= current, color: scheme.primary),
                    ),
                    _Dot(
                      done: i < current || (i == current && !failed),
                      current: i == current,
                      failed: failed && i == current,
                    ),
                    Expanded(
                      child: i == labels.length - 1
                          ? const SizedBox()
                          : _Track(done: i < current, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  text.t(labels[i]),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: i <= current
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight:
                            i == current ? FontWeight.w800 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.done, required this.color});

  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: done ? 1 : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Container(
        height: 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: LinearGradient(
            stops: [v, v],
            colors: [color, Theme.of(context).colorScheme.outlineVariant],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.done, required this.current, required this.failed});

  final bool done;
  final bool current;
  final bool failed;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.current && !widget.failed && !reduce) {
      _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.failed ? AppColors.danger : scheme.primary;
    final filled = widget.done || widget.failed;
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.current && !widget.failed)
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 14 + 10 * _pulse.value,
                height: 14 + 10 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.28 * (1 - _pulse.value)),
                ),
              ),
            ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? color : scheme.surface,
              border: Border.all(
                color: filled ? color : scheme.outline,
                width: 2,
              ),
            ),
            child: filled
                ? Icon(
                    widget.failed
                        ? PhosphorIconsBold.exclamationMark
                        : PhosphorIconsBold.check,
                    size: 10,
                    color: BrandContrast.onColor(color),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Logo del proyecto. Si no hay imagen, muestra las iniciales.
class ProjectLogo extends StatelessWidget {
  const ProjectLogo({super.key, required this.project, this.size = 56});

  final StudentProject project;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = AppEnv.mediaUrl(project.logoUrl);
    final initials = project.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    final fallback = ColoredBox(
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: AppRadii.rMedium,
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

/// Banner de todas las fotos del proyecto. Con más de una, indica «2/8».
/// Al tocar una, se abre a pantalla completa y se puede ampliar.
class ProjectImageBanner extends StatefulWidget {
  const ProjectImageBanner({
    super.key,
    required this.urls,
    required this.fallback,
  });

  final List<String> urls;
  final Widget fallback;

  @override
  State<ProjectImageBanner> createState() => _ProjectImageBannerState();
}

class _ProjectImageBannerState extends State<ProjectImageBanner> {
  late final PageController _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    if (urls.isEmpty) return widget.fallback;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProjectImageViewer(urls: urls, initialIndex: _index),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _page,
            itemCount: urls.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (_, index) => Image.network(
              urls[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => widget.fallback,
            ),
          ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.m,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      '${_index + 1}/${urls.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
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

/// Visor de fotos a pantalla completa, con deslizamiento y ampliación.
class ProjectImageViewer extends StatefulWidget {
  const ProjectImageViewer({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<ProjectImageViewer> createState() => _ProjectImageViewerState();
}

class _ProjectImageViewerState extends State<ProjectImageViewer> {
  late final PageController _page =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: widget.urls.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (_, index) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.urls[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.l),
                  child: Text(
                    '${_index + 1}/${widget.urls.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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

/// Fotos del proyecto, en el orden en que las guardó el servidor.
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
            IconButton.filled(
              tooltip: text.t(playing ? 'Pausar video' : 'Reproducir video'),
              onPressed: () {
                setState(() {
                  playing ? controller.pause() : controller.play();
                });
              },
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
