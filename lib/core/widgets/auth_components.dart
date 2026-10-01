import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_card.dart';

/// Encabezado visual compartido para pantallas de autenticación.
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        leading ?? const Icon(Icons.school_rounded, size: 48),
        const SizedBox(height: AppSpacing.m),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(subtitle!, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

/// Tarjeta de formulario con superficie y espaciado institucionales.
class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => AppCard(child: child);
}

/// Banner accesible para errores de autenticación.
class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Error: $message',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkDangerSoft
              : AppColors.dangerSoft,
          borderRadius: AppRadii.rMedium,
        ),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.danger),
        ),
      ),
    );
  }
}

/// Nota informativa contextual para formularios de autenticación.
class AuthInfoNote extends StatelessWidget {
  final String message;

  const AuthInfoNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: AppDimensions.iconMedium,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: Text(message)),
      ],
    );
  }
}
