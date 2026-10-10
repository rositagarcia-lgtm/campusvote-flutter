import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/branding_controller.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/organization_panel_app_bar.dart';
import '../../settings/presentation/settings_copy.dart';
import '../data/student_projects_repository.dart';
import '../domain/student_project.dart';
import 'widgets/project_visuals.dart';

/// `/teaching/projects` — proyectos de feria donde participa el alumno.
class StudentProjectsPage extends ConsumerWidget {
  const StudentProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final projects = ref.watch(studentProjectsProvider);
    Future<void> reload() => ref.refresh(studentProjectsProvider.future);

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: ref.watch(brandingControllerProvider),
        section: text.t('Mis proyectos'),
      ),
      body: projects.when(
        loading: () => const AppLoader(),
        error: (e, _) => AppErrorView(
          message: text.t('No pudimos cargar tus proyectos.'),
          onRetry: reload,
        ),
        data: (items) => items.isEmpty
            ? AppEmptyView(
                icon: PhosphorIconsRegular.storefront,
                overline: text.t('FERIAS'),
                title: text.t('Aún no participas en una feria'),
                message: text.t(
                    'Cuando tu docente te inscriba en un proyecto, lo verás aquí.'),
              )
            : RefreshIndicator(
                onRefresh: reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.xxl,
                  ),
                  children: [
                    AppMotion.reveal(0, _Summary(projects: items)),
                    const SizedBox(height: AppSpacing.xl),
                    for (var i = 0; i < items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.l),
                        child: AppMotion.reveal(
                          i + 1,
                          _ProjectCard(project: items[i]),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar:
          const AppBottomNav(current: AppNavDestination.projects),
    );
  }
}

/// Cabecera con el color institucional y tres cifras que cuentan al entrar.
class _Summary extends StatelessWidget {
  const _Summary({required this.projects});

  final List<StudentProject> projects;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final approved = projects.where((p) => p.isApproved).length;
    final live = projects.where((p) => p.stage == ProjectStage.live).length;
    final onBrand = BrandContrast.onColor(theme.colorScheme.primary);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      // Color institucional plano: sin brillo ni degradado decorativo.
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: AppRadii.rLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.t('Tus proyectos de feria'),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: onBrand,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            text.t('Solo ves los proyectos en los que participas.'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onBrand.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              _Stat(value: projects.length, label: text.t('Proyectos')),
              _Stat(value: approved, label: text.t('Aprobados')),
              _Stat(value: live, label: text.t('En feria')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBrand = BrandContrast.onColor(theme.colorScheme.primary);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountUpText(
            value: value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: onBrand,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: onBrand.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final StudentProject project;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (label, tone, icon) = project.statusBadge;
    final meta = [
      if (project.category != null) project.category!,
      if (project.stand != null) '${text.t('Stand')} ${project.stand}',
    ].join('  ·  ');

    return Pressable(
      onTap: () => context.push('/teaching/projects/${project.id}'),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadii.rLarge,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'project-cover-${project.id}',
                  child: ProjectCover(project: project, height: 112),
                ),
                Positioned(
                  left: AppSpacing.m,
                  top: AppSpacing.m,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: StatusChip(
                      label: text.t(label),
                      tone: tone,
                      icon: icon,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (project.fair != null)
                    Text(
                      project.fair!.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    project.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(meta, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    children: [
                      TeamAvatars(members: project.members),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          '${text.t('Tú')}: ${text.t(projectRoleLabel(project.myRole))}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      Icon(
                        PhosphorIconsBold.arrowRight,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
