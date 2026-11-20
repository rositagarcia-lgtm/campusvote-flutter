// _thumb.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_dimensions.dart'
    show AppRadii;

/// Miniatura del proyecto (imagen o inicial).
class ProjectThumb extends StatelessWidget {
  const ProjectThumb({super.key, required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    final placeholder = Center(
      child: Text(
        initial,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final src = url;

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AppRadii.rMedium,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: (src == null || src.isEmpty)
          ? placeholder
          : Image.network(
              src,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}