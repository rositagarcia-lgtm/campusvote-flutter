import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_motion.dart';
import '../../jury/data/models/jury_models.dart';

const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', //
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _day(DateTime? date) {
  if (date == null) return 'próximamente';
  final local = date.toLocal();
  return 'el ${local.day} de ${_months[local.month - 1]}';
}

/// Rol de jurado del docente según el momento de cada feria asignada.
///
/// * Abierta: tarjeta destacada con "Entrar como jurado".
/// * Por abrir: aviso con la fecha.
/// * Cerradas: acceso al historial (solo consulta).
/// * Sin asignaciones: aviso discreto.
///
/// Es la misma cuenta: el backend autoriza por la asignación a la feria.
class JuryModeCard extends StatelessWidget {
  const JuryModeCard({super.key, required this.fairs, this.loading = false});

  final List<FairAssignmentModel> fairs;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final open = fairs.where((f) => f.isOpen).toList();
    final upcoming = fairs.where((f) => f.status == FairStatus.draft).toList();
    final closed = fairs.where((f) => f.isClosed).toList();

    if (open.isNotEmpty) {
      return _ActiveJury(fairs: open);
    }
    final (title, subtitle, enabled) = loading
        ? ('Jurado de ferias', 'Consultando tus asignaciones…', false)
        : upcoming.isNotEmpty
            ? (
                'Serás jurado',
                '${upcoming.first.name} · ${_day(upcoming.first.startsAt)}. '
                    'El acceso se habilita cuando la feria abra.',
                true,
              )
            : closed.isNotEmpty
                ? (
                    'Historial de jurado',
                    '${closed.length} feria${closed.length == 1 ? '' : 's'} '
                        'terminada${closed.length == 1 ? '' : 's'}. Consulta lo que calificaste.',
                    true,
                  )
                : (
                    'Jurado de ferias',
                    'No tienes ferias asignadas. Si la organización te elige '
                        'como jurado, aparecerán aquí.',
                    false,
                  );
    return _QuietCard(
      icon: upcoming.isNotEmpty
          ? PhosphorIconsRegular.calendarDots
          : PhosphorIconsRegular.gavel,
      title: title,
      subtitle: subtitle,
      onTap: enabled ? () => context.go('/jury') : null,
    );
  }
}

/// Feria abierta: el docente pasa a modo jurado con un toque.
class _ActiveJury extends StatelessWidget {
  const _ActiveJury({required this.fairs});

  final List<FairAssignmentModel> fairs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final single = fairs.length == 1;
    return Container(
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
              const Icon(PhosphorIconsFill.gavel,
                  size: 16, color: AppColors.juryAccessInk),
              const SizedBox(width: AppSpacing.s),
              Text(
                'HOY ERES JURADO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.juryAccessInk,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            single ? fairs.first.name : '${fairs.length} ferias abiertas',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Califica los proyectos de tus categorías y emite tu voto. No '
            'verás los proyectos que asesoras.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            label: 'Entrar como jurado',
            icon: PhosphorIconsRegular.gavel,
            backgroundColor: AppColors.juryAccessInk,
            foregroundColor: AppColors.inkInverse,
            onPressed: () => context
                .go(single ? '/jury/fair/${fairs.first.fairId}' : '/jury'),
          ),
        ],
      ),
    );
  }
}

class _QuietCard extends StatelessWidget {
  const _QuietCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    return Semantics(
      button: enabled,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: enabled ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (enabled)
                Icon(PhosphorIconsRegular.caretRight,
                    color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
