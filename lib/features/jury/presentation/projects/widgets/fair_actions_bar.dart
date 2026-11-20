// fair_actions_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_button.dart';
import 'package:campusvote_flutter/core/widgets/app_notice.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show CategoryRubricProgress;
import 'package:campusvote_flutter/features/jury/presentation/providers/fairs/jury_fair_providers.dart'
    show categoryRubricProgressProvider;

/// Accesos a progreso y votación oficial.
///
/// Viven aquí, con etiqueta visible, en lugar de ser iconos sueltos en la barra
/// superior: en pantallas estrechas el texto es lo que explica la acción.
class FairActionsBar extends ConsumerWidget {
  const FairActionsBar({super.key, required this.fairId, this.locked = false});

  final String fairId;

  /// Sin declaración firmada tampoco se vota.
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = SettingsCopy.of(context);
    final progressAsync = ref.watch(categoryRubricProgressProvider(fairId));

    return progressAsync.when(
      loading: () => _LoadingActionsBar(copy: copy, fairId: fairId),
      error: (_, __) => _ErrorActionsBar(
        copy: copy,
        fairId: fairId,
        locked: locked,
        onRetry: () => ref.invalidate(categoryRubricProgressProvider(fairId)),
      ),
      data: (categoryProgress) => _ActionsBarContent(
        copy: copy,
        fairId: fairId,
        locked: locked,
        categoryProgress: categoryProgress,
      ),
    );
  }
}

class _LoadingActionsBar extends StatelessWidget {
  const _LoadingActionsBar({required this.copy, required this.fairId});

  final SettingsCopy copy;
  final String fairId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton.outlined(
          label: copy.t('Mi progreso'),
          icon: PhosphorIconsRegular.listChecks,
          dense: true,
          onPressed: () => context.push('/jury/fair/$fairId/progress'),
        ),
        const SizedBox(height: AppSpacing.s),
        AppButton(
          label: copy.t('Verificando rúbricas...'),
          icon: PhosphorIconsRegular.arrowClockwise,
          dense: true,
          onPressed: null,
        ),
      ],
    );
  }
}

class _ErrorActionsBar extends StatelessWidget {
  const _ErrorActionsBar({
    required this.copy,
    required this.fairId,
    required this.locked,
    required this.onRetry,
  });

  final SettingsCopy copy;
  final String fairId;
  final bool locked;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton.outlined(
          label: copy.t('Mi progreso'),
          icon: PhosphorIconsRegular.listChecks,
          dense: true,
          onPressed: () => context.push('/jury/fair/$fairId/progress'),
        ),
        const SizedBox(height: AppSpacing.s),
        if (locked) ...[
          AppButton(
            label: copy.t('Votación (firma primero)'),
            icon: PhosphorIconsRegular.lockSimple,
            dense: true,
            onPressed: null,
          ),
        ] else ...[
          AppButton.outlined(
            label: copy.t('No se pudo verificar rúbricas'),
            icon: PhosphorIconsRegular.warning,
            dense: true,
            onPressed: onRetry,
          ),
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: copy.t('Votación oficial'),
            icon: PhosphorIconsRegular.checkSquareOffset,
            dense: true,
            onPressed: null,
          ),
        ],
      ],
    );
  }
}

class _ActionsBarContent extends StatelessWidget {
  const _ActionsBarContent({
    required this.copy,
    required this.fairId,
    required this.locked,
    required this.categoryProgress,
  });

  final SettingsCopy copy;
  final String fairId;
  final bool locked;
  final Map<String, CategoryRubricProgress> categoryProgress;

  @override
  Widget build(BuildContext context) {
    final progressBtn = AppButton.outlined(
      label: copy.t('Mi progreso'),
      icon: PhosphorIconsRegular.listChecks,
      dense: true,
      onPressed: () => context.push('/jury/fair/$fairId/progress'),
    );

    // Determinar si hay alguna categoría con rúbricas pendientes
    final hasAnyPending = categoryProgress.values.any((p) => !p.allSubmitted);
    final pendingCategories = categoryProgress.entries
        .where((e) => !e.value.allSubmitted)
        .map((e) => e.value)
        .toList();

    String voteLabel;
    IconData voteIcon;
    VoidCallback? voteOnPressed;

    if (locked) {
      voteLabel = copy.t('Votación (firma primero)');
      voteIcon = PhosphorIconsRegular.lockSimple;
      voteOnPressed = null;
    } else if (hasAnyPending) {
      final totalPending = pendingCategories.fold<int>(0, (sum, p) => sum + p.pendingCount);
      voteLabel = copy.t('Completa $totalPending rúbrica(s) para votar');
      voteIcon = PhosphorIconsRegular.lockSimple;
      voteOnPressed = null;
    } else {
      voteLabel = copy.t('Votación oficial');
      voteIcon = PhosphorIconsRegular.checkSquareOffset;
      voteOnPressed = () => context.push('/jury/fair/$fairId/vote');
    }

    final voteBtn = AppButton(
      label: voteLabel,
      icon: voteIcon,
      dense: true,
      onPressed: voteOnPressed,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              voteBtn,
              const SizedBox(height: AppSpacing.s),
              progressBtn,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: progressBtn),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: voteBtn),
          ],
        );
      },
    );
  }
}