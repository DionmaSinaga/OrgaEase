import 'package:flutter/material.dart';

class AppColors {
  // === Fondasi utama (milik Anda, jangan diubah nilainya) ===
  static const Color primaryColor = Color(0xFF834DFB);
  static const Color secondaryColor = Color(0xFFFBD100);
  static const Color darkPrimary = Color(0xFF18102B);
  static const Color lightPrimary = Color(0xFFF6F3FF);

  // === Turunan yang saya sesuaikan ke fondasi ===
  // Ungu akhir gradien login (lebih pekat dari primary).
  static const Color loginDeep = Color(0xFF200659);
  // Ungu muda akhir gradasi header/sidebar + gradien login.
  static const Color lavenderMist = Color(0xFFE3D7FF);
  // Hover ungu: lebih gelap (light) / lebih terang (dark).
  static const Color primaryHover = Color(0xFF6B31E8);
  static const Color primaryHoverDark = Color(0xFF9B6BFF);

  // Teks & ikon mengikuti tema.
  static const Color lightText = Color(0xFF221A3A);
  static const Color lightSubtext = Color(0xFF6B6390);
  static const Color lightBorder = Color(0xFFE2D9F7);
  static const Color darkText = Color(0xFFF1EBFF);
  static const Color darkSubtext = Color(0xFFB3A8D6);
  static const Color darkBorder = Color(0xFF342A55);

  // Permukaan kartu: terang = putih di atas lightPrimary,
  // gelap = darkPrimary yang sedikit diangkat agar beda dari bg.
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF221839);
  static const Color darkCardAlt = Color(0xFF2B1F47);

  // Fungsional
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF1C40F);
  static const Color error = Color(0xFFE74C3C);

  // --- Helper sadar-tema ---
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Aksen utama (ungu) — sama di kedua tema agar brand konsisten.
  static Color primary(BuildContext context) => primaryColor;

  static Color primaryHoverOf(BuildContext context) =>
      isDark(context) ? primaryHoverDark : primaryHover;

  /// Sorotan kuning — dipakai hemat: dot menu aktif, aksen kecil.
  static Color highlight(BuildContext context) => secondaryColor;

  /// Background halaman utama: lightPrimary / darkPrimary.
  static Color page(BuildContext context) =>
      isDark(context) ? darkPrimary : lightPrimary;

  static Color card(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color cardAlt(BuildContext context) =>
      isDark(context) ? darkCardAlt : const Color(0xFFEDE7FB);

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color ink(BuildContext context) =>
      isDark(context) ? darkText : lightText;

  static Color subInk(BuildContext context, [double alpha = 0.75]) =>
      (isDark(context) ? darkSubtext : lightSubtext)
          .withValues(alpha: alpha);

  static Color mutedIcon(BuildContext context) =>
      isDark(context) ? darkSubtext : lightSubtext;

  static Color field(BuildContext context) => isDark(context)
      ? darkCardAlt
      : Colors.white;

  static Color fieldBorder(BuildContext context) => isDark(context)
      ? darkBorder
      : lightBorder;

  static Color cardShadow(BuildContext context) => isDark(context)
      ? Colors.black.withValues(alpha: 0.45)
      : const Color(0xFF834DFB).withValues(alpha: 0.10);

  // === Gradien sesuai referensi ===
  /// Login: #200659 -> #834DFB -> #E3D7FF (selalu sama, tidak ikut tema).
  static const List<Color> loginGradient = [
    loginDeep,
    primaryColor,
    lavenderMist,
  ];

  /// Header homepage & sidebar: #834DFB -> #E3D7FF (selalu sama).
  static const List<Color> headerGradient = [
    lavenderMist,
    primaryColor,
  ];

  /// Teks di atas gradien header: darkPrimary (sesuai referensi).
  static const Color onHeaderText = darkPrimary;
  static Color onHeaderSubtext([double alpha = 0.72]) =>
      darkPrimary.withValues(alpha: alpha);
}


