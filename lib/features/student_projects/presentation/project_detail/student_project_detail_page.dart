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
      onStar: () => _openReviews(context, project),
      reviews: fairId == null && project.isApproved
          ? _ReviewsSummaryCard(
              project: project,
              onOpen: () => _openReviews(context, project),
            )
          : null,
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

void _openReviews(BuildContext context, StudentProject project) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => JuryReviewsPage(project: project)),
  );
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
          onRate: data.canRate ? () => _rateStand(context, ref, fairId, data) : null,
          rateTooltip: data.myScore == null ? 'Calificar' : 'Editar tu opinión',
          onRefresh: () async {
            ref.invalidate(audienceProjectProvider(
                (fairId: fairId, projectId: projectId)));
          },
        );
      },
    );
  }
}

Future<void> _rateStand(
  BuildContext context,
  WidgetRef ref,
  String fairId,
  StandSheet sheet,
) async {
  final project = sheet.project;
  final saved = await showRateProjectSheet(
    context,
    fairId: fairId,
    project: AudienceProject(
      id: project.id,
      name: project.name,
      description: project.description,
      coverUrl: project.coverUrl,
      logoUrl: project.logoUrl,
      category: project.category,
      stand: project.stand,
      myScore: sheet.myScore,
      myComment: sheet.myComment,
    ),
    canRate: sheet.canRate,
  );
  if (saved != true) return;
  ref.invalidate(
      audienceProjectProvider((fairId: fairId, projectId: project.id)));
  ref.invalidate(audienceBoardProvider(fairId));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Gracias! Tu opinión quedó guardada.')),
    );
  }
}

