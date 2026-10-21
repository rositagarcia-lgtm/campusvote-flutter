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

    final fair = project.fair;
    return _ProjectDetailView(
      project: project,
      onBack: () => _back(context),
      showStar: fairId == null,
      starTooltip: text.t('Reseñas'),
      onStar: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => JuryReviewsPage(project: project),
          ),
        );
      },
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
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView({
    required this.project,
    required this.onBack,
    required this.showStar,
    required this.starTooltip,
    required this.onStar,
    required this.onRefresh,
  });

  final StudentProject project;
  final VoidCallback onBack;
  final bool showStar;
  final String starTooltip;
  final VoidCallback onStar;
  final Future<void> Function() onRefresh;

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
    final sheet = ref.watch(
        audienceProjectProvider((fairId: fairId, projectId: projectId)));

    return sheet.when(
      loading: () => Scaffold(appBar: AppBar(), body: const AppLoader()),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorView(
          message: mapExceptionToFailure(error).message,
          onRetry: () => ref.invalidate(
              audienceProjectProvider((fairId: fairId, projectId: projectId))),
        ),
      ),
      data: (data) {
        final project = data.project;
        return _ProjectDetailView(
          project: project,
          onBack: onBack,
          showStar: false,
          starTooltip: text.t('Reseñas'),
          onStar: () {},
          onRefresh: () async {
            ref.invalidate(audienceProjectProvider(
                (fairId: fairId, projectId: projectId)));
          },
        );
      },
    );
  }
}

