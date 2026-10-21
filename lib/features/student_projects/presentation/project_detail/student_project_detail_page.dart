part of '../student_project_detail_page.dart';

/// `/teaching/projects/:projectId`: detalle con equipo y opiniones del público.
class StudentProjectDetailPage extends ConsumerWidget {
  const StudentProjectDetailPage({
    super.key,
    required this.projectId,
    this.fairId,
  });

  final String projectId;

  /// Feria del QR del stand. Si el proyecto no es del alumno, la ficha
  /// se arma con los datos públicos de esa feria.
  final String? fairId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final fair = fairId;
    context.go(fair == null ? '/teaching/projects' : '/teaching/explore/$fair');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final projects = ref.watch(studentProjectsProvider);
    final project =
        projects.valueOrNull?.where((p) => p.id == projectId).firstOrNull;

    if (project == null) {
      if (projects.isLoading) {
        return Scaffold(appBar: AppBar(), body: const AppLoader());
      }
      final fair = fairId;
      if (fair != null) {
        return _StandProjectDetail(
          fairId: fair,
          projectId: projectId,
          onBack: () => _back(context),
        );
      }
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(text.t('Proyecto no disponible'))),
      );
    }

    final theme = Theme.of(context);
    final (label, tone, icon) = project.statusBadge;
    final fair = project.fair;
    final photos = _bannerUrls(project);
    final videoUrl = AppEnv.mediaUrl(project.videoUrl);
    final sections = <Widget>[
      Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [
          StatusChip(label: text.t(label), tone: tone, icon: icon),
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectFeedbackProvider(project));
          if (fair != null) {
            ref.invalidate(
                peerFeedbackProvider((fairId: fair.id, projectId: project.id)));
          }
          await ref
              .refresh(studentProjectsProvider.future)
              .catchError((_) => const <StudentProject>[]);
        },
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
                  onPressed: () => _back(context),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surface.withValues(alpha: 0.92),
                  ),
                  icon: const Icon(PhosphorIconsRegular.arrowLeft),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: IconButton.filledTonal(
                    tooltip: text.t('Reseñas'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => JuryReviewsPage(project: project),
                        ),
                      );
                    },
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

/// Misma ficha del proyecto cuando el QR es de un stand que no es tuyo.
class _StandProjectDetail extends ConsumerWidget {
  const _StandProjectDetail({
    required this.fairId,
    required this.projectId,
    required this.onBack,
  });

  final String fairId;
  final String projectId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final board = ref.watch(audienceBoardProvider(fairId));

    return board.when(
      loading: () => Scaffold(appBar: AppBar(), body: const AppLoader()),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorView(
          message: mapExceptionToFailure(error).message,
          onRetry: () => ref.invalidate(audienceBoardProvider(fairId)),
        ),
      ),
      data: (data) {
        final project =
            data.projects.where((item) => item.id == projectId).firstOrNull;
        if (project == null) {
          return Scaffold(
            appBar: AppBar(leading: IconButton(
              tooltip: text.back,
              onPressed: onBack,
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
            )),
            body: Center(child: Text(text.t('Proyecto no disponible'))),
          );
        }
        return _StandBody(
          fairId: fairId,
          fairName: data.fair.name,
          canRate: data.fair.isOpen,
          project: project,
          onBack: onBack,
        );
      },
    );
  }
}

class _StandBody extends ConsumerWidget {
  const _StandBody({
    required this.fairId,
    required this.fairName,
    required this.canRate,
    required this.project,
    required this.onBack,
  });

  final String fairId;
  final String fairName;
  final bool canRate;
  final AudienceProject project;
  final VoidCallback onBack;

  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    final saved = await showRateProjectSheet(
      context,
      fairId: fairId,
      project: project,
      canRate: canRate,
    );
    if (saved == true) {
      ref.invalidate(audienceBoardProvider(fairId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias! Tu opinión quedó guardada.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showStar = canRate && !project.isMine;
    final cover = AppEnv.mediaUrl(project.coverUrl ?? project.logoUrl);
    final sections = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StandLogo(project: project),
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
                _MetaLine(
                  icon: PhosphorIconsRegular.calendarDots,
                  text: fairName,
                ),
                if (project.category != null)
                  _MetaLine(
                    icon: PhosphorIconsRegular.squaresFour,
                    text: project.category!,
                  ),
                if (project.stand != null)
                  _MetaLine(
                    icon: PhosphorIconsRegular.mapPin,
                    text: 'Stand ${project.stand}',
                  ),
              ],
            ),
          ),
        ],
      ),
      if (project.description != null)
        _Section(
          title: 'Sobre el proyecto',
          child: Text(
            project.description!,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      if (project.isMine)
        const NoticeBanner(
          tone: AppTone.info,
          icon: PhosphorIconsRegular.info,
          message:
              'Es tu proyecto: no puedes calificarlo. Las opiniones de tus compañeros se ven en Mis proyectos.',
        ),
    ];

    return Scaffold(
      floatingActionButton: showStar
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton(
                tooltip:
                    project.myScore == null ? 'Calificar' : 'Editar tu opinión',
                onPressed: () => _rate(context, ref),
                child: const Icon(PhosphorIconsFill.star),
              ),
            )
          : null,
      body: CustomScrollView(
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
                tooltip: 'Volver',
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.surface.withValues(alpha: 0.92),
                ),
                icon: const Icon(PhosphorIconsRegular.arrowLeft),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: cover == null
                  ? DecoratedBox(
                      decoration: BoxDecoration(gradient: context.brandGradient),
                    )
                  : Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: context.brandGradient),
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              120,
            ),
            sliver: SliverList.separated(
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.l),
              itemBuilder: (_, i) => sections[i],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandLogo extends StatelessWidget {
  const _StandLogo({required this.project});

  final AudienceProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = AppEnv.mediaUrl(project.logoUrl ?? project.coverUrl);
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
        width: 56,
        height: 56,
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
