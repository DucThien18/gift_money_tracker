import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.backgroundTop,
            AppColors.backgroundMiddle,
            AppColors.backgroundBottom,
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -120,
            left: -60,
            child: _Orb(size: 260, color: Color.fromRGBO(196, 181, 253, 0.34)),
          ),
          const Positioned(
            top: 80,
            right: -50,
            child: _Orb(size: 220, color: Color.fromRGBO(147, 197, 253, 0.24)),
          ),
          const Positioned(
            bottom: -60,
            right: 20,
            child: _Orb(size: 180, color: Color.fromRGBO(110, 231, 183, 0.24)),
          ),
          child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: color, blurRadius: 90, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}
