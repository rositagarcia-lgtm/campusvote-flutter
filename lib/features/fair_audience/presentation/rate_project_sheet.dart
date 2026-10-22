import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_notice.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../teaching_evaluation/presentation/widgets/teacher_rating_selector.dart';
import '../data/fair_audience_repository.dart';
import '../domain/audience_models.dart';
import 'audience_widgets.dart';
import '../../../core/feedback/app_haptics.dart';
import '../../../core/analytics/app_analytics.dart';

/// Hoja para calificar un proyecto como público. Devuelve `true` si guardó.
Future<bool?> showRateProjectSheet(
  BuildContext context, {
  required String fairId,
  required AudienceProject project,
  required bool canRate,
}) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _RateSheet(fairId: fairId, project: project, canRate: canRate),
    );

class _RateSheet extends ConsumerStatefulWidget {
  const _RateSheet({
    required this.fairId,
    required this.project,
    required this.canRate,
  });

  final String fairId;
  final AudienceProject project;
  final bool canRate;

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  late int _score = widget.project.myScore ?? 0;
  late final _comment =
      TextEditingController(text: widget.project.myComment ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_score < 1) {
      setState(() => _error = 'Elige de 1 a 5 estrellas.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(fairAudienceRepositoryProvider).rate(
            fairId: widget.fairId,
            projectId: widget.project.id,
            score: _score,
            comment: _comment.text,
          );
      AppAnalytics.event('audience_project_rated', {'score': _score});
      AppHaptics.success();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = mapExceptionToFailure(error).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = widget.project;
    final editable = widget.canRate && !project.isMine;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.l,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AudienceThumb(project: project, size: 56),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(
                    project.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (project.description != null) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                project.description!,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            if (project.isMine)
              const NoticeBanner(
                tone: AppTone.info,
                icon: PhosphorIconsRegular.info,
                message:
                    'Es tu proyecto: no puedes calificarlo. Lo que opinen tus compañeros lo verás en Mis proyectos.',
              )
            else if (!widget.canRate)
              NoticeBanner(
                tone: AppTone.info,
                icon: PhosphorIconsRegular.lockSimple,
                message: project.myScore == null
                    ? 'La feria ya cerró: las opiniones quedaron congeladas.'
                    : 'La feria ya cerró. Tu voto fue de ${project.myScore} estrellas.',
              )
            else ...[
              TeacherRatingSelector(
                title: 'Tu calificación',
                value: _score,
                enabled: !_saving,
                onChanged: (value) => setState(() {
                  _score = value;
                  _error = null;
                }),
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: 'Comentario de mejora (opcional)',
                hint: '¿Qué podrían mejorar? Sé concreto y respetuoso.',
                helperText: 'Solo lo verá el equipo del proyecto.',
                controller: _comment,
                maxLines: 3,
                maxLength: 500,
                enabled: !_saving,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.s),
                NoticeBanner(
                  tone: AppTone.danger,
                  icon: PhosphorIconsRegular.warningCircle,
                  message: _error!,
                  liveRegion: true,
                ),
              ],
              const SizedBox(height: AppSpacing.m),
              AppButton(
                label: project.myScore == null
                    ? 'Enviar mi opinión'
                    : 'Actualizar mi opinión',
                icon: PhosphorIconsRegular.paperPlaneTilt,
                isLoading: _saving,
                onPressed: editable && !_saving ? _save : null,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Tu voto no cuenta para la nota del jurado.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
