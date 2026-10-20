import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';

/// Tema terang & gelap OrgaEase.
/// Fondasi: primaryColor #834DFB, secondaryColor #FBD100,
/// darkPrimary #18102B, lightPrimary #F6F3FF.
class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightPrimary,
      primaryColor: AppColors.primaryColor,
      colorScheme: scheme.copyWith(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.lightCard,
        error: AppColors.error,
      ),
      cardColor: AppColors.lightCard,
      dividerColor: AppColors.lightBorder,
      hoverColor: AppColors.primaryColor.withValues(alpha: 0.06),
      splashColor: AppColors.primaryColor.withValues(alpha: 0.12),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered) ||
                s.contains(WidgetState.focused)) {
              return AppColors.primaryHover;
            }
            return AppColors.primaryColor;
          }),
          foregroundColor:
              const WidgetStatePropertyAll<Color>(Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered)) {
              return AppColors.primaryHover;
            }
            return AppColors.primaryColor;
          }),
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
        fillColor: WidgetStatePropertyAll<Color>(AppColors.primaryColor),
        checkColor: WidgetStatePropertyAll<Color>(Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide:
              BorderSide(color: AppColors.primaryColor, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.primaryColor.withValues(alpha: 0.85);
          }
          return AppColors.darkPrimary.withValues(alpha: 0.25);
        }),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkPrimary,
      primaryColor: AppColors.primaryColor,
      colorScheme: scheme.copyWith(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.darkCard,
        surfaceContainerHighest: AppColors.darkCardAlt,
        error: AppColors.error,
      ),
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkBorder,
      hoverColor: AppColors.primaryColor.withValues(alpha: 0.14),
      splashColor: AppColors.primaryColor.withValues(alpha: 0.20),
      appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkText),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered) ||
                s.contains(WidgetState.focused)) {
              return AppColors.primaryHoverDark;
            }
            return AppColors.primaryColor;
          }),
          foregroundColor:
              const WidgetStatePropertyAll<Color>(Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered)) {
              return AppColors.primaryHoverDark;
            }
            return AppColors.secondaryColor;
          }),
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
        fillColor: WidgetStatePropertyAll<Color>(AppColors.primaryColor),
        checkColor: WidgetStatePropertyAll<Color>(Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide:
              BorderSide(color: AppColors.primaryColor, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.secondaryColor;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.primaryColor.withValues(alpha: 0.65);
          }
          return Colors.white.withValues(alpha: 0.30);
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Helper kecil: true jika tema gelap sedang aktif.
bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
