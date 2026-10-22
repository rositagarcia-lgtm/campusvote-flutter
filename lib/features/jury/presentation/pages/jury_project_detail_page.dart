import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_env.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../providers/jury_voting_status_provider.dart';

/// Detalle de un proyecto que el backend asignó a una categoría del jurado.
class JuryProjectDetailPage extends ConsumerWidget {
  const JuryProjectDetailPage({
    super.key,
    required this.fairId,
    required this.projectId,
  });

  final String fairId;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(fairProjectsProvider(fairId));
    final project =
        projects.valueOrNull?.where((item) => item.id == projectId).firstOrNull;
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Detalle del proyecto'),
      body: projects.isLoading
          ? const AppLoader()
          : projects.hasError
              ? AppErrorView(
                  message: 'No pudimos cargar tus proyectos asignados.',
                  onRetry: () => ref.invalidate(fairProjectsProvider(fairId)),
                )
              : project == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.l),
                        child: Text(
                            'Este proyecto no está asignado a tus categorías.'),
                      ),
                    )
                  : _ProjectContent(fairId: fairId, project: project),
    );
  }
}

class _ProjectContent extends ConsumerWidget {
  const _ProjectContent({required this.fairId, required this.project});

  final String fairId;
  final FairProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(juryProgressProvider(fairId));
    final evaluations = ref.watch(myEvaluationsProvider(fairId));
    final voting = ref.watch(juryVotingStatusProvider(fairId));
    final ownRubric = evaluations.valueOrNull
        ?.where((item) => item.projectId == project.id)
        .firstOrNull;
    final categories =
        voting.valueOrNull?.categories ?? const <VotingCategory>[];
    final categoryVote =
        categories.where((item) => item.id == project.categoryId).firstOrNull;
    final voted = categoryVote?.hasVoted ??
        (categories.isEmpty ? voting.valueOrNull?.hasVoted : null);
    final signed = progress.valueOrNull?.declaration != null;
    final cover = AppEnv.mediaUrl(project.coverUrl ??
        (project.imageUrls.isEmpty ? null : project.imageUrls.first));

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.invalidate(fairProjectsProvider(fairId));
        ref.invalidate(myEvaluationsProvider(fairId));
        ref.invalidate(juryProgressProvider(fairId));
        ref.invalidate(juryVotingStatusProvider(fairId));
        await ref.read(fairProjectsProvider(fairId).future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          if (cover != null)
            ClipRRect(
              borderRadius: AppRadii.rLarge,
              child: Image.network(
                cover,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          Text(project.name,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.s),
          Wrap(spacing: AppSpacing.m, runSpacing: AppSpacing.s, children: [
            if (project.categoryName != null)
              _Fact(
                  icon: PhosphorIconsRegular.squaresFour,
                  text: project.categoryName!),
            if (project.standCode != null)
              _Fact(
                  icon: PhosphorIconsRegular.storefront,
                  text: 'Stand ${project.standCode}'),
          ]),
          if (project.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text(project.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
          const SizedBox(height: AppSpacing.xl),
          _StatusCard(
            title: 'Tu rúbrica',
            icon: PhosphorIconsRegular.checkSquareOffset,
            detail: evaluations.isLoading
                ? 'Consultando tu evaluación…'
                : evaluations.hasError
                    ? 'No pudimos consultar tu evaluación.'
                    : ownRubric?.submitted == true
                        ? 'Registrada${ownRubric?.checkedCount == null || ownRubric?.criteriaCount == null ? '' : ' · ${ownRubric!.checkedCount} de ${ownRubric.criteriaCount} criterios'}'
                        : 'Pendiente',
          ),
          const SizedBox(height: AppSpacing.s),
          if (ref.watch(juryFairInPreviewProvider(fairId)))
            const NoticeBanner(
              tone: AppTone.warning,
              icon: PhosphorIconsRegular.eye,
              message: 'Vista previa: estudia el proyecto. Podrás completar la rúbrica y votar cuando empiece la feria.',
            )
          else if (progress.isLoading)
            const Center(child: CircularProgressIndicator.adaptive())
          else if (progress.hasError)
            TextButton.icon(
              onPressed: () => ref.invalidate(juryProgressProvider(fairId)),
              icon: const Icon(PhosphorIconsRegular.arrowClockwise),
              label: const Text('Reintentar estado de declaración'),
            )
          else if (!signed)
            FilledButton.icon(
              onPressed: () => context.push('/jury/fair/$fairId/declaration'),
              icon: const Icon(PhosphorIconsRegular.signature),
              label: const Text('Firmar declaración para evaluar'),
            )
          else
            FilledButton.icon(
              onPressed: () => context
                  .push('/jury/fair/$fairId/project/${project.id}/rubric'),
              icon: const Icon(PhosphorIconsRegular.notePencil),
              label: Text(ownRubric?.submitted == true
                  ? 'Ver mi rúbrica registrada'
                  : 'Completar mi rúbrica'),
            ),
          const SizedBox(height: AppSpacing.l),
          _StatusCard(
            title: 'Voto de tu categoría',
            icon: PhosphorIconsRegular.checkCircle,
            detail: voting.isLoading
                ? 'Consultando estado del voto…'
                : voting.hasError
                    ? 'No pudimos consultar tu voto.'
                    : voted == true
                        ? 'Emitido'
                        : 'Pendiente',
          ),
          const SizedBox(height: AppSpacing.s),
          if (signed)
            OutlinedButton.icon(
              onPressed: () => context.push('/jury/fair/$fairId/vote'),
              icon: const Icon(PhosphorIconsRegular.arrowRight),
              label: const Text('Ir a la votación oficial'),
            ),
          Text(
            'El voto es anónimo. Aquí solo aparece si ya votaste en esta categoría.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: AppSpacing.xs),
          Text(text),
        ],
      );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.icon,
    required this.detail,
  });
  final String title;
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(detail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
