import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/project_status_chip.dart';

/// `/jury/fair/:fairId` — proyectos de la feria.
///
/// El backend ya devuelve SOLO los proyectos aprobados de las categorías
/// asignadas al jurado, así que aquí no se re-filtra (regla 7).
class FairProjectsPage extends ConsumerWidget {
  const FairProjectsPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(fairProjectsProvider(fairId));

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Proyectos',
        actions: [
          IconButton(
            tooltip: 'Mi progreso',
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => context.push('/jury/fair/$fairId/progress'),
          ),
          IconButton(
            tooltip: 'Votar',
            icon: const Icon(Icons.how_to_vote_rounded),
            onPressed: () => context.push('/jury/fair/$fairId/vote'),
          ),
          IconButton(
            tooltip: 'Resultados',
            icon: const Icon(Icons.leaderboard_rounded),
            onPressed: () => context.push('/jury/fair/$fairId/results'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(fairProjectsProvider(fairId)),
        child: _bodyFor(fairId, projects),
      ),
    );
  }
}

Widget _bodyFor(String fairId, AsyncValue<List<FairProjectModel>> projects) {
  switch (projects) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: () => const AppLoader(),
      );
    case AsyncData(:final value):
      if (value.isEmpty) {
        return const AppEmptyView(
          icon: Icons.inventory_2_outlined,
          message: 'No tienes proyectos aprobados para evaluar en esta feria.',
        );
      }
      return _ProjectsList(fairId: fairId, projects: value);
    default:
      return const AppLoader();
  }
}

class _ProjectsList extends ConsumerWidget {
  const _ProjectsList({required this.fairId, required this.projects});

  final String fairId;
  final List<FairProjectModel> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El progreso alimenta el banner superior sin pedir un endpoint extra.
    final progress = ref.watch(juryProgressProvider(fairId));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        if (progress.hasValue) ...[
          _ProgressBanner(progress: progress.requireValue),
          const SizedBox(height: AppSpacing.l),
        ],
        for (final project in projects) ...[
          _ProjectCard(fairId: fairId, project: project),
          const SizedBox(height: AppSpacing.m),
        ],
      ],
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.progress});

  final JuryProgressModel progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: AppRadii.rMedium,
        onTap: () => context.push('/jury/fair/${progress.fairId}/progress'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            children: [
              Icon(Icons.insights_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  'Evaluaste ${progress.completedProjects} de '
                  '${progress.totalProjects} proyectos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.fairId, required this.project});

  final String fairId;
  final FairProjectModel project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: AppRadii.rMedium,
        onTap: () => context.push(
          '/jury/fair/$fairId/project/${project.id}/rubric',
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (project.logoUrl != null)
                    ClipRRect(
                      borderRadius: AppRadii.rSmall,
                      child: Image.network(
                        project.logoUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  ProjectStatusChip(status: project.status),
                  if (project.categoryName != null)
                    _MetaChip(
                        icon: Icons.category_rounded,
                        text: project.categoryName!),
                  if (project.standCode != null)
                    _MetaChip(
                        icon: Icons.storefront_rounded,
                        text: project.standCode!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
