import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color> gradientColors;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradientColors = const [
      AppColors.primaryColor, AppColors.primaryHover],
  });

  /// Gradien ungu utama (Masuk): primary -> hover, ikut tema.
  static List<Color> themeGradient(BuildContext context) =>
      AppColors.isDark(context)
          ? const [AppColors.primaryColor, AppColors.primaryHoverDark]
          : const [AppColors.primaryColor, AppColors.primaryHover];

  /// Gradien tombol Daftar: hover -> primary (kebalikan Masuk).
  static List<Color> themeTealGradient(BuildContext context) =>
      AppColors.isDark(context)
          ? const [AppColors.primaryHoverDark, AppColors.primaryColor]
          : const [AppColors.primaryHover, AppColors.primaryColor];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 53,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
              : Text(text, style: const TextStyle(
                  color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        // Padding card mengecil di layar sempit agar isi tidak terjepit.
        final double pad = w < 340 ? 16 : (w < 420 ? 20 : 24);
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow(context),
                blurRadius: 24, offset: const Offset(0, 10)),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

