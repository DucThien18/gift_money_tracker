import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class GlassTokens {
  static const double blurSigma = 12;
  static const double borderRadius = 20;
  static const double borderWidth = 1;
  static const EdgeInsets contentPadding = EdgeInsets.all(16);

  static const List<Color> overlayGradientColors = <Color>[
    Color.fromRGBO(255, 255, 255, 0.18),
    Color.fromRGBO(255, 255, 255, 0.06),
  ];

  static const List<double> overlayGradientStops = <double>[0.0, 1.0];

  static ImageFilter backdropFilter() {
    return ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);
  }
}
