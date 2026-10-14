import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Icon inside a subtle rounded container. Used everywhere an icon needs
/// emphasis so size, shape and spacing stay consistent.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 40,
    this.circle = false,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final base = color ?? Theme.of(context).colorScheme.primary;
    final c = color == null ? base : tintFor(context, base);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size * 0.55, color: c),
    );
  }
}
