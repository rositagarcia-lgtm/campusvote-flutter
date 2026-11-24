import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../../../../core/widgets/translatable_text.dart';
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
    final copy = SettingsCopy.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;
    final controller = widget.controller;

    if (state.signed && state.status?.declaration != null) {
      final declaration = state.status!.declaration!;
      final primary = theme.colorScheme.primary;
      final success = appToneColors(AppTone.success, isDark: isDark);
      return PageScrollBody(
        maxWidth: kFormMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: success.bg,
                ),
                child: Icon(PhosphorIconsFill.sealCheck,
                    size: 48, color: success.fg),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l, vertical: AppSpacing.s),
                decoration: BoxDecoration(
                  color: success.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsFill.sealCheck,
                        size: AppDimensions.iconMedium, color: success.fg),
                    const SizedBox(width: AppSpacing.s),
                    Flexible(
                      child: Text(
                        copy.t('Declaración firmada'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: success.fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    copy.t('Tu declaración'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.10),
                          borderRadius: AppRadii.rLarge,
                        ),
                        child: Icon(PhosphorIconsRegular.fileText,
                            size: AppDimensions.iconLarge, color: primary),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy.t('Declaración'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TranslatableText(
                              declaration.statement,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (declaration.signedAt != null) ...[
                    const SizedBox(height: AppSpacing.l),
                    const Divider(),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.10),
                            borderRadius: AppRadii.rLarge,
                          ),
                          child: Icon(PhosphorIconsRegular.calendarBlank,
                              size: AppDimensions.iconLarge, color: primary),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                copy.isEnglish
                                    ? 'Registered on'
                                    : 'Registrada el',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                copy.formatDate(declaration.signedAt!),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: AppRadii.rLarge,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(PhosphorIconsFill.checkCircle,
                            size: AppDimensions.iconLarge, color: primary),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            copy.isEnglish
                                ? 'The declaration was recorded successfully.'
                                : 'La declaración se registró correctamente.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              ConstrainedContent(
                maxWidth: kListMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      copy.t('DECLARACIÓN DEL JURADO'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      copy.t('Imparcialidad y compromiso'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      copy.t(
                        'Declara tu imparcialidad antes de evaluar los proyectos de esta feria. Queda registrada con tu usuario y la fecha.',
                      ),
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
            ],
          ),
        ),
        ActionFooter(
          child: ConstrainedContent(
            maxWidth: kListMaxWidth,
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
