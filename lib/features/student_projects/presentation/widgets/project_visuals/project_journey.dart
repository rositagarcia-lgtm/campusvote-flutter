part of '../project_visuals.dart';

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
