part of '../student_projects_page.dart';

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
