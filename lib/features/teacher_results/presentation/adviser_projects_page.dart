import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../data/adviser_projects_repository.dart';

/// `/teacher/projects` — proyectos que el docente asesora: estado, feria y
/// equipo. Primero los que esperan una acción.
class AdviserProjectsPage extends ConsumerWidget {
  const AdviserProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(adviserProjectsProvider);
    Future<void> reload() => ref.refresh(adviserProjectsProvider.future);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Proyectos que asesoro',
        leading: IconButton(
          tooltip: 'Volver al inicio',
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.go('/teacher'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: reload,
        child: projects.when(
          loading: () => const AppLoader(),
          error: (error, _) => AppErrorView(
            message: mapExceptionToFailure(error).message,
            onRetry: reload,
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  AppEmptyView(
                    icon: PhosphorIconsRegular.folderUser,
                    overline: 'ASESORÍA',
                    title: 'Aún no asesoras proyectos',
                    message:
                        'Cuando la sede te autorice como asesor de una feria e '
                        'inscribas proyectos con tus alumnos, aparecerán aquí.',
                  ),
                ],
              );
            }
            final sorted = [...items]..sort((a, b) {
                final pa = a.statusLabel.$2 ? 0 : 1;
                final pb = b.statusLabel.$2 ? 0 : 1;
                return pa.compareTo(pb);
              });
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                for (var i = 0; i < sorted.length; i++)
                  AppMotion.reveal(i, _AdvisedCard(project: sorted[i])),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdvisedCard extends StatelessWidget {
  const _AdvisedCard({required this.project});

  final AdvisedProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (label, needsAction) = project.statusLabel;
    final tone = switch (project.status) {
      'APPROVED' => AppTone.success,
      'REJECTED' => AppTone.danger,
      'SUBMITTED' => AppTone.info,
      _ => AppTone.warning,
    };
    final meta = [
      if (project.fairName != null) project.fairName!,
      if (project.category != null) project.category!,
      if (project.stand != null) 'Stand ${project.stand}',
    ].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.rLarge,
        onTap: () => context.push('/teacher/projects/${project.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(
              color: needsAction ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              if (meta.isNotEmpty) Text(meta, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.s),
              StatusChip(label: label, tone: tone),
              if (project.team.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(PhosphorIconsRegular.usersThree,
                        size: 16, color: scheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(project.team.join(', '),
                          style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
