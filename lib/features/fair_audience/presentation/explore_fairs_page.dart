import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/branding_controller.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/organization_panel_app_bar.dart';
import '../../notifications/presentation/widgets/notifications_bell.dart';
import '../../fair_results/presentation/published_results_section.dart';
import '../data/fair_audience_repository.dart';
import '../domain/audience_models.dart';

/// `/teaching/explore` — ferias de la organización para que el alumno
/// conozca los proyectos, los califique y deje comentarios de mejora.
class ExploreFairsPage extends ConsumerWidget {
  const ExploreFairsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(audienceFairsProvider);
    final branding = ref.watch(brandingControllerProvider);
    Future<void> reload() => ref.refresh(audienceFairsProvider.future);

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Explorar ferias',
        actions: const [NotificationsBell()],
      ),
      body: RefreshIndicator(
        onRefresh: reload,
        child: fairs.when(
          loading: () => const AppLoader(),
          error: (error, _) => AppErrorView(
            message: mapExceptionToFailure(error).message,
            onRetry: reload,
          ),
          data: (items) => items.isEmpty
              ? LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: const AppEmptyView(
                        icon: PhosphorIconsRegular.storefront,
                        overline: 'FERIAS',
                        title: 'No hay ferias abiertas',
                        message:
                            'Cuando tu institución abra una feria, aquí podrás '
                            'conocer los proyectos y darles tu opinión.',
                      ),
                    ),
                  ),
                )
              : _FairList(fairs: items),
        ),
      ),
      bottomNavigationBar:
          const AppBottomNav(current: AppNavDestination.explore),
    );
  }
}

class _FairList extends StatelessWidget {
  const _FairList({required this.fairs});

  final List<AudienceFair> fairs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(
          'Conoce los proyectos de tus compañeros, califícalos y déjales '
          'ideas para mejorar. Tu voto no cuenta para la nota del jurado.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.m),
        const PublishedResultsSection(),
        // En la feria: el QR del stand abre ese proyecto directo.
        if (fairs.any((f) => f.isOpen)) ...[
          AppButton(
            label: 'Escanear QR del stand',
            icon: PhosphorIconsRegular.qrCode,
            onPressed: () => context.push('/scan'),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        for (var i = 0; i < fairs.length; i++)
          AppMotion.reveal(i, _FairCard(fair: fairs[i])),
      ],
    );
  }
}

class _FairCard extends StatelessWidget {
  const _FairCard({required this.fair});

  final AudienceFair fair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final day = fair.startsAt;
    final meta = [
      if (day != null) '${day.day}/${day.month}/${day.year}',
      if (fair.site != null) fair.site!,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Pressable(
        onTap: () => context.go('/teaching/explore/${fair.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(
              color: fair.isOpen ? scheme.primary : scheme.outlineVariant,
              width: fair.isOpen ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                fair.isOpen
                    ? PhosphorIconsFill.storefront
                    : PhosphorIconsRegular.archive,
                color: fair.isOpen ? scheme.primary : scheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fair.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    if (meta.isNotEmpty)
                      Text(meta, style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    StatusChip(
                      label: fair.isOpen ? 'Abierta: puedes opinar' : 'Cerrada',
                      tone: fair.isOpen ? AppTone.success : AppTone.neutral,
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIconsRegular.caretRight,
                  color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
