import 'package:flutter/material.dart';

import '../../../../core/widgets/app_status_chip.dart';

/// Estado del proyecto dentro de la feria (`APPROVED`, `SUBMITTED`, …).
///
/// Traduce el código del backend a la etiqueta en español y al tono del sistema;
/// el chip y sus colores son los de [StatusChip], así que el estado se lee igual
/// en toda la app y en modo oscuro.
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (status.toUpperCase()) {
      'APPROVED' => ('Aprobado', AppTone.success),
      'SUBMITTED' => ('En revisión', AppTone.warning),
      'IN_REVIEW' => ('En revisión', AppTone.warning),
      'REJECTED' => ('Rechazado', AppTone.danger),
      _ => (status, AppTone.neutral),
    };

    return StatusChip(label: label, tone: tone, showDot: true);
  }
}
