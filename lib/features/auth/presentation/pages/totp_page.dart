import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../state/auth_controller.dart';

class TotpPage extends ConsumerStatefulWidget {
  const TotpPage({super.key});

  @override
  ConsumerState<TotpPage> createState() => _TotpPageState();
}

class _TotpPageState extends ConsumerState<TotpPage> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_codeCtrl.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un código de 6 dígitos')),
      );
      return;
    }
    final ok = await ref
        .read(authControllerProvider.notifier)
        .verifyTotp(_codeCtrl.text);
    if (!mounted) return;
    if (ok) {
      // El destino sale del rol que devolvió el backend, no de una ruta fija.
      context
          .go(landingPathForRole(ref.read(authControllerProvider).user?.role));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación en dos pasos')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.l),
              const Icon(Icons.security_rounded,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Verificación 2FA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Ingresa el código de 6 dígitos de tu aplicación autenticadora.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 12,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(hintText: '000000'),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Verificar',
                icon: Icons.verified_outlined,
                isLoading: state.submitting,
                onPressed: state.submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
