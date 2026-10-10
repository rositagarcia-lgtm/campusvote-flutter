// fair_project_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../../settings/presentation/settings_copy.dart';
import '../../../data/models/jury_models.dart';
import '../../widgets/project_status_chip.dart';

/// Tarjeta de proyecto: logo, nombre, descripción, metadatos y acción.
class FairProjectCard extends StatelessWidget {
  const FairProjectCard({
    super.key,
    required this.fairId,
    required this.project,
    this.evaluationSubmitted,
  });

  final String fairId;
  final FairProjectModel project;

  /// `null` mientras se cargan los estados: entonces no se muestra el chip, para
  /// no afirmar «Pendiente» sobre un dato que todavía no llegó.
  final bool? evaluationSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final muted = appMuted(isDark);
    final category = project.categoryName;
    final stand = project.standCode;
    final actionLabel = evaluationSubmitted == true
        ? 'Ver rúbrica registrada'
        : 'Evaluar con rúbrica';

    return Semantics(
      button: true,
      label: '${project.name}. ${SettingsCopy.of(context).t(actionLabel)}',
      child: AppCard(
        onTap: () =>
            context.push('/jury/fair/$fairId/project/${project.id}/rubric'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProjectLogo(
                    url: project.logoUrl, name: project.name, accent: accent),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                if (evaluationSubmitted != null)
                  StatusChip(
                    label: evaluationSubmitted! ? 'Evaluado' : 'Pendiente',
                    tone: evaluationSubmitted!
                        ? AppTone.primary
                        : AppTone.neutral,
                    icon: evaluationSubmitted!
                        ? PhosphorIconsRegular.checkCircle
                        : PhosphorIconsRegular.clock,
                  ),
                if (category != null)
                  _MetaChip(
                      icon: PhosphorIconsRegular.squaresFour, text: category),
                if (stand != null)
                  _MetaChip(icon: PhosphorIconsRegular.storefront, text: stand),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Divider(height: 1, thickness: 1, color: appBorder(isDark)),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: Text(
                    SettingsCopy.of(context).t(actionLabel),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(PhosphorIconsRegular.arrowRight,
                    size: AppDimensions.iconMedium, color: accent),
              ],
            ),
          ],
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

/// Dato secundario del proyecto (categoría, stand) con su ícono.
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - AppSpacing.xxl * 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSmall, color: muted),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
