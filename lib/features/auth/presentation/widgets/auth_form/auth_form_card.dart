import 'package:flutter/material.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_motion.dart';
import '../../../../../core/widgets/app_palette.dart';

/// Superficie que agrupa únicamente los campos del acceso.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Tarjeta sin elevación de Material: sombra difusa y una franja fina del
    // color del acceso arriba, que liga el formulario con su cabecera.
    return AppMotion.reveal(
      2,
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadii.rLarge,
          border: Border.all(color: appBorder(isDark)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.0 : 0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: accent),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
