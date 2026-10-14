import 'package:flutter/material.dart';

/// Shared text-field styling (kept here instead of the global theme so it
/// works on every Flutter version).
InputDecoration appInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  IconData? icon,
  String? prefixText,
  String? helperText,
}) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helperText,
    prefixText: prefixText,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: isDark ? const Color(0xFF1C2B3B) : Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(cs.outlineVariant),
    enabledBorder: border(cs.outlineVariant),
    focusedBorder: border(cs.primary, 2),
    errorBorder: border(cs.error),
    focusedErrorBorder: border(cs.error, 2),
  );
}

/// Hides the "0/50" character counter on short fields (the limit still applies).
Widget? hideCounter(BuildContext context,
        {required int currentLength, required bool isFocused, required int? maxLength}) =>
    null;

/// Section heading with an icon, used inside forms.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                if (subtitle != null)
                  Text(subtitle!,
                      style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to show a floating SnackBar with an icon.
void showFeedback(BuildContext context, String message,
    {bool isError = false, IconData? icon}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20),
        content: Row(
          children: [
            Icon(icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
}
