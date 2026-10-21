import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/branding_controller.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/organization_panel_app_bar.dart';
import '../../auth/presentation/state/auth_controller.dart';
import '../../jury/presentation/providers/jury_providers.dart';
import '../../notifications/presentation/widgets/notifications_bell.dart';
import '../data/adviser_projects_repository.dart';
import '../data/teacher_results_repository.dart';
import '../../fair_results/presentation/published_results_section.dart';
import 'jury_mode_card.dart';
import 'evaluation_progress_card.dart';
import '../domain/teacher_results.dart';

/// `/teacher` — inicio del docente. Todos ven su evaluación; el bloque de
/// jurado solo se abre si la organización lo asignó a alguna feria (la
/// mayoría de docentes no es jurado).
class TeacherHomePage extends ConsumerWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final name =
        ref.watch(authControllerProvider.select((s) => s.user?.firstName)) ??
            '';
    final results = ref.watch(teacherResultsProvider);
    final fairs = ref.watch(juryDashboardProvider);
    final advised = ref.watch(adviserProjectsProvider);
    final theme = Theme.of(context);

    Future<void> reload() async {
      ref.invalidate(teacherResultsProvider);
      ref.invalidate(adviserProjectsProvider);
      await ref.read(juryDashboardProvider.notifier).reload();
    }

    final evaluationSubtitle = results.when(
      loading: () => 'Consultando tus resultados…',
      error: (_, __) =>
          'No pudimos cargar tus resultados. Desliza para reintentar.',
      data: (r) => switch (r.status) {
        TeacherResultsStatus.available =>
          'Promedio ${r.overallAverage.toStringAsFixed(1)} de 5 · ${r.totalResponses} evaluaciones',
        TeacherResultsStatus.locked =>
          'Se publica cuando termine la jornada de evaluación.',
        TeacherResultsStatus.insufficient =>
          'Aún no hay suficientes evaluaciones para mostrarlas.',
      },
    );
    final assigned = fairs.valueOrNull ?? const [];
    // Con una feria abierta, ser jurado es lo urgente del día: va primero.
    final juryActive = assigned.any((f) => f.isOpen);
    final juryCard = JuryModeCard(fairs: assigned, loading: fairs.isLoading);

    final advisedList = advised.valueOrNull ?? const [];
    final pendingAdvice = advisedList.where((p) => p.statusLabel.$2).length;
    final adviserSubtitle = advised.isLoading
        ? 'Consultando tus proyectos…'
        : advised.hasError
            ? 'No pudimos consultar tus proyectos.'
            : advisedList.isEmpty
                ? 'Aún no asesoras proyectos en ferias.'
                : '${advisedList.length} proyecto${advisedList.length == 1 ? '' : 's'}'
                    '${pendingAdvice > 0 ? ' · $pendingAdvice por atender' : ''}';

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Panel docente',
        actions: const [NotificationsBell()],
      ),
      body: RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('PANEL DOCENTE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        )),
                    const SizedBox(height: AppSpacing.s),
                    AppMotion.reveal(
                      0,
                      Text(
                        name.trim().isEmpty ? 'Hola' : 'Hola, ${name.trim()}',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Revisa cómo te evaluaron tus alumnos, los proyectos que '
                      'asesoras y, si te asignaron, tus ferias como jurado.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const EvaluationProgressCard(),
                    const PublishedResultsSection(),
                    if (juryActive) ...[
                      AppMotion.reveal(1, juryCard),
                      const SizedBox(height: AppSpacing.m),
                    ],
                    AppMotion.reveal(
                      1,
                      _HomeCard(
                        icon: PhosphorIconsRegular.chartBar,
                        title: 'Mi evaluación docente',
                        subtitle: evaluationSubtitle,
                        onTap: () => context.go('/teacher/evaluation'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    AppMotion.reveal(
                      2,
                      _HomeCard(
                        icon: PhosphorIconsRegular.folderUser,
                        title: 'Proyectos que asesoro',
                        subtitle: adviserSubtitle,
                        onTap: () => context.go('/teacher/projects'),
                      ),
                    ),
                    // Sin asignación como jurado no se muestra nada de jurado.
                    if (!juryActive && assigned.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s),
                      AppMotion.reveal(3, juryCard),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.home),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    return Semantics(
      button: enabled,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s + 2),
                decoration: BoxDecoration(
                  color: (enabled ? scheme.primary : scheme.onSurfaceVariant)
                      .withValues(alpha: 0.1),
                  borderRadius: AppRadii.rMedium,
                ),
                child: Icon(icon,
                    color: enabled ? scheme.primary : scheme.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (enabled)
                Icon(PhosphorIconsRegular.caretRight,
                    color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
