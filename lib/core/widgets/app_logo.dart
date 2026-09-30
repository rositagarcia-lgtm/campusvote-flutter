import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Logo oficial de CampusVote como asset local.
const kCampusVoteLogoAsset = 'assets/logo.png';

/// Identidad visual de la marca o de la organización.
///
/// Si no hay URL, o la imagen falla, cae a las iniciales sobre fondo tintado:
/// nunca queda un hueco.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.networkUrl,
    this.fallbackLabel = 'CV',
    this.size = 48,
    this.backgroundColor,
  });

  factory AppLogo.campusVote({Key? key, double size = 48}) {
    return AppLogo(
      key: key,
      fallbackLabel: 'CV',
      size: size,
    );
  }

  /// Logo institucional de CampusVote (asset local `assets/logo.png`).
  factory AppLogo.asset({
    Key? key,
    double size = 48,
    Color? backgroundColor,
  }) {
    return AppLogo(
      key: key,
      networkUrl: null,
      fallbackLabel: 'CV',
      size: size,
      backgroundColor: backgroundColor,
    );
  }

  factory AppLogo.organization({
    Key? key,
    String? logoUrl,
    required String organizationCode,
    double size = 48,
  }) {
    return AppLogo(
      key: key,
      networkUrl: logoUrl,
      fallbackLabel:
          organizationCode.isNotEmpty ? organizationCode[0].toUpperCase() : 'O',
      size: size,
    );
  }

  final String? networkUrl;
  final String fallbackLabel;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brand = backgroundColor ?? theme.colorScheme.primary;
    final code = fallbackLabel.trim();
    final initials =
        code.length <= 2 ? code.toUpperCase() : code[0].toUpperCase();

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: brand.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: AppRadii.rMedium,
        ),
        child: Image.network(
          networkUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _initials(context, brand, initials),
        ),
      );
    }

    if (fallbackLabel == 'CV') {
      // Prioriza el logo de marca por asset cuando no hay branding externo.
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          kCampusVoteLogoAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _initials(context, brand, initials),
        ),
      );
    }

    return _initials(context, brand, initials);
  }

  /// Placeholder con la inicial sobre fondo tintado y borde fino.
  Widget _initials(BuildContext context, Color brand, String initials) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: AppRadii.rMedium,
        border: Border.all(color: appBorder(isDark)),
      ),
      child: Text(
        initials,
        style: theme.textTheme.titleMedium?.copyWith(
          color: brand,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
