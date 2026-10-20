import 'package:flutter/material.dart';
import 'package:orga_ease/core/app_theme.dart';
import 'package:orga_ease/core/app_window.dart';
import 'package:orga_ease/core/theme_controller.dart';
import 'package:orga_ease/pages/login_page.dart';

void main() { runApp(const MyApp()); }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OrgaEase',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          builder: (context, child) =>
              MinWindowGuard(child: child ?? const SizedBox.shrink()),
          home: const LoginPage(),
        );
      },
    );
  }
}
