import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../student_projects/presentation/widgets/project_visuals.dart';
import '../data/adviser_projects_repository.dart';

/// Ficha del proyecto que el docente asesora: logo, fotos y video.
class AdviserProjectDetailPage extends ConsumerWidget {
  const AdviserProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(adviserProjectsProvider);
    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Proyecto',
        leading: IconButton(
          tooltip: 'Volver a mis proyectos',
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.go('/teacher/projects'),
        ),
      ),
      body: projects.when(
        loading: () => const AppLoader(),
        error: (_, __) => const AppEmptyView(
          icon: PhosphorIconsRegular.warningCircle,
          title: 'No pudimos abrir el proyecto',
          message: 'Vuelve a la lista e inténtalo de nuevo.',
        ),
        data: (items) {
          AdvisedProject? project;
          for (final item in items) {
            if (item.id == projectId) project = item;
          }
          if (project == null) {
            return const AppEmptyView(
              icon: PhosphorIconsRegular.folderUser,
              title: 'Este proyecto ya no está en tu lista',
              message: 'Puede haber cambiado de asesor o de estado.',
            );
          }
          return _Detail(project: project);
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.project});

  final AdvisedProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, _) = project.statusLabel;
    final logo = AppEnv.mediaUrl(project.logoUrl ?? project.coverUrl);
    final video = AppEnv.mediaUrl(project.videoUrl);
    final tone = switch (project.status) {
      'APPROVED' => AppTone.success,
      'REJECTED' => AppTone.danger,
      'SUBMITTED' => AppTone.info,
      _ => AppTone.warning,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppRadii.rMedium,
              child: SizedBox(
                width: 56,
                height: 56,
                child: logo == null
                    ? ColoredBox(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12))
                    : Image.network(logo, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  if (project.fairName != null)
                    Text(project.fairName!, style: theme.textTheme.bodyMedium),
                  if (project.stand != null)
                    Text('Stand ${project.stand}',
                        style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        StatusChip(label: label, tone: tone),
        if (project.description != null) ...[
          const SizedBox(height: AppSpacing.l),
          Text(project.description!, style: theme.textTheme.bodyLarge),
        ],
        if (project.imageUrls.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text('FOTOS',
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: AppSpacing.s),
          ProjectGallery(urls: project.imageUrls),
        ],
        const SizedBox(height: AppSpacing.l),
        Text('VIDEO',
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: AppSpacing.s),
        if (video == null)
          Text('Aún no hay video del proyecto.',
              style: theme.textTheme.bodyMedium)
        else
          ProjectVideo(url: video),
        if (project.team.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text('EQUIPO',
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: AppSpacing.s),
          Text(project.team.join(', '), style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
