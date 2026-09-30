import 'package:flutter/material.dart';

/// Logo oficial de CampusVote como asset local.
const kCampusVoteLogoAsset = 'assets/logo.png';

class AppLogo extends StatelessWidget {
  final String? networkUrl;
  final String fallbackLabel;
  final double size;
  final Color? backgroundColor;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colorScheme.primary;
    final code = fallbackLabel.trim();
    final initials =
        code.length <= 2 ? code.toUpperCase() : code[0].toUpperCase();

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 4),
        ),
        child: Image.network(
          networkUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials(bg, initials),
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
          errorBuilder: (_, __, ___) => _initials(bg, initials),
        ),
      );
    }

    return _initials(bg, initials);
  }

  Widget _initials(Color bg, String initials) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(color: bg.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: bg,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
