part of '../published_results_page.dart';

/// Podio de una categoría: 2.° · 1.° · 3.° con escalones que suben en cascada
/// (tercero, segundo y al final el ganador, que recibe la corona).
///
/// Solo usa el orden que publica el servidor; no muestra votos (voto secreto).
/// Con animaciones reducidas aparece directamente en su estado final.
class _AnimatedPodium extends StatelessWidget {
  const _AnimatedPodium({required this.category});

  final CategoryPodium category;

  PodiumEntry? _at(int position) =>
      category.podium.where((entry) => entry.position == position).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final slots = [
      (_at(2), 2, 92.0, 260),
      (_at(1), 1, 128.0, 520),
      (_at(3), 3, 68.0, 0),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.l, AppSpacing.m, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (entry, position, height, delay) in slots)
            Expanded(
              child: entry == null
                  ? const SizedBox.shrink()
                  : _PodiumColumn(
                      entry: entry,
                      position: position,
                      height: height,
                      delay: reduced ? Duration.zero : Duration(milliseconds: delay),
                      animate: !reduced,
                    ),
            ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatefulWidget {
  const _PodiumColumn({
    required this.entry,
    required this.position,
    required this.height,
    required this.delay,
    required this.animate,
  });

  final PodiumEntry entry;
  final int position;
  final double height;
  final Duration delay;
  final bool animate;

  @override
  State<_PodiumColumn> createState() => _PodiumColumnState();
}

class _PodiumColumnState extends State<_PodiumColumn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: widget.animate ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = medalColor(widget.position);
    final winner = widget.position == 1;
    final rise = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOutBack));
    final appear = CurvedAnimation(parent: _controller, curve: const Interval(0.45, 1, curve: Curves.easeOut));
    final size = winner ? 64.0 : 52.0;

    return Semantics(
      label: '${widget.position}.° puesto: ${widget.entry.projectName}',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: appear.value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - appear.value)),
                child: Column(
                  children: [
                    if (winner)
                      Transform.scale(
                        scale: 0.6 + 0.4 * appear.value,
                        child: const Icon(PhosphorIconsFill.crownSimple, color: _gold, size: 26),
                      ),
                    _PodiumAvatar(entry: widget.entry, color: color, size: size),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.entry.projectName,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: winner ? FontWeight.w800 : FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (widget.entry.isMine)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Tu proyecto',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF16A34A), fontWeight: FontWeight.w800)),
                      ),
                    const SizedBox(height: AppSpacing.s),
                  ],
                ),
              ),
            ),
            Container(
              height: widget.height * rise.value.clamp(0.0, 1.2),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                ),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 8),
              child: rise.value < 0.4
                  ? null
                  : Text('${widget.position}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumAvatar extends StatelessWidget {
  const _PodiumAvatar({required this.entry, required this.color, required this.size});

  final PodiumEntry entry;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: color,
      child: Icon(PhosphorIconsFill.medal, color: Colors.white, size: size * 0.45),
    );
    final url = entry.coverUrl;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: ClipOval(
        child: url == null
            ? fallback
            : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}
