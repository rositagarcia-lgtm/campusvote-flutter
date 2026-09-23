import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../domain/entities/election.dart';

class ElectionStatusBadge extends StatelessWidget {
  final Election election;
  const ElectionStatusBadge({super.key, required this.election});

  @override
  Widget build(BuildContext context) {
    final e = election;
    if (e.isOpen) {
      return const AppBadge(
        label: 'Activa',
        icon: Icons.bolt_rounded,
        background: AppColors.successSoft,
        foreground: AppColors.success,
      );
    }
    if (e.isUpcoming) {
      return const AppBadge(
        label: 'Próxima',
        icon: Icons.schedule_rounded,
        background: AppColors.infoSoft,
        foreground: AppColors.info,
      );
    }
    return const AppBadge(
      label: 'Cerrada',
      icon: Icons.lock_rounded,
      background: Color(0xFFEAEAF2),
      foreground: AppColors.inkMuted,
    );
  }
}