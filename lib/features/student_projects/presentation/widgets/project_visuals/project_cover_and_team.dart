part of '../project_visuals.dart';

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
