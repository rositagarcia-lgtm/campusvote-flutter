import '../../../../core/theme/app_icons.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/organization_panel_app_bar.dart';
import '../../domain/entities/auth_role.dart';
import '../state/auth_controller.dart';
import '../widgets/security/account_identity.dart';
import '../state/two_factor_controller.dart';
import '../widgets/account_settings_group.dart';
import '../widgets/account_widgets.dart';
import '../widgets/security/security_status.dart';
import '../../../notifications/presentation/widgets/notifications_bell.dart';
import '../widgets/logout_flow.dart';
import '../../../../core/routing/role_landing.dart';
import '../../../settings/presentation/settings_copy.dart';

/// "Sobre mí": foto de perfil, datos de la cuenta y de la organización,
/// acceso a seguridad y cierre de sesión.
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  @override
  void initState() {
    super.initState();
    // El estado de la verificación en dos pasos alimenta el indicador de
    // protección de la lista de ajustes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(twoFactorControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final branding = ref.watch(brandingControllerProvider);
    final accent = context.brandPrimary;
    final text = SettingsCopy.of(context);
    final isJury = AuthRole.usesJuryPanel(user?.role);
    final twoFactor = ref.watch(twoFactorControllerProvider);
    final security = SecurityLevel.of(
      loading: twoFactor.loading,
      twoFactor: twoFactor.status.enabled,
    );

    // "Cuenta" es una pestaña: el botón atrás vuelve al panel del rol en vez
    // de cerrar la app, igual que en cualquier navegación por pestañas.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(landingPathForRole(user?.role));
      },
      child: Scaffold(
        appBar: OrganizationPanelAppBar(
          branding: branding,
          section: isJury ? text.t('Mi cuenta') : text.t('Sobre mí'),
          actions: [
            if (isJury) const NotificationsBell(),
          ],
        ),
        body: SafeArea(
          top: false,
          child: PageScrollBody(
            padding: const EdgeInsets.all(AppSpacing.l),
            maxWidth: kFormMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountIdentityHeader(
                  accent: accent,
                  avatarUrl: user?.avatarUrl,
                  displayName: user?.displayName ?? text.t('Usuario'),
                  email: user?.email ?? '',
                  roleLabel: text.t(AuthRole.label(user?.role)),
                  uploading: auth.submitting,
                  onPickPhoto: _pickPhoto,
                ),
                const SizedBox(height: AppSpacing.xl),
                AccountSection(
                  overline: text.t('Institución'),
                  child: AccountOrganizationRow(branding: branding),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(label: text.t('Ajustes')),
                AccountSettingsGroup(
                  items: [
                    AccountSettingsItem(
                      icon: PhosphorIconsRegular.shieldCheck,
                      title: text.t('Seguridad'),
                      subtitle: text.t(security.hint),
                      trailing: security == SecurityLevel.loading
                          ? null
                          : AccountStatusPill(
                              label: text.t(security == SecurityLevel.strong
                                  ? 'Protegida'
                                  : 'Básica'),
                              color: security.color,
                            ),
                      onTap: () => context.push('/security'),
                    ),
                    AccountSettingsItem(
                      icon: PhosphorIconsRegular.gear,
                      title: text.t('Preferencias'),
                      subtitle: text.t('Tema, idioma y tamaño de texto'),
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.danger(
                  label: text.t('Cerrar sesión'),
                  icon: PhosphorIconsRegular.signOut,
                  onPressed: () => confirmAndLogout(context, ref),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            const AppBottomNav(current: AppNavDestination.account),
      ),
    );
  }

  /// Cámara o galería, y subida inmediata al perfil.
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(PhosphorIconsRegular.camera),
              title: Text(SettingsCopy.of(sheetCtx).t('Tomar foto')),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.images),
              title: Text(SettingsCopy.of(sheetCtx).t('Elegir de la galería')),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.x),
              title: Text(SettingsCopy.of(sheetCtx).t('Cancelar')),
              onTap: () => Navigator.pop(sheetCtx),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      if (!mounted) return;
      _toast(
          SettingsCopy.of(context).t('No se pudo abrir la cámara o galería'));
      return;
    }
    if (picked == null) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .changeAvatar(File(picked.path));
    if (!mounted) return;
    final copy = SettingsCopy.of(context);
    if (ok) {
      _toast(copy.t('Foto de perfil actualizada'));
      return;
    }
    // El motivo real del servidor (formato, tamaño, URL rechazada) ayuda más
    // que un "no se pudo" genérico.
    final reason = ref.read(authControllerProvider).errorMessage;
    _toast(reason == null
        ? copy.t('No se pudo actualizar la foto')
        : '${copy.t('No se pudo actualizar la foto')}: ${copy.error(reason)}');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
