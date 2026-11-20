import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../state/two_factor_controller.dart';
import '../../../../core/widgets/app_motion.dart';
import '../widgets/security/account_summary_card.dart';
import '../widgets/security/security_status.dart';
import '../widgets/security/two_factor_card.dart';
import '../../../settings/presentation/settings_copy.dart';

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

  @override
  Widget build(BuildContext context) {
    final tf = ref.watch(twoFactorControllerProvider);
    final text = SettingsCopy.of(context);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: text.t('Seguridad')),
      body: SafeArea(
        child: PageScrollBody(
          maxWidth: kFormMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMotion.reveal(
                0,
                SecurityStatusBanner(
                  level: SecurityLevel.of(
                    loading: tf.loading,
                    twoFactor: tf.status.enabled,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(label: text.t('Contraseña')),
              PasswordCard(
                onPressed: () => context.push('/security/password'),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(label: text.t('Verificación en dos pasos')),
              TwoFactorCard(
                status: tf.status,
                loading: tf.loading,
                errorMessage: tf.errorMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
