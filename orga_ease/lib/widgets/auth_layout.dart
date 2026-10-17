import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/widgets/auth_components.dart';

// Layout web-standard: background full + card 400-420px di tengah.
class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget form;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryPink, AppColors.primaryTeal],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -80, right: -60,
              child: _dot(220, 0.15)),
            Positioned(top: 120, left: -70,
              child: _dot(180, 0.12)),
            Positioned(bottom: -70, left: 40,
              child: _dot(200, 0.10)),
            Positioned(bottom: 120, right: 50,
              child: _dot(44, 0.22)),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 580, vertical: 32),
                  child: ConstrainedBox(
                    constraints:
                      const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                  .withValues(alpha: 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 32,
                            color: AppColors.primaryPink),
                        ),
                        const SizedBox(height: 14),
                        Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white
                              .withValues(alpha: 0.92))),
                        const SizedBox(height: 24),
                        AuthCard(child: form),
                        const SizedBox(height: 16),
                        Text('© 2026 OrgaEase',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white
                              .withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(double s, double o) {
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: o),
        shape: BoxShape.circle,
      ),
    );
  }
}
