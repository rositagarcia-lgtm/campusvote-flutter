import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_section_header.dart';
import '../data/published_results_repository.dart';
import '../domain/published_results.dart';

/// Desde la publicación, y 7 días después del cierre de la feria.
bool _resultsStillVisible(PublishedFair fair, DateTime now) {
  final published = fair.publishedAt?.toUtc();
  if (published == null || now.isBefore(published)) return false;
  final end = fair.endsAt?.toUtc();
  final anchor = end != null && end.isAfter(published) ? end : published;
  return now.isBefore(anchor.add(const Duration(days: 7)));
}

/// Ferias con resultados publicados. No ocupa espacio si no hay ninguna.
class PublishedResultsSection extends ConsumerStatefulWidget {
  const PublishedResultsSection({super.key});

  @override
  ConsumerState<PublishedResultsSection> createState() =>
      _PublishedResultsSectionState();
}

class _PublishedResultsSectionState
    extends ConsumerState<PublishedResultsSection> {
  Timer? _expiryRefresh;

  @override
  void initState() {
    super.initState();
    _expiryRefresh = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _expiryRefresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final fairs = (ref.watch(publishedFairsProvider).valueOrNull ?? const [])
        .where((fair) => _resultsStillVisible(fair, now))
        .toList();
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
