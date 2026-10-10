import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_notice.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/translatable_text.dart';
import '../../settings/presentation/settings_copy.dart';
import '../data/student_projects_repository.dart';
import '../domain/student_project.dart';
import 'widgets/project_visuals.dart';

/// `/teaching/projects/:projectId` — detalle con recorrido, equipo y la
/// valoración del jurado.
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
      Column(
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
      _Section(
        title: text.t('Valoración del jurado'),
        child: project.hasFeedback
            ? _Feedback(project: project)
            : Text(
                text.t(
                    'Los Me gusta y comentarios del jurado aparecerán cuando tu proyecto esté en una feria abierta.'),
                style: theme.textTheme.bodyMedium,
              ),
      ),
    ];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectFeedbackProvider(project));
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
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Hero(
                  tag: 'project-cover-${project.id}',
                  child: ProjectCover(project: project, height: 280),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxxl,
              ),
              sliver: SliverList.separated(
                itemCount: sections.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.l),
                itemBuilder: (_, i) => AppMotion.reveal(i, sections[i]),
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

/// Me gusta con un "latido" al aparecer y comentarios anónimos del jurado.
class _Feedback extends ConsumerWidget {
  const _Feedback({required this.project});

  final StudentProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final feedback = ref.watch(projectFeedbackProvider(project));

    return feedback.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Text(
        text.t('No pudimos cargar la valoración. Desliza para reintentar.'),
        style: theme.textTheme.bodyMedium,
      ),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, s, child) =>
                    Transform.scale(scale: s, child: child),
                child: const Icon(
                  PhosphorIconsFill.heart,
                  color: AppColors.danger,
                  size: 34,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              CountUpText(
                value: data.likes,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  text.t('Me gusta del jurado'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (data.comments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            for (var i = 0; i < data.comments.length; i++)
              AppMotion.reveal(i, _CommentBubble(comment: data.comments[i])),
          ] else ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              text.t('Aún no hay comentarios del jurado.'),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment});

  final ProjectComment comment;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final date = comment.createdAt == null
        ? null
        : DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .format(comment.createdAt!);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          scheme.primary.withValues(alpha: 0.06),
          scheme.surface,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
          topLeft: Radius.circular(4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatableText(comment.text, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [text.t('Jurado'), if (date != null) date].join(' · '),
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
