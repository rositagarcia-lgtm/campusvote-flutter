import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../data/models/jury_models.dart';
import 'project_status_chip.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Tarjeta de proyecto: logo, nombre, descripción, metadatos y acción.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.fairId, required this.project});

  final String fairId;
  final FairProjectModel project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final muted = appMuted(isDark);
    final category = project.categoryName;
    final stand = project.standCode;

    return Semantics(
      button: true,
      label:
          '${project.name}. ${SettingsCopy.of(context).t('Evaluar con rúbrica')}',
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: appBorder(isDark)),
        ),
        child: InkWell(
          onTap: () =>
              context.push('/jury/fair/$fairId/project/${project.id}/rubric'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProjectLogo(
                        url: project.logoUrl,
                        name: project.name,
                        accent: accent),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (project.description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              project.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: muted, height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ProjectStatusChip(status: project.status),
                    if (category != null)
                      _MetaChip(icon: Icons.category_outlined, text: category),
                    if (stand != null)
                      _MetaChip(icon: Icons.storefront_outlined, text: stand),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Divider(height: 1, thickness: 1, color: appBorder(isDark)),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        SettingsCopy.of(context).t('Evaluar con rúbrica'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        size: AppDimensions.iconMedium, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo del proyecto; si no hay o falla la carga, muestra la inicial.
class _ProjectLogo extends StatelessWidget {
  const _ProjectLogo({
    required this.url,
    required this.name,
    required this.accent,
  });

  final String? url;
  final String name;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    final placeholder = Center(
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: accent,
          fontFamily: 'serif',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final src = url;

    return Container(
      width: AppDimensions.touchTarget,
      height: AppDimensions.touchTarget,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: AppRadii.rMedium,
        border: Border.all(color: appBorder(isDark)),
      ),
      child: (src == null || src.isEmpty)
          ? placeholder
          : Image.network(
              src,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSmall, color: muted),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
      ],
    );
  }
}
