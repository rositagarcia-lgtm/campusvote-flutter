import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_section_header.dart';
import '../data/published_results_repository.dart';

/// Ferias con resultados publicados. No ocupa espacio si no hay ninguna.
class PublishedResultsSection extends ConsumerWidget {
  const PublishedResultsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(publishedFairsProvider).valueOrNull ?? const [];
    if (fairs.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            label: 'Resultados',
            title: 'Ganadores de las ferias',
            count: fairs.length,
          ),
          for (final fair in fairs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Pressable(
                onTap: () => context.push('/resultados/${fair.id}'),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.10),
                    borderRadius: AppRadii.rLarge,
                    border: Border.all(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsFill.trophy,
                          color: Color(0xFFD4A017), size: 28),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fair.name,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            Text('Mira el podio de cada categoría',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Icon(PhosphorIconsRegular.caretRight,
                          color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
