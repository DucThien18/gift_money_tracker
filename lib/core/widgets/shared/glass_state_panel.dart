import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import 'glass_panel.dart';

class GlassStatePanel extends StatelessWidget {
  const GlassStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.primary,
    this.actions = const <Widget>[],
    this.centered = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final List<Widget> actions;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment crossAxisAlignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final TextAlign textAlign = centered ? TextAlign.center : TextAlign.start;

    return GlassPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: textAlign,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: textAlign,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: centered ? WrapAlignment.center : WrapAlignment.start,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

class GlassStateView extends StatelessWidget {
  const GlassStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.primary,
    this.actions = const <Widget>[],
  });

  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GlassStatePanel(
            icon: icon,
            title: title,
            message: message,
            iconColor: iconColor,
            actions: actions,
            centered: true,
          ),
        ),
      ),
    );
  }
}
