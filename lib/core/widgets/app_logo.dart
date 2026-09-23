import 'package:flutter/material.dart';


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
    final bg = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final code = fallbackLabel.trim();
    final initials = code.length <= 2 ? code.toUpperCase() : code[0].toUpperCase();

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