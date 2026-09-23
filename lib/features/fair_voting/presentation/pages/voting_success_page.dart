import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';

/// Pantalla de éxito después de votar.
///
/// Refuerza el mensaje: voto anónimo, no editable.
class VotingSuccessPage extends ConsumerWidget {
  final String fairId;
  const VotingSuccessPage({super.key, required this.fairId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Voto registrado'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Tu voto fue registrado',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'El proceso de votación es anónimo. El backend almacena '
                'tu participación y tu voto, pero no los asocia con tu '
                'identidad en el resultado final.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Ya no puedes modificar ni emitir un nuevo voto.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkFaint,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: 'Volver al inicio',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/juries/fairs'),
              ),
              const SizedBox(height: AppSpacing.m),
              AppButton.outlined(
                label: 'Ver proyectos de la feria',
                onPressed: () => context.go('/juries/fairs/$fairId/projects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
