import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../state/auth_controller.dart';
import 'security/account_identity.dart';

/// Foto de perfil en la barra superior: abre "Mi cuenta".
///
/// Reemplaza al antiguo botón de "actualizar": las pantallas se recargan
/// deslizando hacia abajo, y la barra muestra quién tiene la sesión abierta.
class AccountAvatarButton extends ConsumerWidget {
  const AccountAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final name = user?.displayName ?? '';
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Semantics(
        button: true,
        label: text.t('Mi cuenta'),
        child: InkResponse(
          radius: 24,
          onTap: () => context.go('/account'),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.brandPrimary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: AccountAvatar(
                    avatarUrl: user?.avatarUrl,
                    displayName: name,
                    accent: context.brandPrimary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
