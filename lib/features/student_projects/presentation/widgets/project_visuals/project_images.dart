part of '../project_visuals.dart';

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
            builder: (_) =>
                ProjectImageViewer(urls: urls, initialIndex: _index),
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
