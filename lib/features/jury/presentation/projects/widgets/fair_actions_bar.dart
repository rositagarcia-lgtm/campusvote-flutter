// fair_actions_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';

/// Accesos a progreso y votación oficial.
///
/// Viven aquí, con etiqueta visible, en lugar de ser iconos sueltos en la barra
/// superior: en pantallas estrechas el texto es lo que explica la acción.
class FairActionsBar extends StatelessWidget {
  const FairActionsBar({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context) {
    final progress = AppButton.outlined(
      label: 'Mi progreso',
      icon: PhosphorIconsRegular.listChecks,
      dense: true,
      onPressed: () => context.push('/jury/fair/$fairId/progress'),
    );
    final vote = AppButton(
      label: 'Votación oficial',
      icon: PhosphorIconsRegular.checkSquareOffset,
      dense: true,
      onPressed: () => context.push('/jury/fair/$fairId/vote'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              vote,
              const SizedBox(height: AppSpacing.s),
              progress,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: progress),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: vote),
          ],
        );
      },
    );
  }
}
