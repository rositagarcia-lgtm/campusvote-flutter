part of '../student_project_detail_page.dart';

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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        0,
      ),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: AppRadii.rMedium,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.videoCamera,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text.t('Presentación en video'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          text.t('Conoce la propuesta del equipo'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (url == null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.l,
                ),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: AppRadii.rMedium,
                ),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIconsRegular.videoCamera,
                      size: 28,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      text.t('Aún no hay video del proyecto.'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s,
                  0,
                  AppSpacing.s,
                  AppSpacing.s,
                ),
                child: ProjectVideo(url: url!),
              ),
          ],
        ),
      ),
    );
  }
}
