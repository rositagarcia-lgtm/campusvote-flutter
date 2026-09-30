import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/branding/organization_branding.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/auth_role.dart';
import '../state/auth_controller.dart';

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
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            _IdentityCard(
              avatarUrl: user?.avatarUrl,
              displayName: user?.displayName ?? 'Usuario',
              email: user?.email ?? '',
              role: user?.role,
              uploading: auth.submitting,
              onPickPhoto: _pickPhoto,
            ),
            const SizedBox(height: AppSpacing.l),
            _OrganizationCard(branding: branding),
            const SizedBox(height: AppSpacing.l),
            _AccountInfoCard(
              name: user?.displayName ?? '—',
              email: user?.email ?? '—',
              role: AuthRole.label(user?.role),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.outlined(
              label: 'Seguridad y contraseña',
              icon: Icons.lock_outline_rounded,
              onPressed: () => context.push('/security'),
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

class _IdentityCard extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final String email;
  final String? role;
  final bool uploading;
  final VoidCallback onPickPhoto;

  const _IdentityCard({
    required this.avatarUrl,
    required this.displayName,
    required this.email,
    required this.role,
    required this.uploading,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = context.brandPrimary;

    return AppCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _Avatar(avatarUrl: avatarUrl, displayName: displayName, size: 96),
              if (uploading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onPickPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.colorScheme.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: AppDimensions.iconMedium,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            displayName,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(email,
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.m),
          OutlinedButton.icon(
            onPressed: uploading ? null : onPickPhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Cambiar foto'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double size;

  const _Avatar({
    required this.avatarUrl,
    required this.displayName,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : '?';
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            Color.lerp(theme.colorScheme.primary, Colors.black, 0.18)!,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );

    if (avatarUrl == null || avatarUrl!.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final OrganizationBranding branding;
  const _OrganizationCard({required this.branding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          AppLogo.organization(
            logoUrl: branding.logoUrl,
            organizationCode: branding.name,
            size: 44,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branding.name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('Organización de tu cuenta',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const _AccountInfoCard({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu cuenta',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.m),
          _Row(icon: Icons.badge_outlined, label: 'Nombre', value: name),
          _Row(icon: Icons.mail_outline_rounded, label: 'Correo', value: email),
          _Row(icon: Icons.shield_outlined, label: 'Rol', value: role),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMedium, color: AppColors.inkFaint),
          const SizedBox(width: AppSpacing.s),
          Text(label, style: theme.textTheme.bodySmall),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
