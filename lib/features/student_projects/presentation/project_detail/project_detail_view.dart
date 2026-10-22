part of '../student_project_detail_page.dart';

/// Ficha del proyecto: portada, datos, recorrido, reseñas y equipo.
class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView({
    required this.project,
    required this.onBack,
    required this.showStar,
    required this.starTooltip,
    required this.onStar,
    required this.onRefresh,
    this.onRate,
    this.reviews,
    this.rateTooltip = 'Calificar',
  });

  final StudentProject project;
  final VoidCallback onBack;
  final bool showStar;
  final String starTooltip;
  final VoidCallback onStar;
  final Future<void> Function() onRefresh;
  final VoidCallback? onRate;
  final String rateTooltip;

  /// Resumen de reseñas y comentarios (solo en tu propio proyecto).
  final Widget? reviews;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final (label, tone, icon) = project.statusBadge;
    final photos = _bannerUrls(project);
    final videoUrl = AppEnv.mediaUrl(project.videoUrl);
    final sections = <Widget>[
      Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [
          StatusChip(label: text.t(label), tone: tone, icon: icon),
          if (project.myRole != null)
            StatusChip(
              label: text.t(projectRoleLabel(project.myRole)),
              tone: AppTone.primary,
              icon: PhosphorIconsRegular.identificationBadge,
            ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectLogo(project: project),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (project.fair != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _MetaLine(
                    icon: PhosphorIconsRegular.calendarDots,
                    text: project.fair!.name,
                  ),
                ],
                if (project.category != null)
                  _MetaLine(
                    icon: PhosphorIconsRegular.squaresFour,
                    text: project.category!,
                  ),
                if (project.stand != null)
                  _MetaLine(
                    icon: PhosphorIconsRegular.mapPin,
                    text: '${text.t('Stand')} ${project.stand}',
                  ),
              ],
            ),
          ),
        ],
      ),
      _Section(
        title: text.t('Recorrido'),
        child: ProjectJourney(project: project),
      ),
      if (project.isRejected && project.reviewNotes != null)
        NoticeBanner(
          tone: AppTone.danger,
          icon: PhosphorIconsRegular.warningCircle,
          message: project.reviewNotes!,
        ),
      if (project.description != null)
        _Section(
          title: text.t('Sobre el proyecto'),
          child: TranslatableText(
            project.description!,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      if (reviews != null)
        _Section(title: text.t('Reseñas y comentarios'), child: reviews!),
      _Section(
        title: text.t('Equipo'),
        child: Column(
          children: [
            for (final mate in project.members) _MateRow(mate: mate),
          ],
        ),
      ),
    ];

    return Scaffold(
      floatingActionButton: onRate == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton(
                tooltip: rateTooltip,
                onPressed: onRate,
                child: const Icon(PhosphorIconsFill.star),
              ),
            ),
      body: RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        edgeOffset: 260,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              backgroundColor: theme.colorScheme.surface,
              leading: Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: IconButton.filledTonal(
                  tooltip: text.back,
                  onPressed: onBack,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surface.withValues(alpha: 0.92),
                  ),
                  icon: const Icon(PhosphorIconsRegular.arrowLeft),
                ),
              ),
              actions: [
                if (showStar)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    child: IconButton.filledTonal(
                      tooltip: starTooltip,
                      onPressed: onStar,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surface.withValues(alpha: 0.92),
                      ),
                      icon: const Icon(PhosphorIconsFill.star),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: ProjectImageBanner(
                  urls: photos,
                  fallback: ProjectCover(project: project, height: 280),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                0,
              ),
              sliver: SliverList.separated(
                itemCount: 2,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.l),
                itemBuilder: (_, i) => AppMotion.reveal(i, sections[i]),
              ),
            ),
            SliverToBoxAdapter(child: _ProjectVideoBlock(url: videoUrl)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxxl,
              ),
              sliver: SliverList.separated(
                itemCount: sections.length - 2,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.l),
                itemBuilder: (_, i) => AppMotion.reveal(i + 2, sections[i + 2]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
