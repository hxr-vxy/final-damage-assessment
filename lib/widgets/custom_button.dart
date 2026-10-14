import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ButtonKind { primary, success, danger, warning, outline, dangerOutline }

/// Consistent full-width button used across the app.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = ButtonKind.primary,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonKind kind;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onTap = loading ? null : onPressed;

    Color? bg;
    Color fg = Colors.white;
    Color? outline;
    switch (kind) {
      case ButtonKind.primary:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case ButtonKind.success:
        bg = AppColors.green;
        break;
      case ButtonKind.danger:
        bg = AppColors.red;
        break;
      case ButtonKind.warning:
        bg = AppColors.orange; // light-orange accent for primary call-to-action
        fg = AppColors.navy;
        break;
      case ButtonKind.outline:
        outline = cs.primary;
        break;
      case ButtonKind.dangerOutline:
        outline = tintFor(context, AppColors.red);
        break;
    }

    final spinnerColor = outline ?? fg;
    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: spinnerColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Flexible(
                child: Text(label, textAlign: TextAlign.center),
              ),
            ],
          );

    final Widget button = outline != null
        ? OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: outline,
              side: BorderSide(color: outline.withOpacity(0.7)),
            ),
            child: child,
          )
        : FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg),
            child: child,
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
