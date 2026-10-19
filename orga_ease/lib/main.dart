import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/core/app_window.dart';
import 'package:orga_ease/pages/login_page.dart';

void main() { runApp(const MyApp()); }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OrgaEase',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundWhite,
        primaryColor: AppColors.primaryPink,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryPink),
        useMaterial3: true,
      ),
      builder: (context, child) =>
          MinWindowGuard(child: child ?? const SizedBox.shrink()),
      home: const LoginPage(),
    );
  }
}

