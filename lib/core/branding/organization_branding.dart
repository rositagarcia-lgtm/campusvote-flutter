import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Abstracción de branding institucional.
///
/// El backend entrega `logo`, `primary_color`, `secondary_color` por
/// organización. Mientras esos campos no lleguen, se usa el fallback
/// `CampusVote` (teal + dorado).
class OrganizationBranding {
  final String id;
  final String name;
  final String? logoUrl;
  final Color primaryColor;
  final Color secondaryColor;

  const OrganizationBranding({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory OrganizationBranding.campusVoteFallback() {
    return const OrganizationBranding(
      id: 'campusvote',
      name: 'CampusVote',
      logoUrl: null,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.accent,
    );
  }

  /// Construye desde la respuesta de `GET /api/organizations/:id`.
  ///
  /// Campos esperados (con fallback seguro si faltan):
  /// `id`, `name`, `logo`, `primary_color`, `secondary_color`.
  ///
  /// `GET /api/organizations/:id` serializa el registro crudo de Prisma, así
  /// que devuelve `primaryColor` / `secondaryColor` en camelCase; el login sí
  /// devuelve `primary_color` / `secondary_color`. Se aceptan ambos.
  factory OrganizationBranding.fromOrganizationJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? 'campusvote').toString();
    final name = (json['name'] ?? 'CampusVote').toString();
    final logo = (json['logo'] as String?)?.trim();
    final primary =
        _tryParseHex(json['primary_color'] ?? json['primaryColor']) ??
            AppColors.primary;
    final secondary =
        _tryParseHex(json['secondary_color'] ?? json['secondaryColor']) ??
            AppColors.accent;
    return OrganizationBranding(
      id: id,
      name: name,
      logoUrl: (logo == null || logo.isEmpty) ? null : logo,
      primaryColor: primary,
      secondaryColor: secondary,
    );
  }

  /// Serializa con las mismas claves que acepta [fromOrganizationJson]; se
  /// usa para recordar la marca entre aperturas de la app.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo': logoUrl,
        'primary_color': _toHex(primaryColor),
        'secondary_color': _toHex(secondaryColor),
      };

  static String _toHex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Color? _tryParseHex(dynamic raw) {
    if (raw is! String) return null;
    final value = raw.replaceAll('#', '').trim();
    if (value.length != 6) return null;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(0xFF000000 | parsed);
  }

  OrganizationBranding copyWith({
    String? name,
    String? logoUrl,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return OrganizationBranding(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }
}
