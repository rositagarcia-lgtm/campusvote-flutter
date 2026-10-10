import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../../data/student_projects_repository.dart';
import 'project_visuals.dart';

/// Acceso a "Mis proyectos" desde el inicio del alumno. No ocupa espacio
/// para quien no participa en ninguna feria.
class StudentProjectsShortcut extends ConsumerWidget {
  const StudentProjectsShortcut({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(studentProjectsProvider).valueOrNull;
    if (projects == null || projects.isEmpty) return const SizedBox.shrink();

    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final live = projects.where((p) => p.stage == ProjectStage.live).length;
    final subtitle = live > 0
        ? text.t('Tu proyecto está en feria ahora')
        : text.t('Revisa el estado y la valoración del jurado');

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: AppMotion.reveal(
        1,
        Pressable(
          onTap: () => context.go('/teaching/projects'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.08),
                scheme.surface,
              ),
              borderRadius: AppRadii.rLarge,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: context.brandGradient,
                    borderRadius: AppRadii.rMedium,
                  ),
                  child: Icon(
                    PhosphorIconsFill.storefront,
                    color: BrandContrast.onColor(scheme.primary),
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${text.t('Mis proyectos')} · ${projects.length}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsBold.arrowRight,
                  size: 18,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
