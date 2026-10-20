import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_notice.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/translatable_text.dart';
import '../../fair_audience/data/fair_audience_repository.dart';
import '../../fair_audience/presentation/peer_feedback_section.dart';
import '../../settings/presentation/settings_copy.dart';
import '../data/student_projects_repository.dart';
import '../domain/student_project.dart';
import 'widgets/project_visuals.dart';

/// `/teaching/projects/:projectId` — detalle con equipo y opiniones del público.
class StudentProjectDetailPage extends ConsumerWidget {
  const StudentProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final projects = ref.watch(studentProjectsProvider);
    final project =
        projects.valueOrNull?.where((p) => p.id == projectId).firstOrNull;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: projects.isLoading
            ? const AppLoader()
            : Center(child: Text(text.t('Proyecto no disponible'))),
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
      if (project.isApproved && fair != null && (fair.isOpen || fair.isClosed))
        _Section(
          title: text.t('Opinión de tus compañeros'),
          child: PeerFeedbackSection(fairId: fair.id, projectId: project.id),
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
                  onPressed: () => context.pop(),
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
                    tooltip: text.t('Calificación del jurado'),
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconSmall, color: muted),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          child,
        ],
      ),
    );
  }
}

class _MateRow extends StatelessWidget {
  const _MateRow({required this.mate});

  final ProjectMate mate;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          TeamAvatars(members: [mate], size: 36),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              mate.isMe ? '${mate.name} (${text.t('Tú')})' : mate.name,
              style: theme.textTheme.titleSmall,
            ),
          ),
          Text(
            text.t(projectRoleLabel(mate.role)),
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.label});

  final int rating;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = theme.colorScheme.primary;
    final empty = theme.colorScheme.onSurface.withValues(alpha: 0.35);
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rating ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
            size: 22,
            color: star <= rating ? filled : empty,
          ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.s),
          Text(label, style: theme.textTheme.titleSmall),
        ],
      ],
    );
  }
}

List<String> _bannerUrls(StudentProject project) {
  final Iterable<String> raw = project.imageUrls.isNotEmpty
      ? project.imageUrls
      : [project.coverUrl, project.fair?.imageUrl].whereType<String>();
  return [
    for (final url in raw)
      if (AppEnv.mediaUrl(url) case final src?) src,
  ];
}

class _ProjectVideoBlock extends StatelessWidget {
  const _ProjectVideoBlock({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Text(
              text.t('Video'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          if (url == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Text(
                text.t('Aún no hay video del proyecto.'),
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ProjectVideo(url: url!, borderRadius: BorderRadius.zero),
        ],
      ),
    );
  }
}

class JuryReviewsPage extends ConsumerWidget {
  const JuryReviewsPage({super.key, required this.project});

  final StudentProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final feedback = ref.watch(projectFeedbackProvider(project));

    return Scaffold(
      appBar: AppBar(title: Text(text.t('Calificación del jurado'))),
      body: feedback.when(
        loading: () => const AppLoader(),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              text.t(
                  'No pudimos cargar la valoración. Desliza para reintentar.'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        data: (data) {
          if (!data.published) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text(
                  text.t(
                      'La calificación por estrellas y el voto aparecerán cuando se publiquen los resultados.'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          final average = data.average;
          final reviews = data.reviews;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    average == null ? '—' : average.toStringAsFixed(1),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (average != null)
                          _StarRow(
                            rating: average.round().clamp(1, 5).toInt(),
                            label: '',
                          ),
                        Text(
                          text.t(reviews.length == 1
                              ? '1 reseña del jurado'
                              : '${reviews.length} reseñas del jurado'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${text.t('Votos del jurado')} · ${text.votes(data.votes ?? 0)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              for (var star = 5; star >= 1; star--)
                _RatingBar(
                  star: star,
                  count:
                      reviews.where((review) => review.rating == star).length,
                  total: reviews.length,
                ),
              const SizedBox(height: AppSpacing.l),
              Text(
                text.t('Reseñas del jurado'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Text(
                    text.t('Aún no hay calificaciones por estrellas.'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              for (final review in reviews) _ReviewBlock(review: review),
            ],
          );
        },
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.star,
    required this.count,
    required this.total,
  });

  final int star;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
              width: 12,
              child: Text('$star', style: theme.textTheme.labelMedium)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                color: theme.colorScheme.primary,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  const _ReviewBlock({required this.review});

  final ProjectReview review;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final comment = review.comment;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StarRow(
            rating: review.rating,
            label: text.ratingOutOfFive(review.rating),
          ),
          if (comment != null) ...[
            const SizedBox(height: AppSpacing.xs),
            TranslatableText(comment, style: theme.textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
