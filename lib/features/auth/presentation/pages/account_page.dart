import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_action_tile.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../domain/entities/auth_role.dart';
import '../state/auth_controller.dart';
import '../widgets/account_identity.dart';
import '../widgets/account_widgets.dart';

/// "Sobre mí": foto de perfil, datos de la cuenta y de la organización,
/// acceso a seguridad y cierre de sesión.
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final branding = ref.watch(brandingControllerProvider);
    final accent = context.brandPrimary;

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Sobre mí',
        actions: [
          IconButton(
            tooltip: 'Seguridad',
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => context.push('/security'),
          ),
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
                displayName: user?.displayName ?? 'Usuario',
                email: user?.email ?? '',
                roleLabel: AuthRole.label(user?.role),
                uploading: auth.submitting,
                onPickPhoto: _pickPhoto,
              ),
              const SizedBox(height: AppSpacing.xl),
              AccountSection(
                overline: 'Institución',
                child: AccountOrganizationRow(branding: branding),
              ),
              const SizedBox(height: AppSpacing.xl),
              AccountSection(
                overline: 'Tu cuenta',
                count: 3,
                child: AccountInfoList(
                  name: user?.displayName ?? '—',
                  email: user?.email ?? '—',
                  role: AuthRole.label(user?.role),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ActionTile(
                accent: accent,
                icon: Icons.lock_outline_rounded,
                title: 'Seguridad y contraseña',
                subtitle: 'Gestiona tu acceso y protege tu cuenta',
                onTap: () => context.push('/security'),
              ),
              const SizedBox(height: AppSpacing.m),
              AppButton.danger(
                label: 'Cerrar sesión',
                icon: Icons.logout_rounded,
                onPressed: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await AppDialog.confirm(
      context,
      title: 'Cerrar sesión',
      message: '¿Seguro que quieres salir de la aplicación?',
      confirmLabel: 'Salir',
      destructive: true,
    );
    if (confirm != true || !mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) context.go('/splash');
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
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Cancelar'),
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
      _toast('No se pudo abrir la cámara o galería');
      return;
    }
    if (picked == null) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .changeAvatar(File(picked.path));
    if (!mounted) return;
    _toast(ok ? 'Foto de perfil actualizada' : 'No se pudo actualizar la foto');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
