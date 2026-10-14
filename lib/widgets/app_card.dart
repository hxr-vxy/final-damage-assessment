import 'package:flutter/material.dart';

/// Rounded surface used for all cards. An optional [accentColor] draws a
/// thin bar on the left edge (used to flag urgency).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contentPadding =
        accentColor == null ? padding : padding.copyWith(left: padding.left + 6);

    return Container(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(padding: contentPadding, child: child),
              if (accentColor != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 5, color: accentColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
