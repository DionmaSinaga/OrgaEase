import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/widgets/auth_components.dart';
import 'package:orga_ease/widgets/auth_doodle.dart';

part 'auth_layout_body.dart';

// Scrollbar dipin ke tepi kanan layar (full-width scroll).
class AuthLayout extends StatefulWidget {
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
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Referensi: #200659 -> #834DFB -> #E3D7FF.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.loginGradient,
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Tekstur abstrak: coretan kuning tipis, tidak ramai.
            const Positioned.fill(child: DoodleTexture()),
            Positioned(
              top: -90,
              right: -70,
              child: _glow(240, Colors.white.withValues(alpha: 0.14)),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: _glow(220,
                  AppColors.primaryColor.withValues(alpha: 0.28)),
            ),
            SafeArea(child: _layoutBody(context, _scrollCtrl, widget)),
          ],
        ),
      ),
    );
  }

  Widget _glow(double s, Color c) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}
