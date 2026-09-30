import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';

/// `/jury/fair/:fairId/declaration` — declaración de imparcialidad.
///
/// `POST /fairs/:fairId/jury/declaration` es `.strict()`: solo `statement`
/// (1–2000 caracteres). Solo se acepta con la feria OPEN y una vez por jurado
/// (el segundo intento responde 409).
class JuryDeclarationPage extends ConsumerWidget {
  const JuryDeclarationPage({super.key, required this.fairId});

  final String fairId;

  static const int maxLength = 2000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(declarationFormProvider(fairId));
    final controller = ref.read(declarationFormProvider(fairId).notifier);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Declaración de jurado'),
      body: state.loading
          ? const AppLoader()
          : _Body(state: state, controller: controller),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.state, required this.controller});

  final DeclarationFormState state;
  final DeclarationFormController controller;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final TextEditingController _text =
      TextEditingController(text: widget.state.statement);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;
    final controller = widget.controller;

    if (state.signed && state.status?.declaration != null) {
      final declaration = state.status!.declaration!;
      return PageScrollBody(
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusChip(
                label: 'Declaración firmada',
                tone: AppTone.success,
                icon: Icons.verified_rounded,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                declaration.statement,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              if (declaration.signedAt != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Registrada el ${declaration.signedAt!.toLocal()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appMuted(isDark),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                'Declara tu imparcialidad antes de evaluar los proyectos de esta '
                'feria. Queda registrada con tu usuario y la fecha.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.l),
              if (state.errorMessage != null) ...[
                NoticeBanner(
                  message: state.errorMessage!,
                  tone: AppTone.danger,
                  liveRegion: true,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              AppTextField(
                label: 'Declaración',
                hint: 'Declaro que no tengo conflicto de interés con los '
                    'proyectos de esta feria…',
                controller: _text,
                maxLines: 8,
                maxLength: JuryDeclarationPage.maxLength,
                enabled: !state.submitting,
                onChanged: controller.updateStatement,
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppButton(
              label: 'Firmar declaración',
              onPressed: state.canSubmit ? () => controller.submit() : null,
              isLoading: state.submitting,
            ),
          ),
        ),
      ],
    );
  }
}
