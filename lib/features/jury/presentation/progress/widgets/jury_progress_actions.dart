import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../jury_flow.dart';

/// Acciones de la pantalla.
///
/// Una sola acción dominante —la que corresponde al paso pendiente— y el resto
/// de accesos en botones secundarios. Cada destino aparece **una sola vez**: si
/// el paso pendiente es «votar», el botón principal es ese y no se repite como
/// secundario.
class JuryProgressActions extends StatelessWidget {
  const JuryProgressActions(
      {super.key, required this.flow, required this.onGoTo});

  final JuryFlow flow;
  final ValueChanged<JuryStageAction> onGoTo;

  static const _secondary = <JuryStageAction, ({String label, IconData icon})>{
    JuryStageAction.projects: (
      label: 'Proyectos',
      icon: Icons.folder_open_outlined,
    ),
    JuryStageAction.voting: (
      label: 'Votación',
      icon: Icons.how_to_vote_outlined,
    ),
    JuryStageAction.declaration: (
      label: 'Declaración',
      icon: Icons.draw_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final primary = flow.primaryAction;
    final secondaries =
        _secondary.entries.where((entry) => entry.key != primary).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (primary != null) ...[
          AppButton(
            label: flow.primaryLabel ?? '',
            icon: flow.primaryIcon,
            onPressed: () => onGoTo(primary),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final buttons = [
              for (final entry in secondaries)
                AppButton.outlined(
                  label: entry.value.label,
                  icon: entry.value.icon,
                  dense: true,
                  onPressed: () => onGoTo(entry.key),
                ),
            ];
            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < buttons.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.s),
                    buttons[i],
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.s),
                  Expanded(child: buttons[i]),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
