import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/app_button.dart';

/// Primer paso del jurado en una feria: firmar la declaración de
/// imparcialidad. Hasta entonces la rúbrica y el voto quedan bloqueados.
class DeclarationGate extends StatelessWidget {
  const DeclarationGate({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
              AppColors.juryAccess.withValues(alpha: 0.12), scheme.surface),
          borderRadius: AppRadii.rLarge,
          border: Border.all(color: AppColors.juryAccess, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(PhosphorIconsFill.signature,
                    color: AppColors.juryAccessInk),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    'PASO 1 · ANTES DE CALIFICAR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.juryAccessInk,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Firma tu declaración de imparcialidad',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Confirmas que no tienes conflictos de interés con los proyectos '
              'que evaluarás. Hasta firmarla, la rúbrica y la votación quedan '
              'bloqueadas.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              label: 'Firmar declaración',
              icon: PhosphorIconsRegular.signature,
              backgroundColor: AppColors.juryAccessInk,
              foregroundColor: AppColors.inkInverse,
              onPressed: () => context.push('/jury/fair/$fairId/declaration'),
            ),
          ],
        ),
      ),
    );
  }
}
