import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// The official Damage Assessment System logo, shown unmodified with its
/// original proportions. It is designed for dark-blue surfaces, so always
/// place it on a navy panel (splash, headers, login).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      logoAsset,
      width: width,
      height: width, // the asset is square, so proportions are preserved
      fit: BoxFit.contain,
      cacheWidth: 800,
      semanticLabel: 'Damage Assessment System logo',
    );
  }
}

/// Compact version for app bars: shows only the round emblem of the same
/// logo (cropped for display, not stretched or redrawn).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRect(
          child: Align(
            alignment: const Alignment(-0.0455, -0.409),
            widthFactor: 0.56,
            heightFactor: 0.56,
            child: Image.asset(
              logoAsset,
              width: 1000,
              height: 1000,
              cacheWidth: 800,
              semanticLabel: 'Damage Assessment System logo',
            ),
          ),
        ),
      ),
    );
  }
}
