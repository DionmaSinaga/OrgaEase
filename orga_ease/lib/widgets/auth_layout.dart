import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/widgets/auth_components.dart';

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double w = constraints.maxWidth;
                  // Padding adaptif: menyusut saat jendela disempitkan.
                  // Rumus: sisakan minimal 12-16px di tiap sisi pada layar sempit,
                  // 24-32px pada layar lebar. TIDAK lagi fixed 580px.
                  final double hPad;
                  if (w < 360) {
                    hPad = 12;
                  } else if (w < 480) {
                    hPad = 16;
                  } else if (w < 800) {
                    hPad = 24;
                  } else {
                    hPad = 32;
                  }
                  final double titleSize = w < 360 ? 22 : 26;

                  // Scroll selebar layar -> scrollbar di tepi kanan.
                  // Padding horizontal pindah ke dalam (Padding),
                  // bukan di scrollview.
                  return Scrollbar(
                    controller: _scrollCtrl,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      padding:
                        const EdgeInsets.symmetric(vertical: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                          minWidth: constraints.maxWidth,
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: hPad),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 420),
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
                                    child: Icon(widget.icon, size: 32,
                                      color: AppColors.primaryPink),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(widget.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text(widget.subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.white
                                        .withValues(alpha: 0.92))),
                                  const SizedBox(height: 24),
                                  AuthCard(child: widget.form),
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
                    ),
                  );
                },
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

