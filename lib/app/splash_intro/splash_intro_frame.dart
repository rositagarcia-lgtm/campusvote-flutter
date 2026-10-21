part of '../splash_intro_video.dart';

class IntroVideoFrame extends StatelessWidget {
  const IntroVideoFrame(
      {super.key, required this.aspectRatio, required this.child});

  final double aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio =
            aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1.0;
        final viewportRatio = constraints.maxHeight > 0
            ? constraints.maxWidth / constraints.maxHeight
            : ratio;
        final mismatch =
            (ratio - viewportRatio).abs() / math.max(ratio, viewportRatio);
        final adjustment = (mismatch / 0.25).clamp(0.0, 1.0).toDouble();
        final safeScale = 1.0 - 0.08 * adjustment;

        return ColoredBox(
          color: AppColors.darkBackground,
          child: ClipRect(
            child: Transform.scale(
              scale: safeScale,
              alignment: Alignment.center,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: constraints.maxHeight * ratio,
                    height: constraints.maxHeight,
                    child: AspectRatio(aspectRatio: ratio, child: child),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
