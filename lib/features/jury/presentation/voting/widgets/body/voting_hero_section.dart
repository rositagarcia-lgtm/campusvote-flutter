// voting_hero_section.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/core/widgets/app_status_chip.dart'
    show AppTone, StatusChip;
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart'
    show VotingStatusModel;

/// Hero de la pantalla de votación con info de la feria y estado.
class VotingHero extends StatelessWidget {
  const VotingHero({
    super.key,
    required this.fairName,
    required this.status,
  });

  final String? fairName;
  final VotingStatusModel status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.t('VOTACIÓN OFICIAL'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    fairName == null || fairName!.isEmpty
                        ? Text(
                            copy.t('Feria asignada'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          )
                        : Text(
                            fairName!,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                  ],
                ),
              ),
              StatusChip(
                label: status.isOpen
                    ? (status.windowOpen
                        ? copy.t('Abierta')
                        : status.notStarted
                            ? copy.t('Próximamente')
                            : copy.t('Finalizada'))
                    : copy.t('Cerrada'),
                tone: status.isOpen && status.windowOpen
                    ? AppTone.success
                    : AppTone.warning,
                icon: status.isOpen && status.windowOpen
                    ? PhosphorIconsFill.radioButton
                    : PhosphorIconsRegular.lockSimple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}