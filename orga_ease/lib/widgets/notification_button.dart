import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/core/theme_controller.dart';

/// Model satu item notifikasi dummy.
class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final String time;
  final bool read;
  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.time,
    this.read = false,
  });
}

/// Daftar notifikasi dummy yang ditampilkan saat tombol notifikasi ditekan.
final List<_NotifItem> _dummyNotifications = const [
  _NotifItem(
    icon: Icons.group_add_rounded,
    color: Color(0xFF834DFB),
    title: 'Anggota baru bergabung',
    sub: 'Rina Saputra telah menjadi anggota organisasi.',
    time: 'Baru saja',
    read: false,
  ),
  _NotifItem(
    icon: Icons.event_note_rounded,
    color: Color(0xFFFBD100),
    title: 'Jadwal rapat mingguan',
    sub: 'Rapat pembahasan keuangan hari Senin, 09.00 WIB.',
    time: '2 jam yang lalu',
    read: false,
  ),
  _NotifItem(
    icon: Icons.file_upload_rounded,
    color: Color(0xFF2ECC71),
    title: 'Dokumen baru diunggah',
    sub: 'Laporan keuangan triwulan III telah ditambahkan.',
    time: '5 jam yang lalu',
    read: true,
  ),
  _NotifItem(
    icon: Icons.person_outline_rounded,
    color: Color(0xFF6B6390),
    title: 'Permintaan gabungan',
    sub: 'Andi Wijaya mengajukan gabungan ke organisasi.',
    time: 'Kemarin',
    read: true,
  ),
  _NotifItem(
    icon: Icons.announcement_rounded,
    color: Color(0xFFE74C3C),
    title: 'Pengumuman penting',
    sub: 'Jadwal kegiatan diubah ke minggu depan.',
    time: '2 hari yang lalu',
    read: true,
  ),
];

/// Tombol notifikasi (lonceng) dengan badge jumlah belum dibaca.
/// Saat ditekan, menampilkan popup daftar notifikasi dummy.
class AppNotificationButton extends StatefulWidget {
  final bool compact;
  const AppNotificationButton({super.key, this.compact = false});

  @override
  State<AppNotificationButton> createState() => _AppNotificationButtonState();
}

class _AppNotificationButtonState extends State<AppNotificationButton> {
  int _unread = 2;

  void _openNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border(context)),
        ),
        title: Row(
          children: [
            Icon(Icons.notifications_outlined,
                color: AppColors.primary(context), size: 22),
            const SizedBox(width: 8),
            Text('Notifikasi',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.ink(context))),
          ],
        ),
        content: SizedBox(
          width: 340,
          height: 360,
          child: ListView.separated(
            itemCount: _dummyNotifications.length,
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.border(context), height: 1),
            itemBuilder: (context, i) {
              final n = _dummyNotifications[i];
              final unread = i < _unread;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: n.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: n.color.withValues(alpha: 0.35)),
                  ),
                  child: Icon(n.icon, color: n.color, size: 20),
                ),
                title: Text(n.title,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                        color: AppColors.ink(context))),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(n.sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subInk(context, 0.7))),
                    const SizedBox(height: 2),
                    Text(n.time,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedIcon(context))),
                  ],
                ),
                trailing: unread
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle),
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup',
                style: TextStyle(color: AppColors.primary(context))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark;
    return Tooltip(
      message: 'Notifikasi',
      child: Stack(
        children: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                size: widget.compact ? 18 : 22,
                color: AppColors.ink(context)),
            onPressed: () => _openNotifications(context),
          ),
          Positioned(
            right: widget.compact ? 2 : 4,
            top: widget.compact ? 2 : 4,
            child: Container(
              width: widget.compact ? 8 : 10,
              height: widget.compact ? 8 : 10,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF18102B)
                        : const Color(0xFFF6F3FF),
                    width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
