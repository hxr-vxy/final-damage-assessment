import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand palette: light blue (primary) + light orange (accent) on neutral
/// surfaces. Red is reserved for critical urgency / destructive actions.
class AppColors {
  AppColors._();
  static const navy = Color(0xFF0A2350); // brand panels (matches the logo backdrop)
  static const navyLight = Color(0xFF123A7A);
  static const blue = Color(0xFF1E88E5); // primary light blue
  static const orange = Color(0xFFFF9F43); // accent light orange
  static const orangeDeep = Color(0xFFE8710A); // orange used for text/icons
  static const teal = Color(0xFF00897B);
  static const red = Color(0xFFC62828);
  static const green = Color(0xFF2E7D32);
  static const lightBackground = Color(0xFFF4F8FC);
  static const darkBackground = Color(0xFF0A1428);
  static const darkSurface = Color(0xFF12203A);
}

/// Font used across the whole app (bundled in assets/fonts).
const String appFont = 'Poppins';

/// Lightens a status/urgency color in dark mode so text stays readable.
Color tintFor(BuildContext context, Color base) {
  return Theme.of(context).brightness == Brightness.dark
      ? Color.lerp(base, Colors.white, 0.5)!
      : base;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF64B5F6) : AppColors.blue,
      onPrimary: isDark ? AppColors.navy : Colors.white,
      secondary: isDark ? const Color(0xFFFFB74D) : AppColors.orange,
      onSecondary: AppColors.navy,
      error: isDark ? const Color(0xFFEF9A9A) : AppColors.red,
      surface: isDark ? AppColors.darkSurface : Colors.white,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: appFont);
    final t = base.textTheme;

    // Typography hierarchy (one family, few sizes):
    //  headlineSmall  22 Bold    -> page / app title
    //  titleLarge     18 Medium  -> screen section header
    //  titleMedium    16 Medium  -> section title
    //  titleSmall     14 Medium  -> card titles, labels
    //  bodyLarge      16 Regular -> reading text
    //  bodyMedium     14 Regular -> body text
    //  bodySmall      12 Regular -> supporting text
    //  labelLarge     15 Medium  -> buttons
    //  labelMedium    12 Medium  -> badges
    final textTheme = t.copyWith(
      headlineMedium: t.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: t.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
      titleLarge: t.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      titleMedium: t.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: t.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45),
      bodySmall: t.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: t.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
      labelMedium: t.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0F1B33) : AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.primary.withOpacity(0.16),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withOpacity(0.18),
        height: 68,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
