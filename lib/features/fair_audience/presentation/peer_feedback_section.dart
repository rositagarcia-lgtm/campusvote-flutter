import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../data/fair_audience_repository.dart';
import 'audience_widgets.dart';

/// "Opinión de tus compañeros" en el detalle de un proyecto propio: promedio
/// (desde el mínimo de votos) y comentarios de mejora, siempre anónimos.
class PeerFeedbackSection extends ConsumerWidget {
  const PeerFeedbackSection({
    super.key,
    required this.fairId,
    required this.projectId,
  });

  final String fairId;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final feedback =
        ref.watch(peerFeedbackProvider((fairId: fairId, projectId: projectId)));

    return feedback.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Text(
        'No pudimos cargar la opinión de tus compañeros. Desliza para reintentar.',
        style: theme.textTheme.bodyMedium,
      ),
      data: (data) {
        final average = data.average;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (average != null)
              Row(
                children: [
                  Text(
                    average.toStringAsFixed(1),
                    style: theme.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w800, height: 1),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MiniStars(value: average, size: 18),
                      Text('${data.votes} votos de compañeros',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              )
            else
              Text(
                data.votes == 0
                    ? 'Aún nadie calificó tu proyecto.'
                    : 'El promedio aparece desde ${data.minVotes} votos '
                        '(llevas ${data.votes}).',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.m),
            if (data.comments.isEmpty)
              Text('Aún no hay comentarios de mejora.',
                  style: theme.textTheme.bodySmall)
            else
              for (final comment in data.comments)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.s),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadii.rLarge,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PhosphorIconsFill.quotes,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                          child:
                              Text(comment, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}
