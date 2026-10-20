import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/core/theme_controller.dart';

/// Switchbox pengubah terang/gelap, dipasang di sebelah tombol notifikasi.
/// Ikon matahari/bulan mengikuti status; thumb kuning saat dark.
class ThemeModeSwitch extends StatelessWidget {
  final bool compact;
  const ThemeModeSwitch({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Tooltip(
          message: isDark ? 'Mode gelap aktif' : 'Mode terang aktif',
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.onHeaderText.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.onHeaderText.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.onHeaderText,
                  size: 16,
                ),
                const SizedBox(width: 4),
                // Switchbox utama pengubah dark mode.
                SizedBox(
                  height: 28,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: isDark,
                      onChanged: ThemeController.setDark,
                      activeThumbColor: AppColors.secondaryColor,
                      activeTrackColor: AppColors.onHeaderText
                          .withValues(alpha: 0.55),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.onHeaderText
                          .withValues(alpha: 0.30),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
