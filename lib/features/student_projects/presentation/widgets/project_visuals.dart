import 'package:flutter/material.dart';

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
