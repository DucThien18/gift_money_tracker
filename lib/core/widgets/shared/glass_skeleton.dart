import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class GlassSkeleton extends StatelessWidget {
  const GlassSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
    this.margin = EdgeInsets.zero,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.textHint.withValues(alpha: 0.16),
            AppColors.textHint.withValues(alpha: 0.08),
          ],
        ),
      ),
    );
  }
}
