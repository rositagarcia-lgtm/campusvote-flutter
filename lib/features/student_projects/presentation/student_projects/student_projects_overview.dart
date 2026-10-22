part of '../student_projects_page.dart';

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
        actions: const [NotificationsBell()],
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
            : RefreshIndicator.adaptive(
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
