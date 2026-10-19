import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/models/app_user.dart';
import 'package:orga_ease/pages/login_page.dart';
import 'package:orga_ease/widgets/auth_components.dart';

/// Halaman home / welcoming setelah user berhasil login.
/// Responsif untuk window Windows yang di-resize.
class HomePage extends StatelessWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _initials {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get _memberSince {
    final d = user.createdAt;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final m =
        (d.month >= 1 && d.month <= 12) ? months[d.month] : '${d.month}';
    return '${d.day} $m ${d.year}';
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label segera hadir di OrgaEase.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItem('Organisasi Saya', Icons.groups_rounded,
          AppColors.primaryPink),
      _MenuItem(
          'Kegiatan', Icons.event_note_rounded, AppColors.primaryTeal),
      _MenuItem('Anggota', Icons.person_outline_rounded,
          AppColors.tealHover),
      _MenuItem(
          'Laporan', Icons.bar_chart_rounded, AppColors.pinkHover),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('OrgaEase',
            style: TextStyle(fontWeight: FontWeight.w800)),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryPink, AppColors.primaryTeal],
            ),
          ),
        ),
      ),
      body: _HomeBody(
        user: user,
        menus: menus,
        initials: _initials,
        greeting: _greeting,
        memberSince: _memberSince,
        onLogout: () => _logout(context),
        onMenuTap: (label) => _soon(context, label),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  const _MenuItem(this.label, this.icon, this.color);
}

class _HomeBody extends StatelessWidget {
  final AppUser user;
  final List<_MenuItem> menus;
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
  final _MenuItem item;
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
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9))),
        Text(name,
            textAlign: align,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(email,
            textAlign: align,
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9))),
        const SizedBox(height: 2),
        Text('Anggota sejak $memberSince',
            textAlign: align,
            style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }
}
