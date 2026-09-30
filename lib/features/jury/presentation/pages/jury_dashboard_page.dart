import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/panel_hero.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/voting_countdown.dart';

/// `/jury` — dashboard de ferias asignadas (`GET /fairs/my-assignments`).
class JuryDashboardPage extends ConsumerWidget {
  const JuryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(juryDashboardProvider);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Panel del jurado',
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(juryDashboardProvider.notifier).reload(),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/splash');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(juryDashboardProvider.notifier).reload(),
        child: _bodyFor(context, ref, fairs),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

/// `AsyncValue` no es una jerarquía sellada, así que el caso por defecto se
/// trata explícitamente en vez de usar un switch exhaustivo.
Widget _bodyFor(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<List<FairAssignmentModel>> fairs,
) {
  switch (fairs) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: () => ref.read(juryDashboardProvider.notifier).reload(),
      );
    case AsyncData(:final value):
      if (value.isEmpty) {
        return const AppEmptyView(
          icon: Icons.event_busy_rounded,
          message: 'No tienes ferias asignadas por ahora.',
        );
      }
      return _FairsList(fairs: value);
    default:
      return const AppLoader();
  }
}

class _FairsList extends ConsumerWidget {
  const _FairsList({required this.fairs});

  final List<FairAssignmentModel> fairs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final open = fairs.where((f) => f.isOpen).toList(growable: false);
    final others = fairs.where((f) => !f.isOpen).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        PanelHero(
          title: 'Panel del jurado',
          subtitle: 'Evalúa proyectos y vota en tus ferias asignadas',
          icon: Icons.gavel_rounded,
          badge: open.isNotEmpty
              ? '${open.length} feria${open.length == 1 ? '' : 's'} abierta${open.length == 1 ? '' : 's'}'
              : 'Sin ferias abiertas',
          organizationLogoUrl: branding.logoUrl,
          organizationName: branding.name,
        ),
        const SizedBox(height: AppSpacing.l),
        if (open.isNotEmpty) ...[
          const _SectionLabel('Abiertas · evaluar y votar'),
          for (final fair in open) _FairCard(fair: fair),
        ],
        if (others.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          const _SectionLabel('Otras ferias'),
          for (final fair in others) _FairCard(fair: fair),
        ],
      ],
    );
  }
}

class _FairCard extends StatelessWidget {
  const _FairCard({required this.fair});

  final FairAssignmentModel fair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = fair.isOpen;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: () => context.push('/jury/fair/${fair.fairId}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fair.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (fair.siteName != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(fair.siteName!, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: AppSpacing.m),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    _Tag(
                      label: switch (fair.status) {
                        FairStatus.open => 'Abierta',
                        FairStatus.draft => 'En preparación',
                        FairStatus.closed => 'Cerrada',
                        FairStatus.unknown => 'Sin estado',
                      },
                      tone: enabled ? _TagTone.success : _TagTone.neutral,
                    ),
                    if (enabled)
                      const _Tag(
                          label: 'Votación y rúbrica', tone: _TagTone.info),
                  ],
                ),
                // `endsAt`/`startsAt` vienen de la asignación; si la feria no
                // trae fechas, el contador se oculta en vez de inventar una.
                if (enabled) ...[
                  const SizedBox(height: AppSpacing.m),
                  VotingCountdown(
                    startsAt: fair.startsAt,
                    endsAt: fair.endsAt,
                  ),
                ],
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Toca para ver los proyectos de tu categoría',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _TagTone { success, info, neutral }

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.tone});

  final String label;
  final _TagTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _TagTone.success => (Colors.green.shade50, Colors.green.shade800),
      _TagTone.info => (Colors.blue.shade50, Colors.blue.shade800),
      _TagTone.neutral => (Colors.grey.shade200, Colors.grey.shade800),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.rSmall),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
