import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/glass_tokens.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.fillColor = AppColors.glassFill,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(GlassTokens.borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: GlassTokens.backdropFilter(),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: fillColor,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.glassGradient,
            ),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
