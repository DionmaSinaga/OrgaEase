import 'package:flutter/material.dart';

class AppColors {
  // Warna Fondasi Utama Anda
  static const Color primaryPink = Color(0xFFDE539D);
  static const Color primaryTeal = Color(0xFF4EBFC1);
  static const Color lightBackground = Color(0xFFF9FDFD);
  static const Color lightCard = Color(0xFFEAEFF2);
  static const Color lightText = Color(0xFF0E1A1A);
  static const Color lightSubtext = Color(0xFF526363);
  static const Color lightBorder = Color(0xFFE0EBEB);

  // Palet Dark Mode
  static const Color darkPink = primaryPink; // tetap sama, tapi bisa diganti jika mau
  static const Color darkTeal = primaryTeal; // tetap sama, tapi bisa diganti jika mau
  static const Color darkBackground = Color(0xFF121E1F);
  static const Color darkCard = Color(0xFF1A2C2E);
  static const Color darkText = Color(0xFFE0F2F1);
  static const Color darkSubtext = Color(0xFF94A8A8);
  static const Color darkBorder = Color(0xFF2A3F41);

  // Fungsional
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF1C40F);
  static const Color error = Color(0xFFE74C3C);

  // --- Varian hover / tekan / lembut (saya sesuaikan dari palet Anda) ---
  // Light: hover = versi lebih gelap agar kontras di atas terang.
  static const Color pinkHover = Color(0xFFB8387C);
  static const Color tealHover = Color(0xFF389A9C);
  static const Color pinkSoft = Color(0xFFFCE4F0);
  static const Color tealSoft = Color(0xFFDCF3F4);
  // Dark: hover = versi lebih terang agar kontras di atas gelap.
  static const Color darkPinkHover = pinkHover;
  static const Color darkTealHover = tealHover;
  // Soft dark: hijau-keabu netral (BUKAN pink) agar background
  // menu/sidebar minimize tidak tampak kemerahan.
  static const Color darkPinkSoft = Color(0xFF22393C);
  static const Color darkTealSoft = Color(0xFF1E3D40);
  // Isian field saat dark: sedikit lebih terang dari kartu.
  static const Color darkField = Color(0xFF22393C);

  // --- Helper sadar-tema ---
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Aksen utama mengikuti tema (pink terang / pink lembut di dark).
  static Color primary(BuildContext context) =>
      isDark(context) ? darkPink : primaryPink;

  static Color secondary(BuildContext context) =>
      isDark(context) ? darkTeal : primaryTeal;

  static Color primaryHover(BuildContext context) =>
      isDark(context) ? darkPinkHover : pinkHover;

  static Color secondaryHover(BuildContext context) =>
      isDark(context) ? darkTealHover : tealHover;

  static Color primarySoft(BuildContext context) =>
      isDark(context) ? darkPinkSoft : pinkSoft;

  static Color secondarySoft(BuildContext context) =>
      isDark(context) ? darkTealSoft : tealSoft;

  /// Permukaan kartu: putih di light (kontras dgn lightBackground),
  /// darkCard di dark.
  static Color card(BuildContext context) =>
      isDark(context) ? darkCard : Colors.white;

  /// Permukaan alternatif (footer sidebar, chip ikon, dsb).
  static Color cardAlt(BuildContext context) =>
      isDark(context) ? darkField : lightCard;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color ink(BuildContext context) =>
      isDark(context) ? darkText : lightText;

  static Color subInk(BuildContext context, [double alpha = 0.6]) =>
      (isDark(context) ? darkSubtext : lightSubtext)
          .withValues(alpha: alpha);

  static Color mutedIcon(BuildContext context) =>
      isDark(context) ? darkSubtext : lightSubtext;

  /// Isian TextField.
  static Color field(BuildContext context) =>
      isDark(context) ? darkField : lightCard.withValues(alpha: 0.6);

  static Color fieldBorder(BuildContext context) =>
      isDark(context) ? darkBorder : lightText.withValues(alpha: 0.08);

  /// Warna bayangan kartu.
  static Color cardShadow(BuildContext context) => isDark(context)
      ? Colors.black.withValues(alpha: 0.35)
      : lightText.withValues(alpha: 0.07);
}

