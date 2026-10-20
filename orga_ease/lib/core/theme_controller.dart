import 'package:flutter/material.dart';

/// Pengendali global untuk mode terang / gelap.
/// Dipakai oleh [ThemeModeSwitch] di top bar dan didengarkan oleh [MyApp].
class ThemeController {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => mode.value == ThemeMode.dark;

  static void toggle() {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  static void setDark(bool dark) {
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }
}
