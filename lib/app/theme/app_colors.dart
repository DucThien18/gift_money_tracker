import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF6366F1);

  static const Color backgroundTop = Color(0xFFF0F4FF);
  static const Color backgroundMiddle = Color(0xFFFAF5FF);
  static const Color backgroundBottom = Color(0xFFF0FDF4);
  static const Color background = backgroundTop;
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);
  static const Color pink = Color(0xFFEC4899);

  // Glass colors
  static const Color glassFill = Color.fromRGBO(255, 255, 255, 0.78);
  static const Color glassFillStrong = Color.fromRGBO(255, 255, 255, 0.92);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.72);
  static const Color accentTint = Color.fromRGBO(124, 58, 237, 0.1);
  static const Color accentBorder = Color.fromRGBO(124, 58, 237, 0.18);
  static const Color cardShadow = Color.fromRGBO(15, 23, 42, 0.08);
  static const Color fabShadow = Color.fromRGBO(124, 58, 237, 0.3);

  static const List<Color> glassGradient = <Color>[
    Color.fromRGBO(255, 255, 255, 0.92),
    Color.fromRGBO(255, 255, 255, 0.68),
  ];
}
