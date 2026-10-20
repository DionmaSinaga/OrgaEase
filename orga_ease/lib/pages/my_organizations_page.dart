import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/models/app_user.dart';
import 'package:orga_ease/models/organization.dart';
import 'package:orga_ease/pages/create_organization_page.dart';
import 'package:orga_ease/pages/organization_detail_page.dart';
import 'package:orga_ease/repositories/organization_repository.dart';
import 'package:orga_ease/widgets/auth_components.dart';

/// Halaman "Organisasi Saya": daftar card organisasi yang diikuti user
/// (avatar/logo, nama, jabatan, instansi, kategori, jumlah anggota) +
/// tombol floating untuk membuat organisasi baru.
class MyOrganizationsPage extends StatefulWidget {
  final AppUser user;
  const MyOrganizationsPage({super.key, required this.user});

  @override
  State<MyOrganizationsPage> createState() => _MyOrganizationsPageState();
}

class _MyOrganizationsPageState extends State<MyOrganizationsPage> {
  final OrganizationRepository _repo = OrganizationRepository();
  List<Organization> _orgs = const [];
  bool _loading = true;
  String? _error;

  static const double _cardHeight = 180;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orgs = await _repo.fetchMyOrganizations(widget.user.id);
      if (!mounted) return;
      setState(() {
        _orgs = orgs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _prettyError(e);
        _loading = false;
      });
    }
  }

  String _prettyError(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  /// Buka form pembuatan organisasi; muat ulang daftar jika baru dibuat.
  Future<void> _openCreateForm() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => CreateOrganizationPage(user: widget.user),
      settings: const RouteSettings(name: '/organisasi/baru'),
    ));
    if (created == true) _load();
  }

  /// Buka halaman organisasi; route diambil dari nama organisasi (kunci unik).
  void _openDetail(Organization org) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OrganizationDetailPage(
        user: widget.user,
        orgName: org.name,
        initial: org,
      ),
      settings:
          RouteSettings(name: '/organisasi/${Uri.encodeComponent(org.name)}'),
    ));
  }

  int _crossCount(double w) {
    if (w < 520) return 1;
    if (w < 860) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: _body()),
      Positioned(
        right: 24,
        bottom: 24,
        child: FloatingActionButton.extended(
          tooltip: 'Buat organisasi baru',
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          onPressed: _openCreateForm,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Organisasi',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    ]);
  }

  Widget _body() {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: _load,
      child: LayoutBuilder(builder: (context, c) {
        final double w = c.maxWidth;
        final double hPad = w < 520 ? 16.0 : (w < 860 ? 24.0 : 32.0);
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 16),
                  _content(w),
                  // Ruang tambahan agar FAB tidak menutupi card terbawah.
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _header() {
    final narrow = MediaQuery.of(context).size.width < 560;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Organisasi Saya',
            style: TextStyle(
                fontSize: narrow ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink(context))),
        const SizedBox(height: 4),
        Text(
          'Semua organisasi yang kamu ikuti. Klik salah satu card untuk membuka halamannya.',
          style: TextStyle(fontSize: 13, color: AppColors.subInk(context)),
        ),
      ],
    );
  }

  Widget _content(double w) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }
    if (_error != null) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        title: 'Gagal memuat organisasi',
        message: _error!,
        actionLabel: 'Coba Lagi',
        onAction: _load,
      );
    }
    if (_orgs.isEmpty) {
      return _StateCard(
        icon: Icons.groups_outlined,
        iconColor: AppColors.primaryColor,
        title: 'Belum ada organisasi',
        message: 'Kamu belum tergabung dalam organisasi mana pun. '
            'Buat organisasi baru dengan tombol di kanan bawah.',
        actionLabel: 'Buat Organisasi',
        onAction: _openCreateForm,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossCount(w),
        mainAxisExtent: _cardHeight,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: _orgs.length,
      itemBuilder: (context, i) => _OrgCard(
        org: _orgs[i],
        onTap: () => _openDetail(_orgs[i]),
      ),
    );
  }
}

/// Card satu organisasi di halaman "Organisasi Saya".
class _OrgCard extends StatelessWidget {
  final Organization org;
  final VoidCallback onTap;
  const _OrgCard({required this.org, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      hoverColor: AppColors.primaryColor.withValues(alpha: 0.07),
      splashColor: AppColors.primaryColor.withValues(alpha: 0.12),
      highlightColor: AppColors.primaryColor.withValues(alpha: 0.09),
      onTap: onTap,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
                color: AppColors.cardShadow(context),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _OrgAvatar(org: org, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(org.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink(context))),
                    const SizedBox(height: 2),
                    Text(org.instansi ?? 'Tanpa instansi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.subInk(context))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.mutedIcon(context)),
            ]),
            const SizedBox(height: 10),
            _RoleBadge(role: org.myRole ?? 'Anggota'),
            const Spacer(),
            Row(children: [
              Expanded(
                child: _MetaChip(
                    icon: Icons.category_rounded, label: org.category),
              ),
              const SizedBox(width: 8),
              _MetaChip(
                  icon: Icons.people_outline_rounded,
                  label: '${org.memberCount} anggota'),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Avatar organisasi: logo (network) bila ada, fallback inisial nama.
class _OrgAvatar extends StatelessWidget {
  final Organization org;
  final double size;
  const _OrgAvatar({required this.org, required this.size});

  @override
  Widget build(BuildContext context) {
    final logo = org.logoUrl;
    final Widget inner;
    if (logo != null && logo.isNotEmpty) {
      inner = ClipOval(
        child: Image.network(
          logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initials(),
        ),
      );
    } else {
      inner = _initials();
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.35),
            width: 2),
      ),
      child: inner,
    );
  }

  Widget _initials() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text(org.initials,
          style: TextStyle(
              fontSize: size * 0.34,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor)),
    );
  }
}

/// Badge jabatan/role user di organisasi.
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.workspace_premium_rounded,
            size: 14, color: AppColors.primaryColor),
        const SizedBox(width: 5),
        Text(role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor)),
      ]),
    );
  }
}

/// Chip info kecil (kategori, jumlah anggota).
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: AppColors.mutedIcon(context)),
      const SizedBox(width: 5),
      Flexible(
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.subInk(context))),
      ),
    ]);
  }
}

/// Kartu pesan tengah (error memuat / daftar kosong).
class _StateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow(context),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle),
          child: Icon(icon, size: 32, color: iconColor),
        ),
        const SizedBox(height: 14),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink(context))),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.subInk(context, 0.65))),
        const SizedBox(height: 18),
        SizedBox(
          width: 220,
          child: GradientButton(
            text: actionLabel,
            gradientColors: GradientButton.themeGradient(context),
            onPressed: onAction,
          ),
        ),
      ]),
    );
  }
}