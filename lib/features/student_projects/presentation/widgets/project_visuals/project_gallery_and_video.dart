part of '../project_visuals.dart';

class ProjectGallery extends StatelessWidget {
  const ProjectGallery({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final resolved = [
      for (final url in urls)
        if (AppEnv.mediaUrl(url) case final src?) src,
    ];
    if (resolved.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resolved.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: AppRadii.rMedium,
          child: Image.network(
            resolved[index],
            width: 196,
            height: 148,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 196,
              height: 148,
              child: ColoredBox(color: Color(0x11000000)),
            ),
          ),
        ),
      ),
    );
  }
}
