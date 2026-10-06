// settings_page.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_page_layout.dart';
import 'sections/settings_appearance_section.dart';
import 'sections/settings_language_section.dart';
import 'sections/settings_organization_header.dart';
import 'settings_copy.dart';

/// Configuración: identidad de la organización, apariencia e idioma.
///
/// Cada control escribe una preferencia real y persistente
/// (`appPreferencesProvider`); no hay filas decorativas que no hagan nada.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: const SafeArea(
        top: false,
        child: PageScrollBody(
          maxWidth: kListMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsOrganizationHeader(),
              SizedBox(height: AppSpacing.xl),
              SettingsAppearanceSection(),
              SizedBox(height: AppSpacing.xl),
              SettingsLanguageSection(),
            ],
          ),
        ),
      ),
    );
  }
}