import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/widgets/notification_button.dart';
import 'package:orga_ease/widgets/theme_switch.dart';

/// Top bar reusable yang dipasang di halaman apapun.
///
/// Berisi:
/// - [leading] (tombol menu hamburger / panah kembali)
/// - [title] judul halaman di tengah
/// - [ThemeModeSwitch] untuk ganti terang/gelap
/// - [AppNotificationButton] untuk buka daftar notifikasi
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;
  final bool showThemeSwitch;
  final bool showNotification;
  final VoidCallback? onMenuPressed;
  final List<Widget>? extraActions;

  const AppTopBar({
    super.key,
    this.leading,
    required this.title,
    this.showThemeSwitch = true,
    this.showNotification = true,
    this.onMenuPressed,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final actions = <Widget>[];

    if (showThemeSwitch) {
      actions.add(const ThemeModeSwitch(compact: true));
      actions.add(const SizedBox(width: 8));
    }

    if (showNotification) {
      actions.add(const AppNotificationButton());
    }

    if (extraActions != null) {
      actions.addAll(extraActions!);
    }

    return AppBar(
      backgroundColor: AppColors.page(context),
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      leading: leading ??
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: onMenuPressed ?? () => Navigator.of(context).pop(),
          ),
      actions: actions.isEmpty ? null : actions,
    );
  }
}
