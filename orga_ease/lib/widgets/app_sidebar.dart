import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';

/// Model menu sidebar (kategori homepage).
class SideMenuItem {
  final String label;
  final IconData icon;
  final Color color;
  const SideMenuItem(this.label, this.icon, this.color);
}

/// Daftar kategori homepage utama (semua ikon netral; aksen via secondary).
List<SideMenuItem> defaultSideMenus() => const [
      SideMenuItem('Beranda', Icons.dashboard_rounded, AppColors.primaryColor),
      SideMenuItem('Organisasi Saya', Icons.groups_rounded, AppColors.primaryColor),
      SideMenuItem('Kegiatan', Icons.event_note_rounded, AppColors.primaryColor),
      SideMenuItem('Anggota', Icons.person_outline_rounded, AppColors.primaryColor),
      SideMenuItem('Laporan', Icons.bar_chart_rounded, AppColors.primaryColor),
    ];

/// Aksen menu: ungu primary di kedua tema; sorotan kuning hanya
/// untuk dot/penanda aktif (lihat [_Tile]).
extension SideMenuColor on SideMenuItem {
  Color resolveColor(BuildContext context) => AppColors.primaryColor;
}

/// - Di layar lebar ([collapsed] mengatur minimize/expand seperti biasa).
/// - Di dalam [Drawer] (layar sempit, [inDrawer] = true): SELALU tampil
///   expanded penuh berisi teks, walau sidebar desktop sedang minimize.
///   Ini mencegah bug: minimize di layar penuh -> kecilkan window ->
///   drawer terbuka tapi tanpa teks sehingga "OE" harus diklik 2x.
class AppSidebar extends StatelessWidget {
  final List<SideMenuItem> menus;
  final int selectedIndex;
  final bool collapsed;
  final bool manageExpanded;
  final String userName;
  final String userEmail;
  final String initials;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onToggleManage;
  final ValueChanged<int> onSelect;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  final VoidCallback? onCloseDrawer;
  final bool inDrawer;

  const AppSidebar({
    super.key,
    required this.menus,
    required this.selectedIndex,
    required this.collapsed,
    required this.manageExpanded,
    required this.userName,
    required this.userEmail,
    required this.initials,
    required this.onToggleCollapsed,
    required this.onToggleManage,
    required this.onSelect,
    required this.onSettings,
    required this.onLogout,
    this.onCloseDrawer,
    this.inDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Drawer selalu expanded penuh (ada teks menu). Status minimize
    // (_collapsed) hanya berlaku untuk sidebar di layar lebar.
    final bool exp = inDrawer ? true : !collapsed;
    // Background sidebar eksplisit sama untuk minimize & full layar
    // (AppColors.card): putih di light, darkCard di dark.
    return Container(
      color: AppColors.card(context),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          expanded: exp,
          onToggle: onToggleCollapsed,
          onClose: onCloseDrawer,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: exp ? 12 : 8, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // if (exp)
                //   const Padding(
                //     padding: EdgeInsets.fromLTRB(8, 2, 8, 8),
                //     child: Text('MENU UTAMA',
                //         style: TextStyle(
                //             fontSize: 11,
                //             fontWeight: FontWeight.w800,
                //             letterSpacing: 1.1,
                //             color: Color(0xFF94A3B8))),
                //   ),
                _Tile(
                  item: menus[0],
                  selected: selectedIndex == 0,
                  expanded: exp,
                  onTap: () => onSelect(0),
                ),
                const SizedBox(height: 4),
                _ManageGroup(
                  expanded: exp,
                  isOpen: manageExpanded,
                  hasActive: selectedIndex >= 1,
                  onToggle: onToggleManage,
                  children: [
                    for (int i = 1; i < menus.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _Tile(
                          item: menus[i],
                          selected: selectedIndex == i,
                          expanded: exp,
                          subItem: exp,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _ProfileFooter(
          expanded: exp,
          userName: userName,
          userEmail: userEmail,
          initials: initials,
          onSettings: onSettings,
          onLogout: onLogout,
        ),
      ],
      ),
    );
  }
}
/// Header gradient SAMA dgn topbar agar menyatu tanpa sekat.
/// - Logo "OE" = tombol untuk MEMBUKA sidebar (saat minimize / drawer tertutup).
/// - Panah ke kiri = tombol untuk MENUTUP / minimize sidebar.
class _Header extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback? onClose;
  const _Header({required this.expanded, required this.onToggle, this.onClose});
  @override
  Widget build(BuildContext context) {
    Widget oeLogo({required double fontSize, required String tooltip}) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: expanded ? null : onToggle,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.onHeaderText,
                borderRadius: BorderRadius.circular(12)),
            child: Text('OE',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: fontSize)),
          ),
        ),
      );
    }

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        // Referensi sidebar: #834DFB -> #E3D7FF (sama dgn topbar).
          color: AppColors.primaryColor),

      padding: EdgeInsets.symmetric(horizontal: expanded ? 16 : 8, vertical: 10),
      // Clip agar Row expanded tidak overflow sesaat saat AnimatedContainer
      // masih di tengah animasi 80 <-> 264px.
      clipBehavior: Clip.hardEdge,
      child: expanded
          ? Row(children: [
              // Logo statis saat sidebar terbuka (tombol buka tidak perlu).
              Container(
                width: 38, height: 38, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.onHeaderText, borderRadius: BorderRadius.circular(12)),
                child: const Text('OE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15)),
              ),
              const Spacer(flex: 1),
              const Text('OrgaEase', style: TextStyle(color: AppColors.onHeaderText, fontWeight: FontWeight.w700, fontSize: 17)),
              const Spacer(flex: 3),
              // Panah ke kiri = tutup / minimize sidebar.
              IconButton(
                tooltip: onClose != null ? 'Tutup menu' : 'Tutup sidebar',
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.onHeaderText, size: 28),
                onPressed: onClose ?? onToggle,
              ),
            ])
          : Center(
              // Logo OE = tombol untuk MEMBUKA sidebar saat minimize.
              child: oeLogo(fontSize: 14, tooltip: 'Buka sidebar'),
            ),
    );
  }
}

/// Tile menu tunggal.
class _Tile extends StatelessWidget {
  final SideMenuItem item;
  final bool selected;
  final bool expanded;
  final bool subItem;
  final VoidCallback onTap;
  const _Tile({required this.item, required this.selected, required this.expanded, this.subItem = false, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primaryColor;
    // Sorotan kuning hanya untuk dot/section aktif.
    const spot = AppColors.secondaryColor;
    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Tooltip(
          message: item.label,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            hoverColor: accent.withValues(alpha: 0.08),
            onTap: onTap,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? accent.withValues(alpha: 0.22) : Colors.transparent),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(item.icon, color: selected ? accent : AppColors.mutedIcon(context), size: 22),
                  if (selected)
                    Positioned(
                      bottom: 6,
                      child: Container(width: 6, height: 6,
                        decoration: const BoxDecoration(color: spot, shape: BoxShape.circle)),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      hoverColor: accent.withValues(alpha: 0.08),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: subItem ? 10 : 12, vertical: 10),
        margin: subItem ? const EdgeInsets.only(left: 22) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? accent.withValues(alpha: 0.22) : Colors.transparent),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: selected ? accent.withValues(alpha: 0.16) : AppColors.cardAlt(context),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, size: 18, color: selected ? accent : AppColors.mutedIcon(context)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.ink(context) : AppColors.subInk(context, 0.9)))),
          if (selected) Container(width: 8, height: 8,
            decoration: const BoxDecoration(color: spot, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}

/// Grup dropdown Kelola.
class _ManageGroup extends StatelessWidget {
  final bool expanded;
  final bool isOpen;
  final bool hasActive;
  final VoidCallback onToggle;
  final List<Widget> children;
  const _ManageGroup({required this.expanded, required this.isOpen, required this.hasActive, required this.onToggle, required this.children});
  @override
  Widget build(BuildContext context) {
    // Saat minimize: header "Kelola" disembunyikan total agar tidak
    // overflow; hanya isi menu (children = ikon) yang ditampilkan.
    if (!expanded) return Column(children: children);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.primaryColor.withValues(alpha: 0.08),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: hasActive
                ? AppColors.primaryColor.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            // Garis kuning tipis sebagai penanda section aktif.
            border: Border(
              left: BorderSide(
                color: hasActive
                    ? AppColors.secondaryColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: AppColors.cardAlt(context),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.folder_open_rounded,
                  size: 18, color: AppColors.mutedIcon(context))),
            const SizedBox(width: 10),
            Expanded(child: Text('Kelola',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                  color: AppColors.subInk(context, 0.9)))),
            AnimatedRotation(turns: isOpen ? 0.5 : 0, duration: const Duration(milliseconds: 200),
              child: Icon(Icons.expand_more_rounded, size: 20, color: AppColors.mutedIcon(context))),
          ]),
        ),
      ),
      AnimatedCrossFade(
        firstChild: const SizedBox.shrink(),
        secondChild: Padding(padding: const EdgeInsets.only(top: 4), child: Column(children: children)),
        crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 220),
      ),
    ]);
  }
}

/// Footer profil ala Discord.
class _ProfileFooter extends StatelessWidget {
  final bool expanded;
  final String userName;
  final String userEmail;
  final String initials;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  const _ProfileFooter({required this.expanded, required this.userName, required this.userEmail, required this.initials, required this.onSettings, required this.onLogout});
  Widget _avatar(BuildContext context) {
    return Stack(children: [
      Container(
        width: 42, height: 42, alignment: Alignment.center,
        decoration: const BoxDecoration(
          // Avatar profil: gradien header ungu, teks darkPrimary.
          gradient: LinearGradient(colors: AppColors.headerGradient),
          shape: BoxShape.circle,
        ),
        child: Text(initials,
            style: const TextStyle(
                color: AppColors.onHeaderText,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
      ),
      Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12,
        decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
          border: Border.all(color: AppColors.secondaryColor, width: 2)))),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    final footerBg = AppColors.cardAlt(context);
    final footerBorder = AppColors.border(context);
    if (!expanded) {
      return Container(
        decoration: BoxDecoration(color: footerBg,
          border: Border(top: BorderSide(color: footerBorder))),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(children: [
          _avatar(context),
          const SizedBox(height: 8),
          IconButton(tooltip: 'Pengaturan', icon: const Icon(Icons.settings_outlined, size: 20),
            color: AppColors.mutedIcon(context), onPressed: onSettings),
          IconButton(tooltip: 'Keluar', icon: const Icon(Icons.logout_rounded, size: 20),
            color: AppColors.error, onPressed: onLogout),
        ]),
      );
    }
    return Container(
      decoration: BoxDecoration(color: footerBg,
        border: Border(top: BorderSide(color: footerBorder))),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _avatar(context),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(userName, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.ink(context))),
          Text(userEmail, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: AppColors.mutedIcon(context))),
          const Text('Online', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
        ])),
        IconButton(tooltip: 'Pengaturan', icon: const Icon(Icons.settings_outlined, size: 20),
          color: AppColors.mutedIcon(context), onPressed: onSettings),
        IconButton(tooltip: 'Keluar', icon: const Icon(Icons.logout_rounded, size: 20),
          color: AppColors.error, onPressed: onLogout),
      ]),
    );
  }
}


