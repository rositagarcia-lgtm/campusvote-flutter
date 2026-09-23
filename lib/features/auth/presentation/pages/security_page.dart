import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_dialog.dart';
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
    if (ok != true) return;
    final result = await ref.read(disableTotpUseCaseProvider)(
      password: '',
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
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final tf = ref.watch(twoFactorControllerProvider);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Seguridad'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            AccountHeaderCard(
              displayName: auth.user?.displayName ?? 'Usuario',
              email: auth.user?.email ?? '',
            ),
            const SizedBox(height: AppSpacing.l),
            PasswordCard(
              onPressed: () => context.push('/security/password'),
            ),
            const SizedBox(height: AppSpacing.l),
            TwoFactorCard(
              status: tf.status,
              loading: tf.loading,
              errorMessage: tf.errorMessage,
              onSetup: () => context.push('/security/totp/setup'),
              onDisable: _onDisableTotp,
            ),
            const SizedBox(height: AppSpacing.l),
            SessionCard(onLogout: _onLogout),
          ],
        ),
      ),
    );
  }
}