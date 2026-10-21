import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'evaluation_progress_card.dart';

import '../../../core/branding/branding_controller.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/organization_panel_app_bar.dart';
import '../data/teacher_results_repository.dart';
import '../domain/teacher_results.dart';
import 'teacher_results_widgets.dart';

/// `/teacher/evaluation` — cómo le fue al docente en la evaluación de sus
/// alumnos. Solo agregados anónimos y solo cuando termina la jornada.
class TeacherResultsPage extends ConsumerWidget {
  const TeacherResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(teacherResultsProvider);
    final branding = ref.watch(brandingControllerProvider);
    Future<void> reload() {
      ref.invalidate(teacherEvaluationProgressProvider);
      return ref.refresh(teacherResultsProvider.future);
    }

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Mi evaluación docente',
        actions: [
          IconButton(
            tooltip: 'Actualizar resultados',
            icon: const Icon(PhosphorIconsRegular.arrowClockwise),
            onPressed: reload,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: reload,
        child: results.when(
          loading: () => const AppLoader(),
          error: (error, _) => AppErrorView(
            message: mapExceptionToFailure(error).message,
            onRetry: reload,
          ),
          data: (data) => _Body(results: data),
        ),
      ),
      bottomNavigationBar:
          const AppBottomNav(current: AppNavDestination.results),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.results});

  final TeacherResults results;

  @override
  Widget build(BuildContext context) {
    // Los estados vacíos también deben poder refrescarse con el gesto.
    Widget scrollable(Widget child) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              // El avance de la jornada se ve aunque aún no haya resultados.
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
                  child: EvaluationProgressCard(),
                ),
                child,
              ]),
            ),
          ),
        );

    switch (results.status) {
      case TeacherResultsStatus.locked:
        return scrollable(const AppEmptyView(
          icon: PhosphorIconsRegular.lockSimple,
          overline: 'RESULTADOS EN CAMINO',
          title: 'La jornada de evaluación sigue abierta',
          message: 'Tus resultados aparecen cuando termine, para que nadie vea '
              'resultados parciales mientras los alumnos evalúan.',
        ));
      case TeacherResultsStatus.insufficient:
        return scrollable(AppEmptyView(
          icon: PhosphorIconsRegular.shieldCheck,
          overline: 'ANONIMATO PROTEGIDO',
          title: 'Aún no hay suficientes evaluaciones',
          message: 'Para proteger a tus alumnos, los resultados se muestran '
              'desde ${results.minimumRequired} evaluaciones: llevas '
              '${results.totalResponses} de ${results.minimumRequired}. Se suman '
              'las de todos tus cursos y periodos, así que aunque tengas un solo '
              'curso o vengas un día a la semana, se completan con el tiempo.',
        ));
      case TeacherResultsStatus.available:
        return _Results(results: results);
    }
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results});

  final TeacherResults results;

  @override
  Widget build(BuildContext context) {
    final strongest = results.strongest;
    final weakest = results.weakest;
    var step = 0;
    Widget reveal(Widget child) => AppMotion.reveal(step++, child);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EvaluationProgressCard(),
                reveal(ResultsHero(results: results)),
                if (strongest != null && weakest != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  reveal(ResultsHighlights(
                      strongest: strongest, weakest: weakest)),
                ],
                if (results.byCriterion.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    label: 'RÚBRICA',
                    title: 'Por criterio',
                    subtitle: 'De mayor a menor puntaje.',
                  ),
                  ResultsPanel(children: [
                    for (final c in results.byCriterion)
                      ScoreBarRow(
                          label: c.name,
                          caption: c.description,
                          average: c.average),
                  ]),
                ],
                if (results.byCourse.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    label: 'CURSOS',
                    title: 'Por curso',
                    subtitle: 'Solo cursos con suficientes evaluaciones.',
                  ),
                  ResultsPanel(children: [
                    for (final c in results.byCourse)
                      ScoreBarRow(
                        label:
                            c.courseName.isEmpty ? c.courseCode : c.courseName,
                        caption: [
                          if (c.courseCode.isNotEmpty) c.courseCode,
                          if (c.cycle != null) 'Ciclo ${c.cycle}',
                          if (c.periodName != null) c.periodName!,
                          '${c.responses} evaluaciones',
                        ].join(' · '),
                        average: c.average,
                      ),
                  ]),
                ],
                if (results.distribution.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    label: 'PUNTAJES',
                    title: 'Cómo te calificaron',
                    subtitle: 'Total de estrellas recibidas en los criterios.',
                  ),
                  ResultsPanel(children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.m),
                      child:
                          DistributionBars(distribution: results.distribution),
                    ),
                  ]),
                ],
                if (results.evolution.length > 1) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    label: 'HISTORIAL',
                    title: 'Evolución por periodo',
                  ),
                  ResultsPanel(children: [
                    for (final p in results.evolution)
                      ScoreBarRow(
                        label: p.periodName,
                        caption: '${p.responses} evaluaciones',
                        average: p.average,
                      ),
                  ]),
                ],
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  label: 'ALUMNOS',
                  title: 'Comentarios anónimos',
                  count: results.comments.length,
                ),
                if (results.comments.isEmpty)
                  Text('Tus alumnos no dejaron comentarios.',
                      style: Theme.of(context).textTheme.bodyMedium)
                else
                  for (final comment in results.comments)
                    AnonymousComment(text: comment),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
