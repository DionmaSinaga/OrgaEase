import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';

/// Tema terang & gelap OrgaEase, selaras dengan palet baru di AppColors.
class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPink,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryPink,
      colorScheme: scheme.copyWith(
        primary: AppColors.primaryPink,
        secondary: AppColors.primaryTeal,
        surface: Colors.white,
        error: AppColors.error,
      ),
      cardColor: Colors.white,
      dividerColor: AppColors.lightBorder,
      hoverColor: AppColors.primaryPink.withValues(alpha: 0.06),
      splashColor: AppColors.primaryPink.withValues(alpha: 0.12),
      // Tombol aksi utama: pink -> pinkHover saat ditekan/hover.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered) ||
                s.contains(WidgetState.focused)) {
              return AppColors.pinkHover;
            }
            return AppColors.primaryPink;
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
              return AppColors.pinkHover;
            }
            return AppColors.primaryPink;
          }),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.primaryTeal;
          }
          return null;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.primaryTeal, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.lightText.withValues(alpha: 0.85);
          }
          return Colors.white.withValues(alpha: 0.45);
        }),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkPink,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPink,
      colorScheme: scheme.copyWith(
        primary: AppColors.darkPink,
        secondary: AppColors.darkTeal,
        surface: AppColors.darkCard,
        surfaceContainerHighest: AppColors.darkField,
        error: AppColors.error,
      ),
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkBorder,
      hoverColor: AppColors.darkPink.withValues(alpha: 0.10),
      splashColor: AppColors.darkPink.withValues(alpha: 0.16),
      appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkText),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered) ||
                s.contains(WidgetState.focused)) {
              return AppColors.darkPinkHover;
            }
            return AppColors.darkPink;
          }),
          // Teks gelap di atas pink lembut agar kontras.
          foregroundColor:
              const WidgetStatePropertyAll<Color>(AppColors.darkBackground),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed) ||
                s.contains(WidgetState.hovered)) {
              return AppColors.darkPinkHover;
            }
            return AppColors.darkPink;
          }),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.darkTeal;
          }
          return null;
        }),
        checkColor:
            const WidgetStatePropertyAll<Color>(AppColors.darkBackground),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.darkTeal, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.darkPink;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return Colors.white;
          return Colors.white.withValues(alpha: 0.35);
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

