part of '../project_visuals.dart';

class ProjectLogo extends StatelessWidget {
  const ProjectLogo({super.key, required this.project, this.size = 56});

  final StudentProject project;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = AppEnv.mediaUrl(project.logoUrl);
    final initials = project.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    final fallback = ColoredBox(
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: AppRadii.rMedium,
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

/// Banner de todas las fotos del proyecto. Con más de una, indica «2/8».
/// Al tocar una, se abre a pantalla completa y se puede ampliar.
