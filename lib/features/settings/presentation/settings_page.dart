// settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_page_layout.dart';
import '../../auth/presentation/state/auth_controller.dart';
import 'sections/settings_appearance_section.dart';
import 'sections/settings_language_section.dart';
import 'sections/settings_notifications_section.dart';
import 'sections/settings_organization_header.dart';
import 'settings_copy.dart';

/// Configuración: identidad de la organización, apariencia e idioma.
///
/// Cada control escribe una preferencia real y persistente
/// (`appPreferencesProvider`); no hay filas decorativas que no hagan nada.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: text.title,
        // Solo si hay a dónde volver: como ruta raíz no debe offercer un
        // botón que no hace nada.
        leading: navigator.canPop()
            ? IconButton(
                tooltip: text.back,
                onPressed: navigator.maybePop,
                icon: const Icon(PhosphorIconsRegular.arrowLeft),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator.adaptive(
          onRefresh: () =>
              ref.read(authControllerProvider.notifier).refreshBranding(),
          child: const PageScrollBody(
            physics: AlwaysScrollableScrollPhysics(),
            maxWidth: kListMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsOrganizationHeader(),
                SizedBox(height: AppSpacing.xl),
                SettingsAppearanceSection(),
                SizedBox(height: AppSpacing.xl),
                SettingsLanguageSection(),
                SizedBox(height: AppSpacing.xl),
                SettingsNotificationsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
