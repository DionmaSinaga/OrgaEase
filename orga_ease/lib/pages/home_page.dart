import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/models/app_user.dart';
import 'package:orga_ease/pages/login_page.dart';
import 'package:orga_ease/widgets/auth_components.dart';
import 'package:orga_ease/widgets/app_sidebar.dart';

/// Homepage dgn sidebar kiri menyatu dgn appbar + bisa minimize.
/// Sidebar berisi kategori homepage; bawah = profil ala Discord.
class HomePage extends StatefulWidget {
  final AppUser user;
  const HomePage({super.key, required this.user});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _collapsed = false;
  // Apakah ISI sidebar tampil versi expanded (ada teks).
  // Dipisah dari [_collapsed] (lebar container) agar tidak overflow sesaat:
  // saat expand, lebar masih ~80px selama animasi 220ms sedangkan teks
  // butuh ~264px. Jadi teks baru dipasang SETELAH animasi selesai.
  bool _contentExpanded = true;
  // Token untuk membatalkan future tertunda saat user toggle cepat.
  int _collapseToken = 0;
  bool _manageExpanded = true;
  late final List<SideMenuItem> _menus = defaultSideMenus();
  static const double _wExp = 264;
  static const double _wCol = 80;
  static const double _topH = 64;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _initials {
    final parts = widget.user.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get _memberSince {
    final d = widget.user.createdAt;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final m =
        (d.month >= 1 && d.month <= 12) ? months[d.month] : '${d.month}';
    return '${d.day} $m ${d.year}';
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _soon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label segera hadir di OrgaEase.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _selectMenu(int i, {bool fromDrawer = false}) {
    setState(() => _selectedIndex = i);
    if (fromDrawer) Navigator.of(context).pop();
  }

  AppSidebar _sidebar({required bool inDrawer}) {
    return AppSidebar(
      menus: _menus,
      selectedIndex: _selectedIndex,
      // Di mode lebar: isi mengikuti _contentExpanded (tertunda 230ms
      // saat expand agar tidak overflow). Di drawer: selalu expanded.
      collapsed: inDrawer ? false : !_contentExpanded,
      manageExpanded: _manageExpanded,
      userName: widget.user.name,
      userEmail: widget.user.email,
      initials: _initials,
      onToggleCollapsed: inDrawer ? () {} : _toggleCollapsed,
      onToggleManage: () =>
          setState(() => _manageExpanded = !_manageExpanded),
      onSelect: (i) =>
          _selectMenu(i, fromDrawer: inDrawer),
      onSettings: () => _soon('Pengaturan'),
      onLogout: _logout,
      onCloseDrawer: inDrawer
          ? () => Navigator.of(context).pop()
          : null,
      inDrawer: inDrawer,
    );
  }

  /// Dipanggil sebelum Scaffold mode sempit dibangun: pastikan drawer
  /// selalu dibuka dalam keadaan expanded penuh, walau sidebar desktop
  /// sedang minimize. Mencegah bug "klik OE 2x".
  void _openDrawer() {
    if (_collapsed) setState(() => _collapsed = false);
    if (!_contentExpanded) setState(() => _contentExpanded = true);
    _scaffoldKey.currentState?.openDrawer();
  }

  /// Toggle minimize/expand sidebar TANPA overflow sesaat.
  ///
  /// - Collapse (264 -> 80): isi langsung jadi ikon (aman di lebar berapa pun),
  ///   lalu lebar container dianimasikan.
  /// - Expand (80 -> 264): lebar container dianimasikan DULU (isi tetap ikon),
  ///   teks baru dipasang setelah animasi 220ms selesai. Tanpa jeda ini,
  ///   teks langsung dirender saat lebar masih ~80px -> strip kuning 0,2 detik.
  void _toggleCollapsed() {
    final int token = ++_collapseToken;
    if (!_collapsed) {
      // Mulai collapse: kecilkan isi dulu, baru container.
      setState(() {
        _collapsed = true;
        _contentExpanded = false;
      });
    } else {
      // Mulai expand: lebarkan container dulu (isi tetap ikon)...
      setState(() => _collapsed = false);
      // ...teks dipasang setelah animasi lebar (220ms) selesai.
      Future.delayed(const Duration(milliseconds: 230), () {
        if (!mounted || token != _collapseToken) return;
        setState(() => _contentExpanded = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final bool narrow = c.maxWidth < 760;
      if (narrow) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundWhite,
          drawer: Drawer(width: _wExp, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), child: _sidebar(inDrawer: true)),
          body: Column(children: [_topBar(true), Expanded(child: _content())]),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: _collapsed ? _wCol : _wExp,
            decoration: const BoxDecoration(color: Colors.white,
              border: Border(right: BorderSide(color: AppColors.cardGray))),
            // clipBehavior memotong sisa render 1 frame terakhir bila ada,
            // sehingga strip kuning "overflowed" tidak sempat terlihat.
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              // Kunci lebar child = lebar target animasi. Tanpa ini, Row
              // expanded di dalam (_Header/_Tile) memaksa min. width 264px
              // saat container masih 80px -> overflow sesaat.
              width: _collapsed ? _wCol : _wExp,
              child: _sidebar(inDrawer: false),
            ),
          ),
          Expanded(child: Column(children: [_topBar(false), Expanded(child: _content())])),
        ]),
      );
    });
  }

  Widget _topBar(bool narrow) {
    final cur = _menus[_selectedIndex];
    return Container(
      height: _topH,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primaryPink, AppColors.primaryTeal]),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      // TANPA hamburger: navigasi buka/tutup hanya via logo "OE"
      // (mode minimize) dan panah kiri (di header sidebar).
      child: Row(children: [
        // Saat drawer tertutup di layar sempit, logo OE di topbar
        // berfungsi sebagai tombol pembuka drawer.
        if (narrow)
          Tooltip(
            message: 'Buka menu',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _openDrawer,
              child: Container(
                width: 36, height: 36, alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('OE',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryPink,
                        fontSize: 13)),
              ),
            ),
          ),
        if (narrow) const SizedBox(width: 10),
        Icon(cur.icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cur.label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          if (!narrow) Text('$_greeting, ${widget.user.name}', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
        ])),
        IconButton(tooltip: 'Notifikasi', icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => _soon('Notifikasi')),
        const SizedBox(width: 4),
        // Container(width: 36, height: 36, alignment: Alignment.center,
        //   decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25),
        //     shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
        //   child: Text(_initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
        // const SizedBox(width: 8),
      ]),
    );
  }

  Widget _content() {
    if (_selectedIndex == 0) {
      return _HomeBody(
        user: widget.user,
        menus: _menus.sublist(1),
        initials: _initials,
        greeting: _greeting,
        memberSince: _memberSince,
        onLogout: _logout,
        onMenuTap: (label) {
          final idx = _menus.indexWhere((m) => m.label == label);
          if (idx != -1) {
            setState(() => _selectedIndex = idx);
          } else {
            _soon(label);
          }
        },
      );
    }
    final item = _menus[_selectedIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardGray),
            boxShadow: [BoxShadow(color: AppColors.textDark.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8))]),
          child: Column(children: [
            Container(padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(item.icon, size: 36, color: item.color)),
            const SizedBox(height: 16),
            Text(item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text('Halaman "${item.label}" segera hadir di OrgaEase. Untuk sekarang kamu bisa kembali ke Beranda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textDark.withValues(alpha: 0.65))),
            const SizedBox(height: 20),
            SizedBox(width: 220, child: GradientButton(text: 'Kembali ke Beranda',
              onPressed: () => setState(() => _selectedIndex = 0))),
          ]),
        ),
      )),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final AppUser user;
  final List<SideMenuItem> menus;
  final String initials;
  final String greeting;
  final String memberSince;
  final VoidCallback onLogout;
  final ValueChanged<String> onMenuTap;

  const _HomeBody({
    required this.user,
    required this.menus,
    required this.initials,
    required this.greeting,
    required this.memberSince,
    required this.onLogout,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double hPad = w < 480 ? 16 : (w < 800 ? 24 : 32);
        final int crossCount = w < 480 ? 2 : (w < 900 ? 3 : 4);
        final bool narrow = w < 560;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeCard(
                    user: user,
                    initials: initials,
                    greeting: greeting,
                    memberSince: memberSince,
                    narrow: narrow,
                  ),
                  const SizedBox(height: 20),
                  Text('Menu Utama',
                      style: TextStyle(
                          fontSize: narrow ? 16 : 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text('Kelola organisasimu dari sini',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark
                              .withValues(alpha: 0.6))),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: menus.length,
                    itemBuilder: (context, i) {
                      final m = menus[i];
                      return _MenuCard(
                        item: m,
                        onTap: () => onMenuTap(m.label),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  GradientButton(text: 'Keluar', onPressed: onLogout),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _WelcomeCard extends StatelessWidget {
  final AppUser user;
  final String initials;
  final String greeting;
  final String memberSince;
  final bool narrow;

  const _WelcomeCard({
    required this.user,
    required this.initials,
    required this.greeting,
    required this.memberSince,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(narrow ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryPink, AppColors.primaryTeal],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: narrow
          ? Column(
              children: [
                _Avatar(initials: initials),
                const SizedBox(height: 14),
                _WelcomeText(
                  greeting: greeting,
                  name: user.name,
                  email: user.email,
                  memberSince: memberSince,
                  centered: true,
                ),
              ],
            )
          : Row(
              children: [
                _Avatar(initials: initials),
                const SizedBox(width: 18),
                Expanded(
                  child: _WelcomeText(
                    greeting: greeting,
                    name: user.name,
                    email: user.email,
                    memberSince: memberSince,
                    centered: false,
                  ),
                ),
              ],
            ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final SideMenuItem item;
  final VoidCallback onTap;

  const _MenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardGray),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 26, color: item.color),
            ),
            const SizedBox(height: 10),
            Text(item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(initials,
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white)),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final String greeting;
  final String name;
  final String email;
  final String memberSince;
  final bool centered;

  const _WelcomeText({
    required this.greeting,
    required this.name,
    required this.email,
    required this.memberSince,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text('$greeting,',
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9))),
        Text(name,
            textAlign: align,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(email,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9))),
        const SizedBox(height: 2),
        Text('Anggota sejak $memberSince',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }
}
