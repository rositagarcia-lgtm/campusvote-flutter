import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../state/auth_controller.dart';
import '../state/auth_providers.dart';
import '../state/two_factor_controller.dart';
import '../widgets/account_summary_card.dart';
import '../widgets/disable_totp_dialog.dart';
import '../widgets/two_factor_card.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(twoFactorControllerProvider.notifier).load();
    });
  }

  Future<void> _onDisableTotp() async {
    final ok = await DisableTotpDialog.show(context);
    if (ok == null) return;
    final result = await ref.read(disableTotpUseCaseProvider)(
      password: ok.password,
      code: ok.code,
    );
    if (!mounted) return;
    result.when(
      success: (_) {
        ref.read(twoFactorControllerProvider.notifier).markDisabled();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA deshabilitado')),
        );
      },
      failure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
    );
  }

  Future<void> _onLogout() async {
    final confirm = await AppDialog.confirm(
      context,
      title: 'Cerrar sesión',
      message: '¿Estás seguro que deseas salir de CampusVote?',
      confirmLabel: 'Salir',
      destructive: true,
    );
    if (!confirm || !mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
    // Al selector de acceso: cualquier rol vuelve a elegir su panel.
    if (mounted) context.go('/splash');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final tf = ref.watch(twoFactorControllerProvider);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Seguridad'),
      body: SafeArea(
        child: PageScrollBody(
          maxWidth: kFormMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(label: 'Cuenta'),
              AccountHeaderCard(
                displayName: auth.user?.displayName ?? 'Usuario',
                email: auth.user?.email ?? '',
                avatarUrl: auth.user?.avatarUrl,
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(label: 'Contraseña'),
              PasswordCard(
                onPressed: () => context.push('/security/password'),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(label: 'Verificación en dos pasos'),
              TwoFactorCard(
                status: tf.status,
                loading: tf.loading,
                errorMessage: tf.errorMessage,
                onSetup: () => context.push('/security/totp/setup'),
                onDisable: _onDisableTotp,
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(label: 'Sesión'),
              SessionCard(onLogout: _onLogout),
            ],
          ),
        ),
      ),
    );
  }
}
